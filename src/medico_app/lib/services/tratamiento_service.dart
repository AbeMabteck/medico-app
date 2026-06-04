import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/tratamiento_model.dart';
import 'auth_service.dart';

class TratamientoService {
  final _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtener todos los tratamientos
  Future<List<TratamientoModel>> getTratamientos() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.tratamientos),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((t) => TratamientoModel.fromJson(t)).toList();
    }
    throw Exception('Error al obtener tratamientos');
  }

  // Obtener tratamientos activos
  Future<List<TratamientoModel>> getTratamientosActivos() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.tratamientosActivos),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((t) => TratamientoModel.fromJson(t)).toList();
    }
    throw Exception('Error al obtener tratamientos activos');
  }

  // Obtener tomas de un tratamiento
  Future<List<TomaModel>> getTomas(int tratamientoId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.tratamientos}/$tratamientoId/tomas'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((t) => TomaModel.fromJson(t)).toList();
    }
    throw Exception('Error al obtener tomas');
  }

  // Obtener próximas tomas
  Future<List<TomaModel>> getProximasTomas() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.tomasProximas),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((t) => TomaModel.fromJson(t)).toList();
    }
    throw Exception('Error al obtener próximas tomas');
  }

  // Crear tratamiento
  Future<Map<String, dynamic>> createTratamiento({
    required int medicamentoId,
    required String dosis,
    required int frecuenciaHoras,
    required int duracionDias,
    required DateTime fechaInicio,
    int? recetaId,
    String? notas,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.tratamientos),
      headers: headers,
      body: jsonEncode({
        'medicamentoId': medicamentoId,
        'dosis': dosis,
        'frecuenciaHoras': frecuenciaHoras,
        'duracionDias': duracionDias,
        'fechaInicio': fechaInicio.toIso8601String(),
        'recetaId': recetaId,
        'notas': notas,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al crear tratamiento');
  }

  // Confirmar toma
  Future<void> confirmarToma(int tomaId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.tratamientos}/tomas/$tomaId/confirmar'),
      headers: headers,
      body: jsonEncode({'horaTomada': DateTime.now().toIso8601String()}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al confirmar toma');
    }
  }

  // Omitir toma
  Future<void> omitirToma(int tomaId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.tratamientos}/tomas/$tomaId/omitir'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al omitir toma');
    }
  }

  // Cancelar tratamiento
  Future<void> cancelarTratamiento(int id) async {
    final headers = await _getHeaders();
    await http.put(
      Uri.parse('${ApiConstants.tratamientos}/$id/cancelar'),
      headers: headers,
    );
  }
}
