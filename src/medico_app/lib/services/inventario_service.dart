import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/inventario_model.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'connectivity_service.dart';

class InventarioService {
  final _authService = AuthService();
  final _db = DatabaseService();
  final _connectivity = ConnectivityService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─── OBTENER INVENTARIO ──────────────────────────────────────────

  Future<List<InventarioModel>> getInventario() async {
    if (await _connectivity.isOnline()) {
      try {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse(ApiConstants.inventario),
          headers: headers,
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          final items = data.map((i) => InventarioModel.fromJson(i)).toList();
          // Guardar en local
          await _db.upsertAll(
            'inventario',
            items.map((i) => _toLocalMap(i)).toList(),
          );
          return items;
        }
      } catch (_) {}
    }
    // Sin internet o error — leer de SQLite
    final rows = await _db.getAll('inventario');
    return rows.map((r) => _fromLocalMap(r)).toList();
  }

  // ─── OBTENER STOCK BAJO ──────────────────────────────────────────

  Future<List<InventarioModel>> getStockBajo() async {
    final todos = await getInventario();
    return todos.where((i) => i.stockBajo).toList();
  }

  // ─── OBTENER CATÁLOGO ────────────────────────────────────────────

  Future<List<MedicamentoCatalogoModel>> getCatalogo() async {
    if (await _connectivity.isOnline()) {
      try {
        final headers = await _getHeaders();
        final response = await http.get(
          Uri.parse(ApiConstants.inventarioCatalogo),
          headers: headers,
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          final items = data
              .map((m) => MedicamentoCatalogoModel.fromJson(m))
              .toList();
          // Guardar en local
          await _db.upsertAll(
            'catalogo',
            items
                .map(
                  (m) => {
                    'id': m.id,
                    'nombre': m.nombre,
                    'nombreGenerico': m.nombreGenerico,
                    'presentacion': m.presentacion,
                    'concentracion': m.concentracion,
                  },
                )
                .toList(),
          );
          return items;
        }
      } catch (_) {}
    }
    // Sin internet — leer catálogo local
    final rows = await _db.getAll('catalogo');
    return rows
        .map(
          (r) => MedicamentoCatalogoModel(
            id: r['id'],
            nombre: r['nombre'],
            nombreGenerico: r['nombreGenerico'],
            presentacion: r['presentacion'],
            concentracion: r['concentracion'],
          ),
        )
        .toList();
  }

  // ─── AGREGAR AL INVENTARIO ───────────────────────────────────────

  Future<void> agregarInventario({
    required int medicamentoId,
    required int cantidadActual,
    int cantidadMinima = 5,
    String unidad = 'tabletas',
    DateTime? fechaCaducidad,
    String? lugarCompra,
    double? precio,
  }) async {
    final payload = jsonEncode({
      'medicamentoId': medicamentoId,
      'cantidadActual': cantidadActual,
      'cantidadMinima': cantidadMinima,
      'unidad': unidad,
      'fechaCaducidad': fechaCaducidad?.toIso8601String(),
      'lugarCompra': lugarCompra,
      'precio': precio,
    });

    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConstants.inventario),
        headers: headers,
        body: payload,
      );
      if (response.statusCode == 201) {
        // Refrescar cache local
        await getInventario();
        return;
      }
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al agregar medicamento');
    }

    // Sin internet — guardar local con ID temporal negativo
    final tempId = -(DateTime.now().millisecondsSinceEpoch);
    final catalogoRow = await _db.getById('catalogo', medicamentoId);
    await _db.upsert('inventario', {
      'id': tempId,
      'medicamentoId': medicamentoId,
      'medicamentoNombre': catalogoRow?['nombre'] ?? 'Medicamento',
      'medicamentoPresentacion': catalogoRow?['presentacion'],
      'medicamentoConcentracion': catalogoRow?['concentracion'],
      'cantidadActual': cantidadActual,
      'cantidadMinima': cantidadMinima,
      'unidad': unidad,
      'fechaCaducidad': fechaCaducidad?.toIso8601String(),
      'lugarCompra': lugarCompra,
      'precio': precio,
      'status': 'disponible',
      'stockBajo': cantidadActual <= cantidadMinima ? 1 : 0,
      'pendingAction': 'create',
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await _db.addToSyncQueue(
      entity: 'inventario',
      action: 'create',
      entityId: tempId,
      payload: payload,
    );
  }

  // ─── ACTUALIZAR INVENTARIO ───────────────────────────────────────

  Future<void> actualizarInventario({
    required int id,
    required int cantidadActual,
    required int cantidadMinima,
    required String unidad,
    DateTime? fechaCaducidad,
    String? lugarCompra,
    double? precio,
  }) async {
    final payload = jsonEncode({
      'cantidadActual': cantidadActual,
      'cantidadMinima': cantidadMinima,
      'unidad': unidad,
      'fechaCaducidad': fechaCaducidad?.toIso8601String(),
      'lugarCompra': lugarCompra,
      'precio': precio,
    });

    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConstants.inventario}/$id'),
        headers: headers,
        body: payload,
      );
      if (response.statusCode == 204) {
        await getInventario();
        return;
      }
      throw Exception('Error al actualizar inventario');
    }

    // Sin internet — actualizar local y encolar
    final existing = await _db.getById('inventario', id);
    await _db.update('inventario', {
      'cantidadActual': cantidadActual,
      'cantidadMinima': cantidadMinima,
      'unidad': unidad,
      'fechaCaducidad': fechaCaducidad?.toIso8601String(),
      'lugarCompra': lugarCompra,
      'precio': precio,
      'stockBajo': cantidadActual <= cantidadMinima ? 1 : 0,
      'pendingAction': existing?['pendingAction'] == 'create'
          ? 'create'
          : 'update',
      'updatedAt': DateTime.now().toIso8601String(),
    }, id);
    await _db.addToSyncQueue(
      entity: 'inventario',
      action: 'update',
      entityId: id,
      payload: payload,
    );
  }

  // ─── ACTUALIZAR CANTIDAD ─────────────────────────────────────────

  Future<void> actualizarCantidad(int id, int nuevaCantidad) async {
    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      await http.put(
        Uri.parse('${ApiConstants.inventario}/$id'),
        headers: headers,
        body: jsonEncode({'cantidadActual': nuevaCantidad}),
      );
      await getInventario();
      return;
    }
    // Sin internet — actualizar local
    final existing = await _db.getById('inventario', id);
    if (existing != null) {
      await _db.update('inventario', {
        'cantidadActual': nuevaCantidad,
        'stockBajo': nuevaCantidad <= (existing['cantidadMinima'] ?? 5) ? 1 : 0,
        'pendingAction': existing['pendingAction'] == 'create'
            ? 'create'
            : 'update',
        'updatedAt': DateTime.now().toIso8601String(),
      }, id);
      await _db.addToSyncQueue(
        entity: 'inventario',
        action: 'update',
        entityId: id,
        payload: jsonEncode({'cantidadActual': nuevaCantidad}),
      );
    }
  }

  // ─── ELIMINAR DEL INVENTARIO ─────────────────────────────────────

  Future<void> eliminarInventario(int id) async {
    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.inventario}/$id'),
        headers: headers,
      );
      if (response.statusCode == 204) {
        await _db.delete('inventario', id);
        return;
      }
      throw Exception('Error al eliminar medicamento');
    }

    // Sin internet — marcar como pendiente de eliminar
    final existing = await _db.getById('inventario', id);
    if (existing?['pendingAction'] == 'create') {
      // Si nunca se sincronizó, eliminar directo sin encolar
      await _db.delete('inventario', id);
    } else {
      await _db.update('inventario', {
        'pendingAction': 'delete',
        'updatedAt': DateTime.now().toIso8601String(),
      }, id);
      await _db.addToSyncQueue(
        entity: 'inventario',
        action: 'delete',
        entityId: id,
        payload: null,
      );
    }
  }

  // ─── AGREGAR AL CATÁLOGO ─────────────────────────────────────────

  Future<void> agregarCatalogo({
    required String nombre,
    String? nombreGenerico,
    String? presentacion,
    String? concentracion,
  }) async {
    final payload = jsonEncode({
      'nombre': nombre,
      'nombreGenerico': nombreGenerico,
      'presentacion': presentacion,
      'concentracion': concentracion,
    });

    if (await _connectivity.isOnline()) {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConstants.inventarioCatalogo),
        headers: headers,
        body: payload,
      );
      if (response.statusCode == 201) {
        await getCatalogo();
        return;
      }
    }

    // Sin internet — guardar en catálogo local con ID temporal
    final tempId = -(DateTime.now().millisecondsSinceEpoch);
    await _db.upsert('catalogo', {
      'id': tempId,
      'nombre': nombre,
      'nombreGenerico': nombreGenerico,
      'presentacion': presentacion,
      'concentracion': concentracion,
    });
    await _db.addToSyncQueue(
      entity: 'catalogo',
      action: 'create',
      entityId: tempId,
      payload: payload,
    );
  }

  // ─── HELPERS LOCALES ─────────────────────────────────────────────

  Map<String, dynamic> _toLocalMap(InventarioModel i) => {
    'id': i.id,
    'medicamentoId': i.medicamentoId,
    'medicamentoNombre': i.medicamentoNombre,
    'medicamentoPresentacion': i.medicamentoPresentacion,
    'medicamentoConcentracion': i.medicamentoConcentracion,
    'cantidadActual': i.cantidadActual,
    'cantidadMinima': i.cantidadMinima,
    'unidad': i.unidad,
    'fechaCaducidad': i.fechaCaducidad?.toIso8601String(),
    'lugarCompra': i.lugarCompra,
    'precio': i.precio,
    'status': i.status,
    'stockBajo': i.stockBajo ? 1 : 0,
    'pendingAction': null,
    'updatedAt': i.updatedAt.toIso8601String(),
  };

  InventarioModel _fromLocalMap(Map<String, dynamic> r) => InventarioModel(
    id: r['id'],
    medicamentoId: r['medicamentoId'],
    medicamentoNombre: r['medicamentoNombre'] ?? '',
    medicamentoPresentacion: r['medicamentoPresentacion'],
    medicamentoConcentracion: r['medicamentoConcentracion'],
    cantidadActual: r['cantidadActual'] ?? 0,
    cantidadMinima: r['cantidadMinima'] ?? 0,
    unidad: r['unidad'] ?? 'tabletas',
    fechaCaducidad: r['fechaCaducidad'] != null
        ? DateTime.tryParse(r['fechaCaducidad'])
        : null,
    lugarCompra: r['lugarCompra'],
    precio: r['precio']?.toDouble(),
    status: r['status'] ?? 'disponible',
    stockBajo: r['stockBajo'] == 1,
    updatedAt: r['updatedAt'] != null
        ? DateTime.parse(r['updatedAt'])
        : DateTime.now(),
  );
}
