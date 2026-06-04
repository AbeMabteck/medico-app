import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/tratamiento_model.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'connectivity_service.dart';

class TratamientoService {
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

  // ─── OBTENER TODOS LOS TRATAMIENTOS ─────────────────────────────
  /// Obtiene la lista completa de tratamientos del usuario
  /// (activos, completados y cancelados).
  ///
  /// Flujo:
  /// - Con internet: llama a la API, guarda en SQLite y retorna.
  /// - Sin internet: lee directamente de SQLite con los datos del último sync.
  /// - Si la API falla, cae al fallback de SQLite para no dejar al usuario sin datos.
  Future<List<TratamientoModel>> getTratamientos() async {
    if (await _connectivity.isOnline()) {
      try {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse(ApiConstants.tratamientos),
          headers: headers,
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          final tratamientos = data
              .map((t) => TratamientoModel.fromJson(t))
              .toList();
          // Persistir en SQLite para tener disponible offline
          await _db.upsertAll(
            'tratamientos',
            tratamientos.map((t) => _tratamientoToLocalMap(t)).toList(),
          );
          return tratamientos;
        }
      } catch (_) {
        // Si hay error de red o timeout, caemos al cache local
      }
    }
    // Sin internet o error — retornar datos del cache local
    final rows = await _db.getAll('tratamientos');
    return rows.map((r) => _tratamientoFromLocalMap(r)).toList();
  }

  // ─── OBTENER TRATAMIENTOS ACTIVOS ────────────────────────────────
  /// Obtiene solo los tratamientos con status = 'activo'.
  /// Se usa en el Dashboard y en la pantalla principal de tratamientos
  /// para mostrar los tratamientos en curso.
  ///
  /// Offline: filtra directamente del cache local por status 'activo'.
  Future<List<TratamientoModel>> getTratamientosActivos() async {
    if (await _connectivity.isOnline()) {
      try {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse(ApiConstants.tratamientosActivos),
          headers: headers,
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          final tratamientos = data
              .map((t) => TratamientoModel.fromJson(t))
              .toList();
          // Actualizar cache local con los activos
          await _db.upsertAll(
            'tratamientos',
            tratamientos.map((t) => _tratamientoToLocalMap(t)).toList(),
          );
          return tratamientos;
        }
      } catch (_) {
        // Caer al cache local si hay error de red
      }
    }
    // Sin internet — filtrar activos del cache local
    final rows = await _db.getAll('tratamientos');
    return rows
        .where((r) => r['status'] == 'activo')
        .map((r) => _tratamientoFromLocalMap(r))
        .toList();
  }

  // ─── OBTENER TOMAS DE UN TRATAMIENTO ────────────────────────────
  /// Obtiene todas las tomas programadas de un tratamiento específico.
  /// Se usa en la pantalla de detalle para mostrar el calendario de tomas
  /// con su estado (pendiente, tomada, omitida).
  ///
  /// Offline: lee las tomas del cache local filtradas por tratamientoId.
  Future<List<TomaModel>> getTomas(int tratamientoId) async {
    if (await _connectivity.isOnline()) {
      try {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse('${ApiConstants.tratamientos}/$tratamientoId/tomas'),
          headers: headers,
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          final tomas = data.map((t) => TomaModel.fromJson(t)).toList();
          // Persistir tomas en SQLite para acceso offline
          await _db.upsertAll(
            'tomas',
            tomas.map((t) => _tomaToLocalMap(t)).toList(),
          );
          return tomas;
        }
      } catch (_) {
        // Caer al cache local si hay error de red
      }
    }
    // Sin internet — leer tomas del cache local filtradas por tratamiento
    final database = await _db.db;
    final rows = await database.query(
      'tomas',
      where: 'tratamientoId = ?',
      whereArgs: [tratamientoId],
      orderBy: 'horaProgramada ASC',
    );
    return rows.map((r) => _tomaFromLocalMap(r)).toList();
  }

  // ─── OBTENER PRÓXIMAS TOMAS ──────────────────────────────────────
  /// Obtiene las tomas programadas para las próximas 24 horas.
  /// Se usa en el Dashboard para mostrar el resumen del día
  /// y recordarle al usuario qué medicamentos debe tomar.
  ///
  /// Offline: filtra las tomas pendientes del cache local
  /// cuya horaProgramada esté dentro de las próximas 24 horas.
  Future<List<TomaModel>> getProximasTomas() async {
    if (await _connectivity.isOnline()) {
      try {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse(ApiConstants.tomasProximas),
          headers: headers,
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          final tomas = data.map((t) => TomaModel.fromJson(t)).toList();
          // Actualizar cache local con las próximas tomas
          await _db.upsertAll(
            'tomas',
            tomas.map((t) => _tomaToLocalMap(t)).toList(),
          );
          return tomas;
        }
      } catch (_) {
        // Caer al cache local si hay error de red
      }
    }
    // Sin internet — calcular próximas tomas desde el cache local
    // Filtra tomas pendientes dentro de las próximas 24 horas
    final ahora = DateTime.now();
    final limite = ahora.add(const Duration(hours: 24));
    final database = await _db.db;
    final rows = await database.query(
      'tomas',
      where: 'status = ? AND horaProgramada >= ? AND horaProgramada <= ?',
      whereArgs: [
        'pendiente',
        ahora.toIso8601String(),
        limite.toIso8601String(),
      ],
      orderBy: 'horaProgramada ASC',
    );
    return rows.map((r) => _tomaFromLocalMap(r)).toList();
  }

  // ─── CREAR TRATAMIENTO ───────────────────────────────────────────
  /// Crea un nuevo tratamiento y genera automáticamente todas las tomas
  /// programadas según la frecuencia y duración indicadas.
  ///
  /// Flujo offline:
  /// - Guarda el tratamiento en SQLite con pendingAction = 'create'.
  /// - Genera las tomas localmente con el mismo algoritmo que el servidor
  ///   (cada frecuenciaHoras a partir de fechaInicio por duracionDias días).
  /// - Encola todo para sincronizar cuando regrese internet.
  /// - Retorna un Map con el ID temporal para que la UI pueda navegar al detalle.
  Future<Map<String, dynamic>> createTratamiento({
    required int medicamentoId,
    required String dosis,
    required int frecuenciaHoras,
    required int duracionDias,
    required DateTime fechaInicio,
    int? recetaId,
    String? notas,
  }) async {
    final payload = jsonEncode({
      'medicamentoId': medicamentoId,
      'dosis': dosis,
      'frecuenciaHoras': frecuenciaHoras,
      'duracionDias': duracionDias,
      'fechaInicio': fechaInicio.toIso8601String(),
      'recetaId': recetaId,
      'notas': notas,
    });

    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConstants.tratamientos),
        headers: headers,
        body: payload,
      );
      if (response.statusCode == 201) {
        // Refrescar cache local con el tratamiento y tomas recién creados
        await getTratamientos();
        return jsonDecode(response.body);
      }
      throw Exception('Error al crear tratamiento');
    }

    // Sin internet — crear tratamiento local con ID temporal negativo
    final tempId = -(DateTime.now().millisecondsSinceEpoch);
    final fechaFin = fechaInicio.add(Duration(days: duracionDias));

    // Buscar nombre del medicamento en cache local para mostrarlo en la UI
    final catalogoRow = await _db.getById('catalogo', medicamentoId);
    final medicamentoNombre = catalogoRow?['nombre'] ?? 'Medicamento';

    await _db.upsert('tratamientos', {
      'id': tempId,
      'medicamentoId': medicamentoId,
      'medicamentoNombre': medicamentoNombre,
      'dosis': dosis,
      'frecuenciaHoras': frecuenciaHoras,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'duracionDias': duracionDias,
      'notas': notas,
      'status': 'activo',
      'totalTomas': 0,
      'tomasTomadas': 0,
      'tomasPendientes': 0,
      'pendingAction': 'create',
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Generar tomas localmente con el mismo algoritmo del servidor:
    // cada frecuenciaHoras a partir de fechaInicio hasta fechaFin
    DateTime fechaToma = fechaInicio;
    int totalTomas = 0;
    while (fechaToma.isBefore(fechaFin)) {
      final tomaId = -(DateTime.now().microsecondsSinceEpoch + totalTomas);
      await _db.upsert('tomas', {
        'id': tomaId,
        'tratamientoId': tempId,
        'medicamentoNombre': medicamentoNombre,
        'dosis': dosis,
        'horaProgramada': fechaToma.toIso8601String(),
        'horaTomada': null,
        'status': 'pendiente',
        'descontadoInventario': 0,
        'pendingAction': 'create',
      });
      fechaToma = fechaToma.add(Duration(hours: frecuenciaHoras));
      totalTomas++;
    }

    // Encolar el tratamiento completo para sincronizar con el servidor
    await _db.addToSyncQueue(
      entity: 'tratamientos',
      action: 'create',
      entityId: tempId,
      payload: payload,
    );

    return {'id': tempId, 'medicamentoNombre': medicamentoNombre};
  }

  // ─── CONFIRMAR TOMA ──────────────────────────────────────────────
  /// Confirma que el usuario tomó su medicamento.
  /// Esto descuenta automáticamente una unidad del inventario en el servidor.
  ///
  /// Flujo offline:
  /// - Actualiza el status de la toma a 'tomada' en SQLite.
  /// - Encola la confirmación para procesarla en el servidor al sincronizar.
  /// - Nota: el descuento de inventario ocurrirá cuando se sincronice,
  ///   no de forma inmediata en modo offline.
  Future<void> confirmarToma(int tomaId) async {
    final ahora = DateTime.now().toIso8601String();

    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.tratamientos}/tomas/$tomaId/confirmar'),
        headers: headers,
        body: jsonEncode({'horaTomada': ahora}),
      );
      if (response.statusCode == 200) {
        // Actualizar status en cache local
        await _db.update('tomas', {
          'status': 'tomada',
          'horaTomada': ahora,
          'descontadoInventario': 1,
          'pendingAction': null,
        }, tomaId);
        return;
      }
      throw Exception('Error al confirmar toma');
    }

    // Sin internet — marcar como tomada en SQLite y encolar
    // El descuento de inventario se procesará al sincronizar
    await _db.update('tomas', {
      'status': 'tomada',
      'horaTomada': ahora,
      'descontadoInventario': 0,
      'pendingAction': 'confirmar',
    }, tomaId);
    await _db.addToSyncQueue(
      entity: 'tomas',
      action: 'confirmar',
      entityId: tomaId,
      payload: jsonEncode({'horaTomada': ahora}),
    );
  }

  // ─── OMITIR TOMA ─────────────────────────────────────────────────
  /// Registra que el usuario no pudo tomar el medicamento en el horario
  /// programado. No modifica el inventario.
  ///
  /// Flujo offline:
  /// - Actualiza el status de la toma a 'omitida' en SQLite.
  /// - Encola la operación para sincronizar con el servidor.
  Future<void> omitirToma(int tomaId) async {
    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.tratamientos}/tomas/$tomaId/omitir'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        // Actualizar status en cache local
        await _db.update('tomas', {
          'status': 'omitida',
          'pendingAction': null,
        }, tomaId);
        return;
      }
      throw Exception('Error al omitir toma');
    }

    // Sin internet — marcar como omitida en SQLite y encolar
    await _db.update('tomas', {
      'status': 'omitida',
      'pendingAction': 'omitir',
    }, tomaId);
    await _db.addToSyncQueue(
      entity: 'tomas',
      action: 'omitir',
      entityId: tomaId,
      payload: null,
    );
  }

  // ─── CANCELAR TRATAMIENTO ────────────────────────────────────────
  /// Cancela un tratamiento activo antes de que termine.
  /// Las tomas futuras ya no se ejecutarán pero el historial
  /// de tomas confirmadas se conserva.
  ///
  /// Flujo offline:
  /// - Actualiza el status del tratamiento a 'cancelado' en SQLite.
  /// - Encola la operación para sincronizar con el servidor.
  Future<void> cancelarTratamiento(int id) async {
    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConstants.tratamientos}/$id/cancelar'),
        headers: headers,
      );
      if (response.statusCode == 204 || response.statusCode == 200) {
        // Actualizar status en cache local
        await _db.update('tratamientos', {
          'status': 'cancelado',
          'pendingAction': null,
          'updatedAt': DateTime.now().toIso8601String(),
        }, id);
        return;
      }
      throw Exception('Error al cancelar tratamiento');
    }

    // Sin internet — marcar como cancelado en SQLite y encolar
    await _db.update('tratamientos', {
      'status': 'cancelado',
      'pendingAction': 'cancelar',
      'updatedAt': DateTime.now().toIso8601String(),
    }, id);
    await _db.addToSyncQueue(
      entity: 'tratamientos',
      action: 'cancelar',
      entityId: id,
      payload: null,
    );
  }

  // ─── HELPERS LOCALES ─────────────────────────────────────────────

  /// Convierte un TratamientoModel a un Map compatible con SQLite.
  /// Las fechas se guardan como String ISO 8601 porque SQLite
  /// no tiene tipo DateTime nativo.
  Map<String, dynamic> _tratamientoToLocalMap(TratamientoModel t) => {
    'id': t.id,
    'medicamentoId': t.medicamentoId,
    'medicamentoNombre': t.medicamentoNombre,
    'dosis': t.dosis,
    'frecuenciaHoras': t.frecuenciaHoras,
    'fechaInicio': t.fechaInicio.toIso8601String(),
    'fechaFin': t.fechaFin.toIso8601String(),
    'duracionDias': t.duracionDias,
    'notas': t.notas,
    'status': t.status,
    'totalTomas': t.totalTomas,
    'tomasTomadas': t.tomasTomadas,
    'tomasPendientes': t.tomasPendientes,
    'pendingAction': null,
    'updatedAt': DateTime.now().toIso8601String(),
  };

  /// Convierte un row de SQLite a TratamientoModel.
  /// Usa valores por defecto seguros para campos que podrían ser null
  /// en registros creados offline antes de sincronizar.
  TratamientoModel _tratamientoFromLocalMap(Map<String, dynamic> r) =>
      TratamientoModel(
        id: r['id'],
        medicamentoId: r['medicamentoId'] ?? 0,
        medicamentoNombre: r['medicamentoNombre'] ?? '',
        dosis: r['dosis'] ?? '',
        frecuenciaHoras: r['frecuenciaHoras'] ?? 8,
        fechaInicio: r['fechaInicio'] != null
            ? DateTime.parse(r['fechaInicio'])
            : DateTime.now(),
        fechaFin: r['fechaFin'] != null
            ? DateTime.parse(r['fechaFin'])
            : DateTime.now(),
        duracionDias: r['duracionDias'] ?? 1,
        notas: r['notas'],
        status: r['status'] ?? 'activo',
        totalTomas: r['totalTomas'] ?? 0,
        tomasTomadas: r['tomasTomadas'] ?? 0,
        tomasPendientes: r['tomasPendientes'] ?? 0,
        createdAt: r['updatedAt'] != null
            ? DateTime.parse(r['updatedAt'])
            : DateTime.now(),
      );

  /// Convierte un TomaModel a un Map compatible con SQLite.
  /// El booleano descontadoInventario se guarda como entero (1/0)
  /// porque SQLite no tiene tipo booleano nativo.
  Map<String, dynamic> _tomaToLocalMap(TomaModel t) => {
    'id': t.id,
    'tratamientoId': t.tratamientoId,
    'medicamentoNombre': t.medicamentoNombre,
    'dosis': t.dosis,
    'horaProgramada': t.horaProgramada.toIso8601String(),
    'horaTomada': t.horaTomada?.toIso8601String(),
    'status': t.status,
    'descontadoInventario': t.descontadoInventario ? 1 : 0,
    'pendingAction': null,
  };

  /// Convierte un row de SQLite a TomaModel.
  /// Usa valores por defecto seguros para campos que podrían ser null
  /// en registros creados offline antes de sincronizar.
  TomaModel _tomaFromLocalMap(Map<String, dynamic> r) => TomaModel(
    id: r['id'],
    tratamientoId: r['tratamientoId'],
    medicamentoNombre: r['medicamentoNombre'] ?? '',
    dosis: r['dosis'] ?? '',
    horaProgramada: r['horaProgramada'] != null
        ? DateTime.parse(r['horaProgramada'])
        : DateTime.now(),
    horaTomada: r['horaTomada'] != null
        ? DateTime.tryParse(r['horaTomada'])
        : null,
    status: r['status'] ?? 'pendiente',
    descontadoInventario: r['descontadoInventario'] == 1,
  );
}
