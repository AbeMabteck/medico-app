import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/consulta_model.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'connectivity_service.dart';

class DoctorService {
  final _authService = AuthService();
  final _db = DatabaseService();
  final _connectivity = ConnectivityService();

  /// Construye los headers necesarios para cada request a la API.
  /// Incluye el token JWT guardado en SharedPreferences.
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─── OBTENER DOCTORES ────────────────────────────────────────────
  /// Obtiene la lista completa de doctores del usuario.
  ///
  /// Flujo:
  /// - Con internet: llama a la API, guarda el resultado en SQLite y retorna.
  /// - Sin internet: lee directamente de SQLite con los datos del último sync.
  /// - Si la API falla por cualquier razón, cae al fallback de SQLite
  ///   para no dejar al usuario sin datos.
  Future<List<DoctorModel>> getDoctores() async {
    if (await _connectivity.isOnline()) {
      try {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse(ApiConstants.doctores),
          headers: headers,
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          final doctores = data.map((d) => DoctorModel.fromJson(d)).toList();
          // Persistir en SQLite para tener disponible offline
          await _db.upsertAll(
            'doctores',
            doctores.map((d) => _toLocalMap(d)).toList(),
          );
          return doctores;
        }
      } catch (_) {
        // Si hay error de red o timeout, caemos al cache local
      }
    }
    // Sin internet o error — retornar datos del cache local
    // Solo retornamos los activos (isActive = 1)
    final rows = await _db.getAll('doctores');
    return rows
        .where((r) => r['isActive'] == 1)
        .map((r) => _fromLocalMap(r))
        .toList();
  }

  // ─── CREAR DOCTOR ────────────────────────────────────────────────
  /// Registra un nuevo doctor en el directorio del usuario.
  ///
  /// Flujo offline:
  /// - Genera un ID temporal negativo para identificar el registro
  ///   localmente antes de sincronizar con el servidor.
  /// - Guarda en SQLite con pendingAction = 'create'.
  /// - Encola la operación para enviarla cuando regrese internet.
  Future<void> createDoctor({
    required String nombre,
    String? especialidad,
    String? consultorio,
    String? telefono,
    String? notas,
  }) async {
    final payload = jsonEncode({
      'nombre': nombre,
      'especialidad': especialidad,
      'consultorio': consultorio,
      'telefono': telefono,
      'notas': notas,
    });

    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConstants.doctores),
        headers: headers,
        body: payload,
      );
      if (response.statusCode == 201) {
        // Refrescar cache local con el registro recién creado
        await getDoctores();
        return;
      }
      throw Exception('Error al crear doctor');
    }

    // Sin internet — guardar localmente con ID temporal negativo
    final tempId = -(DateTime.now().millisecondsSinceEpoch);
    await _db.upsert('doctores', {
      'id': tempId,
      'nombre': nombre,
      'especialidad': especialidad,
      'consultorio': consultorio,
      'isActive': 1,
      'pendingAction': 'create',
      'updatedAt': DateTime.now().toIso8601String(),
    });
    // Encolar para sincronizar cuando regrese internet
    await _db.addToSyncQueue(
      entity: 'doctores',
      action: 'create',
      entityId: tempId,
      payload: payload,
    );
  }

  // ─── ACTUALIZAR DOCTOR ───────────────────────────────────────────
  /// Actualiza los datos de un doctor existente.
  ///
  /// Lógica de pendingAction offline:
  /// - Si el registro tiene pendingAction = 'create' (nunca se sincronizó),
  ///   mantiene 'create' para que al sincronizar se envíe como POST, no PUT.
  /// - Si ya existía en el servidor, marca como 'update' para enviar PUT.
  Future<void> updateDoctor(
    int id, {
    String? nombre,
    String? especialidad,
    String? consultorio,
    String? telefono,
    String? notas,
  }) async {
    final payload = jsonEncode({
      'nombre': nombre,
      'especialidad': especialidad,
      'consultorio': consultorio,
      'telefono': telefono,
      'notas': notas,
    });

    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConstants.doctores}/$id'),
        headers: headers,
        body: payload,
      );
      if (response.statusCode == 204) {
        // Refrescar cache local
        await getDoctores();
        return;
      }
      throw Exception('Error al actualizar doctor');
    }

    // Sin internet — actualizar en SQLite y encolar
    final existing = await _db.getById('doctores', id);
    await _db.update('doctores', {
      'nombre': nombre,
      'especialidad': especialidad,
      'consultorio': consultorio,
      // Si nunca se sincronizó conserva 'create', si ya existe en servidor marca 'update'
      'pendingAction': existing?['pendingAction'] == 'create'
          ? 'create'
          : 'update',
      'updatedAt': DateTime.now().toIso8601String(),
    }, id);
    await _db.addToSyncQueue(
      entity: 'doctores',
      action: 'update',
      entityId: id,
      payload: payload,
    );
  }

  // ─── ELIMINAR DOCTOR ─────────────────────────────────────────────
  /// Elimina un doctor del directorio (soft delete en el servidor).
  ///
  /// Lógica especial offline:
  /// - Si el registro tiene pendingAction = 'create', significa que nunca
  ///   llegó al servidor, así que se elimina directo de SQLite sin encolar.
  /// - Si ya existe en el servidor, se marca con isActive = 0 localmente
  ///   (para que desaparezca de la lista) y se encola para el servidor.
  Future<void> deleteDoctor(int id) async {
    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.doctores}/$id'),
        headers: headers,
      );
      if (response.statusCode == 204) {
        // Eliminar también del cache local
        await _db.delete('doctores', id);
        return;
      }
      throw Exception('Error al eliminar doctor');
    }

    // Sin internet — revisar si el registro existe solo localmente
    final existing = await _db.getById('doctores', id);
    if (existing?['pendingAction'] == 'create') {
      // Nunca llegó al servidor, eliminar directo sin encolar
      await _db.delete('doctores', id);
    } else {
      // Ya existe en el servidor — marcar como inactivo localmente
      // y encolar para hacer el soft delete en el servidor al sincronizar
      await _db.update('doctores', {
        'isActive': 0,
        'pendingAction': 'delete',
        'updatedAt': DateTime.now().toIso8601String(),
      }, id);
      await _db.addToSyncQueue(
        entity: 'doctores',
        action: 'delete',
        entityId: id,
        payload: null,
      );
    }
  }

  // ─── HELPERS LOCALES ─────────────────────────────────────────────

  /// Convierte un DoctorModel a un Map compatible con SQLite.
  /// El campo booleano 'activo' se guarda como entero (1/0)
  /// porque SQLite no tiene tipo booleano nativo.
  Map<String, dynamic> _toLocalMap(DoctorModel d) => {
    'id': d.id,
    'nombre': d.nombre,
    'especialidad': d.especialidad,
    'consultorio': d.consultorio,
    'isActive': d.activo ? 1 : 0,
    'pendingAction': null,
    'updatedAt': DateTime.now().toIso8601String(),
  };

  /// Convierte un row de SQLite a DoctorModel.
  /// Usa valores por defecto seguros para campos que podrían ser null
  /// en registros creados offline antes de sincronizar.
  DoctorModel _fromLocalMap(Map<String, dynamic> r) => DoctorModel(
    id: r['id'],
    nombre: r['nombre'] ?? '',
    especialidad: r['especialidad'],
    consultorio: r['consultorio'],
    activo: r['isActive'] == 1,
  );
}
