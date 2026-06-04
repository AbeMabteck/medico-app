import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/inventario_model.dart';
import 'auth_service.dart';

class InventarioService {
  final _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtener inventario
  Future<List<InventarioModel>> getInventario() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.inventario),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((i) => InventarioModel.fromJson(i)).toList();
    }
    throw Exception('Error al obtener inventario');
  }

  // Obtener stock bajo
  Future<List<InventarioModel>> getStockBajo() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.inventarioStockBajo),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((i) => InventarioModel.fromJson(i)).toList();
    }
    throw Exception('Error al obtener stock bajo');
  }

  // Obtener catálogo
  Future<List<MedicamentoCatalogoModel>> getCatalogo() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.inventarioCatalogo),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((m) => MedicamentoCatalogoModel.fromJson(m)).toList();
    }
    throw Exception('Error al obtener catálogo');
  }

  // Agregar al inventario
  Future<void> agregarInventario({
    required int medicamentoId,
    required int cantidadActual,
    int cantidadMinima = 5,
    String unidad = 'tabletas',
    DateTime? fechaCaducidad,
    String? lugarCompra,
    double? precio,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.inventario),
      headers: headers,
      body: jsonEncode({
        'medicamentoId': medicamentoId,
        'cantidadActual': cantidadActual,
        'cantidadMinima': cantidadMinima,
        'unidad': unidad,
        'fechaCaducidad': fechaCaducidad?.toIso8601String(),
        'lugarCompra': lugarCompra,
        'precio': precio,
      }),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al agregar medicamento');
    }
  }

  // Actualizar inventario completo
  Future<void> actualizarInventario({
    required int id,
    required int cantidadActual,
    required int cantidadMinima,
    required String unidad,
    DateTime? fechaCaducidad,
    String? lugarCompra,
    double? precio,
  }) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiConstants.inventario}/$id'),
      headers: headers,
      body: jsonEncode({
        'cantidadActual': cantidadActual,
        'cantidadMinima': cantidadMinima,
        'unidad': unidad,
        'fechaCaducidad': fechaCaducidad?.toIso8601String(),
        'lugarCompra': lugarCompra,
        'precio': precio,
      }),
    );

    if (response.statusCode != 204) {
      throw Exception('Error al actualizar inventario');
    }
  }

  // Actualizar cantidad
  Future<void> actualizarCantidad(int id, int nuevaCantidad) async {
    final headers = await _getHeaders();
    await http.put(
      Uri.parse('${ApiConstants.inventario}/$id'),
      headers: headers,
      body: jsonEncode({'cantidadActual': nuevaCantidad}),
    );
  }

  // Eliminar del inventario
  Future<void> eliminarInventario(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.inventario}/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar medicamento');
    }
  }

  // Agregar al catálogo
  Future<void> agregarCatalogo({
    required String nombre,
    String? nombreGenerico,
    String? presentacion,
    String? concentracion,
  }) async {
    final headers = await _getHeaders();
    await http.post(
      Uri.parse(ApiConstants.inventarioCatalogo),
      headers: headers,
      body: jsonEncode({
        'nombre': nombre,
        'nombreGenerico': nombreGenerico,
        'presentacion': presentacion,
        'concentracion': concentracion,
      }),
    );
  }
}
