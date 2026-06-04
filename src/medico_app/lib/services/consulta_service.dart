import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/consulta_model.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'connectivity_service.dart';

class ConsultaService {
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

  // ─── OBTENER CONSULTAS ───────────────────────────────────────────
  /// Obtiene la lista completa de consultas del usuario.
  ///
  /// Flujo:
  /// - Con internet: llama a la API, guarda el resultado en SQLite y retorna.
  /// - Sin internet: lee directamente de SQLite con los datos del último sync.
  /// - Si la API falla por cualquier razón (timeout, error 5xx), también
  ///   cae al fallback de SQLite para no dejar al usuario sin datos.
  Future<List<ConsultaModel>> getConsultas() async {
    if (await _connectivity.isOnline()) {
      try {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse(ApiConstants.consultas),
          headers: headers,
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          final consultas = data.map((c) => ConsultaModel.fromJson(c)).toList();
          // Persistir en SQLite para tener disponible offline
          await _db.upsertAll(
            'consultas',
            consultas.map((c) => _toLocalMap(c)).toList(),
          );
          return consultas;
        }
      } catch (_) {
        // Si hay error de red o timeout, caemos al cache local
      }
    }
    // Sin internet o error — retornar datos del cache local
    final rows = await _db.getAll('consultas');
    return rows.map((r) => _fromLocalMap(r)).toList();
  }

  // ─── CREAR CONSULTA ──────────────────────────────────────────────
  /// Registra una nueva consulta médica.
  ///
  /// Flujo offline:
  /// - Genera un ID temporal negativo (basado en timestamp) para
  ///   identificar el registro localmente antes de sincronizar.
  /// - Guarda el registro en SQLite con pendingAction = 'create'.
  /// - Agrega la operación a la sync_queue para enviarla a la API
  ///   cuando regrese internet.
  Future<void> createConsulta({
    required DateTime fecha,
    int? doctorId,
    String? motivo,
    String? sintomas,
    String? diagnostico,
    String? notas,
  }) async {
    final payload = jsonEncode({
      'fecha': fecha.toIso8601String(),
      'doctorId': doctorId,
      'motivo': motivo,
      'sintomas': sintomas,
      'diagnostico': diagnostico,
      'notas': notas,
    });

    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConstants.consultas),
        headers: headers,
        body: payload,
      );
      if (response.statusCode == 201) {
        // Refrescar cache local con el registro recién creado en el servidor
        await getConsultas();
        return;
      }
      throw Exception('Error al crear consulta');
    }

    // Sin internet — guardar localmente con ID temporal negativo
    final tempId = -(DateTime.now().millisecondsSinceEpoch);
    // Buscar nombre del doctor en cache local para mostrarlo en la UI
    final doctorRow = doctorId != null
        ? await _db.getById('doctores', doctorId)
        : null;
    await _db.upsert('consultas', {
      'id': tempId,
      'doctorId': doctorId,
      'doctorNombre': doctorRow?['nombre'] ?? '',
      'fechaConsulta': fecha.toIso8601String(),
      'sintomas': sintomas,
      'diagnostico': diagnostico,
      'observaciones': notas,
      'pendingAction': 'create',
      'updatedAt': DateTime.now().toIso8601String(),
    });
    // Encolar para sincronizar cuando regrese internet
    await _db.addToSyncQueue(
      entity: 'consultas',
      action: 'create',
      entityId: tempId,
      payload: payload,
    );
  }

  // ─── ACTUALIZAR CONSULTA ─────────────────────────────────────────
  /// Actualiza los datos de una consulta existente.
  ///
  /// Lógica de pendingAction offline:
  /// - Si el registro tiene pendingAction = 'create' (nunca se sincronizó),
  ///   mantiene 'create' para que al sincronizar se envíe como POST, no PUT.
  /// - Si ya existía en el servidor, marca como 'update' para enviar PUT.
  Future<void> updateConsulta({
    required int id,
    required DateTime fecha,
    int? doctorId,
    String? motivo,
    String? sintomas,
    String? diagnostico,
    String? notas,
  }) async {
    final payload = jsonEncode({
      'fecha': fecha.toIso8601String(),
      'doctorId': doctorId,
      'motivo': motivo,
      'sintomas': sintomas,
      'diagnostico': diagnostico,
      'notas': notas,
    });

    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConstants.consultas}/$id'),
        headers: headers,
        body: payload,
      );
      if (response.statusCode == 204) {
        // Refrescar cache local
        await getConsultas();
        return;
      }
      throw Exception('Error al actualizar consulta');
    }

    // Sin internet — actualizar en SQLite y encolar
    final existing = await _db.getById('consultas', id);
    final doctorRow = doctorId != null
        ? await _db.getById('doctores', doctorId)
        : null;
    await _db.update('consultas', {
      'doctorId': doctorId,
      'doctorNombre': doctorRow?['nombre'] ?? existing?['doctorNombre'] ?? '',
      'fechaConsulta': fecha.toIso8601String(),
      'sintomas': sintomas,
      'diagnostico': diagnostico,
      'observaciones': notas,
      // Si nunca se sincronizó conserva 'create', si ya existe en servidor marca 'update'
      'pendingAction': existing?['pendingAction'] == 'create'
          ? 'create'
          : 'update',
      'updatedAt': DateTime.now().toIso8601String(),
    }, id);
    await _db.addToSyncQueue(
      entity: 'consultas',
      action: 'update',
      entityId: id,
      payload: payload,
    );
  }

  // ─── ELIMINAR CONSULTA ───────────────────────────────────────────
  /// Elimina una consulta del historial.
  ///
  /// Lógica especial offline:
  /// - Si el registro tiene pendingAction = 'create', significa que nunca
  ///   llegó al servidor, así que se elimina directo de SQLite sin encolar.
  /// - Si ya existe en el servidor, se marca con pendingAction = 'delete'
  ///   y se encola para eliminarlo en el servidor al sincronizar.
  Future<void> deleteConsulta(int id) async {
    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.consultas}/$id'),
        headers: headers,
      );
      if (response.statusCode == 204) {
        // Eliminar también del cache local
        await _db.delete('consultas', id);
        return;
      }
      throw Exception('Error al eliminar consulta');
    }

    // Sin internet — revisar si el registro existe solo localmente
    final existing = await _db.getById('consultas', id);
    if (existing?['pendingAction'] == 'create') {
      // Nunca llegó al servidor, eliminar directo sin encolar
      await _db.delete('consultas', id);
    } else {
      // Ya existe en el servidor, marcar para eliminar al sincronizar
      await _db.update('consultas', {
        'pendingAction': 'delete',
        'updatedAt': DateTime.now().toIso8601String(),
      }, id);
      await _db.addToSyncQueue(
        entity: 'consultas',
        action: 'delete',
        entityId: id,
        payload: null,
      );
    }
  }

  // ─── OBTENER DOCTORES ────────────────────────────────────────────
  /// Obtiene la lista de doctores registrados por el usuario.
  /// Se usa principalmente en el formulario de nueva consulta
  /// para seleccionar qué doctor atendió al paciente.
  ///
  /// Sigue el mismo patrón: API → cache SQLite → fallback local.
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
            doctores
                .map(
                  (d) => {
                    'id': d.id,
                    'nombre': d.nombre,
                    'especialidad': d.especialidad,
                    'consultorio': d.consultorio,
                    'isActive': d.activo ? 1 : 0,
                    'pendingAction': null,
                    'updatedAt': DateTime.now().toIso8601String(),
                  },
                )
                .toList(),
          );
          return doctores;
        }
      } catch (_) {
        // Caer al cache local si hay error de red
      }
    }
    // Sin internet — leer doctores del cache local
    final rows = await _db.getAll('doctores');
    return rows
        .where((r) => r['isActive'] == 1)
        .map(
          (r) => DoctorModel(
            id: r['id'],
            nombre: r['nombre'] ?? '',
            especialidad: r['especialidad'],
            consultorio: r['consultorio'],
            activo: true,
          ),
        )
        .toList();
  }

  // ─── CREAR DOCTOR ────────────────────────────────────────────────
  /// Registra un nuevo doctor en el directorio del usuario.
  /// Este método existe aquí porque el formulario de consulta
  /// permite agregar un doctor nuevo en el mismo flujo.
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
        // Refrescar cache de doctores
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
    await _db.addToSyncQueue(
      entity: 'doctores',
      action: 'create',
      entityId: tempId,
      payload: payload,
    );
  }

  // ─── HELPERS LOCALES ─────────────────────────────────────────────

  /// Convierte un ConsultaModel a un Map compatible con SQLite.
  /// SQLite no tiene tipo DateTime nativo, por eso las fechas
  /// se guardan como String en formato ISO 8601.
  /// Nota: en SQLite usamos 'fechaConsulta' y 'observaciones' como
  /// nombres de columna internos, distintos a los campos del modelo
  /// Dart que son 'fecha' y 'notas'.
  Map<String, dynamic> _toLocalMap(ConsultaModel c) => {
    'id': c.id,
    'doctorId': c.doctorId,
    'doctorNombre': c.doctorNombre,
    'fechaConsulta': c.fecha.toIso8601String(), // modelo usa 'fecha'
    'sintomas': c.sintomas,
    'diagnostico': c.diagnostico,
    'observaciones': c.notas, // modelo usa 'notas'
    'pendingAction': null,
    'updatedAt': c.createdAt.toIso8601String(),
  };

  /// Convierte un row de SQLite a ConsultaModel.
  /// Mapea los nombres de columna SQLite a los campos del modelo Dart.
  /// Usa valores por defecto seguros para campos que podrían ser null
  /// en registros creados offline antes de sincronizar.
  ConsultaModel _fromLocalMap(Map<String, dynamic> r) => ConsultaModel(
    id: r['id'],
    doctorId: r['doctorId'],
    doctorNombre: r['doctorNombre'] ?? '',
    fecha:
        r['fechaConsulta'] !=
            null // columna SQLite → campo 'fecha'
        ? DateTime.parse(r['fechaConsulta'])
        : DateTime.now(),
    sintomas: r['sintomas'],
    diagnostico: r['diagnostico'],
    notas: r['observaciones'], // columna SQLite → campo 'notas'
    createdAt: r['updatedAt'] != null
        ? DateTime.parse(r['updatedAt'])
        : DateTime.now(),
    recetas: const [],
  );
}
