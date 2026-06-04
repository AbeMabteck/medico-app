import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'connectivity_service.dart';
import 'inventario_service.dart';
import 'consulta_service.dart';
import 'doctor_service.dart';
import 'tratamiento_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _db = DatabaseService();
  final _connectivity = ConnectivityService();
  final _authService = AuthService();

  /// Flag para evitar que se ejecuten múltiples sincronizaciones
  /// al mismo tiempo si el usuario recupera internet varias veces seguidas.
  bool _isSyncing = false;

  /// Construye los headers necesarios para cada request a la API.
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─── INICIAR LISTENER DE CONECTIVIDAD ────────────────────────────
  /// Inicia el listener que detecta cuando el dispositivo recupera internet.
  /// Se llama una sola vez al arrancar la app en main.dart.
  ///
  /// Cada vez que el dispositivo pasa de offline a online, dispara
  /// syncPendingItems() automáticamente para enviar todo lo que
  /// el usuario hizo sin conexión.
  void startConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        // Pequeño delay para asegurar que la conexión esté estable
        Future.delayed(const Duration(seconds: 2), () => syncPendingItems());
      }
    });
  }

  // ─── SINCRONIZAR ITEMS PENDIENTES ────────────────────────────────
  /// Procesa todos los items en la sync_queue y los envía a la API.
  ///
  /// Flujo:
  /// 1. Verifica que haya internet y que no esté ya sincronizando.
  /// 2. Obtiene todos los items pendientes ordenados por fecha de creación
  ///    (FIFO — primero en entrar, primero en salir).
  /// 3. Por cada item, ejecuta la operación correspondiente en la API.
  /// 4. Si la operación es exitosa, elimina el item de la queue.
  /// 5. Si falla, lo deja en la queue para reintentar después.
  /// 6. Al terminar, refresca el cache local con los datos del servidor.
  Future<void> syncPendingItems() async {
    // Evitar sincronizaciones simultáneas
    if (_isSyncing) return;
    if (!await _connectivity.isOnline()) return;

    _isSyncing = true;

    try {
      final pendingItems = await _db.getPendingSyncItems();

      if (pendingItems.isEmpty) {
        _isSyncing = false;
        return;
      }

      for (final item in pendingItems) {
        try {
          await _processSyncItem(item);
          // Si el item se procesó correctamente, eliminarlo de la queue
          await _db.removeSyncItem(item['id']);
        } catch (e) {
          // Si falla este item, continuar con el siguiente
          // Se reintentará en la próxima sincronización
          continue;
        }
      }

      // Refrescar todo el cache local con los datos actualizados del servidor
      await _refreshAllCaches();
    } finally {
      _isSyncing = false;
    }
  }

  // ─── PROCESAR UN ITEM DE LA QUEUE ────────────────────────────────
  /// Ejecuta la operación pendiente de un item en la API.
  ///
  /// Cada item tiene:
  /// - entity: qué tabla afecta ('inventario', 'consultas', 'doctores', etc.)
  /// - action: qué operación hacer ('create', 'update', 'delete', etc.)
  /// - entityId: el ID del registro afectado
  /// - payload: el JSON con los datos a enviar (null para delete/cancelar)
  Future<void> _processSyncItem(Map<String, dynamic> item) async {
    final entity = item['entity'] as String;
    final action = item['action'] as String;
    final entityId = item['entityId'] as int?;
    final payload = item['payload'] as String?;
    final headers = await _getHeaders();

    switch (entity) {
      // ── INVENTARIO ──────────────────────────────────────────────
      case 'inventario':
        await _syncInventario(action, entityId, payload, headers);
        break;

      // ── CATÁLOGO ────────────────────────────────────────────────
      case 'catalogo':
        await _syncCatalogo(action, payload, headers);
        break;

      // ── CONSULTAS ───────────────────────────────────────────────
      case 'consultas':
        await _syncConsultas(action, entityId, payload, headers);
        break;

      // ── DOCTORES ────────────────────────────────────────────────
      case 'doctores':
        await _syncDoctores(action, entityId, payload, headers);
        break;

      // ── TRATAMIENTOS ────────────────────────────────────────────
      case 'tratamientos':
        await _syncTratamientos(action, entityId, payload, headers);
        break;

      // ── TOMAS ───────────────────────────────────────────────────
      case 'tomas':
        await _syncTomas(action, entityId, payload, headers);
        break;
    }
  }

  // ─── SYNC INVENTARIO ─────────────────────────────────────────────
  /// Sincroniza operaciones pendientes del inventario de medicamentos.
  /// Los IDs negativos son temporales (creados offline) — para 'create'
  /// el servidor asigna el ID real y se actualiza el cache local.
  Future<void> _syncInventario(
    String action,
    int? entityId,
    String? payload,
    Map<String, String> headers,
  ) async {
    switch (action) {
      case 'create':
        // Enviar al servidor y obtener el ID real asignado
        final response = await http.post(
          Uri.parse(ApiConstants.inventario),
          headers: headers,
          body: payload,
        );
        if (response.statusCode == 201) {
          // Eliminar el registro temporal del cache local
          // El ID real llegará al refrescar el cache después del sync
          if (entityId != null) await _db.delete('inventario', entityId);
        }
        break;

      case 'update':
        if (entityId == null) break;
        await http.put(
          Uri.parse('${ApiConstants.inventario}/$entityId'),
          headers: headers,
          body: payload,
        );
        break;

      case 'delete':
        if (entityId == null) break;
        await http.delete(
          Uri.parse('${ApiConstants.inventario}/$entityId'),
          headers: headers,
        );
        break;
    }
  }

  // ─── SYNC CATÁLOGO ───────────────────────────────────────────────
  /// Sincroniza medicamentos nuevos agregados al catálogo offline.
  Future<void> _syncCatalogo(
    String action,
    String? payload,
    Map<String, String> headers,
  ) async {
    if (action == 'create') {
      await http.post(
        Uri.parse(ApiConstants.inventarioCatalogo),
        headers: headers,
        body: payload,
      );
    }
  }

  // ─── SYNC CONSULTAS ──────────────────────────────────────────────
  /// Sincroniza operaciones pendientes del historial clínico.
  Future<void> _syncConsultas(
    String action,
    int? entityId,
    String? payload,
    Map<String, String> headers,
  ) async {
    switch (action) {
      case 'create':
        final response = await http.post(
          Uri.parse(ApiConstants.consultas),
          headers: headers,
          body: payload,
        );
        if (response.statusCode == 201 && entityId != null) {
          // Eliminar el registro temporal — el real llega al refrescar cache
          await _db.delete('consultas', entityId);
        }
        break;

      case 'update':
        if (entityId == null) break;
        await http.put(
          Uri.parse('${ApiConstants.consultas}/$entityId'),
          headers: headers,
          body: payload,
        );
        break;

      case 'delete':
        if (entityId == null) break;
        await http.delete(
          Uri.parse('${ApiConstants.consultas}/$entityId'),
          headers: headers,
        );
        break;
    }
  }

  // ─── SYNC DOCTORES ───────────────────────────────────────────────
  /// Sincroniza operaciones pendientes del directorio de doctores.
  Future<void> _syncDoctores(
    String action,
    int? entityId,
    String? payload,
    Map<String, String> headers,
  ) async {
    switch (action) {
      case 'create':
        final response = await http.post(
          Uri.parse(ApiConstants.doctores),
          headers: headers,
          body: payload,
        );
        if (response.statusCode == 201 && entityId != null) {
          await _db.delete('doctores', entityId);
        }
        break;

      case 'update':
        if (entityId == null) break;
        await http.put(
          Uri.parse('${ApiConstants.doctores}/$entityId'),
          headers: headers,
          body: payload,
        );
        break;

      case 'delete':
        if (entityId == null) break;
        await http.delete(
          Uri.parse('${ApiConstants.doctores}/$entityId'),
          headers: headers,
        );
        break;
    }
  }

  // ─── SYNC TRATAMIENTOS ───────────────────────────────────────────
  /// Sincroniza operaciones pendientes de tratamientos.
  /// Para 'create', el servidor genera todas las tomas automáticamente,
  /// por lo que las tomas temporales locales se eliminan y se reemplazan
  /// con las del servidor al refrescar el cache.
  Future<void> _syncTratamientos(
    String action,
    int? entityId,
    String? payload,
    Map<String, String> headers,
  ) async {
    switch (action) {
      case 'create':
        final response = await http.post(
          Uri.parse(ApiConstants.tratamientos),
          headers: headers,
          body: payload,
        );
        if (response.statusCode == 201 && entityId != null) {
          // Eliminar tratamiento temporal y sus tomas temporales
          await _db.delete('tratamientos', entityId);
          final database = await _db.db;
          await database.delete(
            'tomas',
            where: 'tratamientoId = ?',
            whereArgs: [entityId],
          );
        }
        break;

      case 'cancelar':
        if (entityId == null) break;
        await http.put(
          Uri.parse('${ApiConstants.tratamientos}/$entityId/cancelar'),
          headers: headers,
        );
        break;
    }
  }

  // ─── SYNC TOMAS ──────────────────────────────────────────────────
  /// Sincroniza confirmaciones y omisiones de tomas.
  /// Confirmar una toma también descuenta el inventario en el servidor.
  Future<void> _syncTomas(
    String action,
    int? entityId,
    String? payload,
    Map<String, String> headers,
  ) async {
    if (entityId == null) return;

    switch (action) {
      case 'confirmar':
        // Confirmar la toma — el servidor descuenta inventario automáticamente
        await http.post(
          Uri.parse('${ApiConstants.tratamientos}/tomas/$entityId/confirmar'),
          headers: headers,
          body: payload,
        );
        break;

      case 'omitir':
        await http.post(
          Uri.parse('${ApiConstants.tratamientos}/tomas/$entityId/omitir'),
          headers: headers,
        );
        break;
    }
  }

  // ─── REFRESCAR TODOS LOS CACHES ──────────────────────────────────
  /// Después de sincronizar, refresca el cache local con los datos
  /// actualizados del servidor para que la UI muestre información correcta.
  ///
  /// Se ejecuta al final de cada sincronización exitosa.
  /// Los servicios individuales ya saben cómo guardar en SQLite,
  /// así que simplemente los llamamos para que hagan su trabajo.
  Future<void> _refreshAllCaches() async {
    try {
      await Future.wait([
        InventarioService().getInventario(),
        InventarioService().getCatalogo(),
        ConsultaService().getConsultas(),
        DoctorService().getDoctores(),
        TratamientoService().getTratamientos(),
      ]);
    } catch (_) {
      // Si algún refresh falla, no es crítico — el cache local
      // ya tiene datos suficientes para seguir funcionando
    }
  }

  // ─── VERIFICAR SI HAY PENDIENTES ─────────────────────────────────
  /// Retorna true si hay operaciones pendientes de sincronizar.
  /// Se puede usar en la UI para mostrar un indicador visual
  /// de que hay cambios offline sin sincronizar.
  Future<bool> hasPendingItems() async {
    final items = await _db.getPendingSyncItems();
    return items.isNotEmpty;
  }

  /// Retorna el número exacto de operaciones pendientes.
  /// Útil para mostrar un badge o contador en la UI.
  Future<int> getPendingCount() async {
    final items = await _db.getPendingSyncItems();
    return items.length;
  }
}
