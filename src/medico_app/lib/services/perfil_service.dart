import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_service.dart';

class PerfilService {
  final _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getPerfil() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.perfil),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener perfil');
  }

  Future<void> updatePerfil({
    String? nombre,
    String? telefono,
    String? tipoSangre,
    DateTime? fechaNacimiento,
  }) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse(ApiConstants.perfil),
      headers: headers,
      body: jsonEncode({
        'nombre': nombre,
        'telefono': telefono,
        'tipoSangre': tipoSangre,
        'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      }),
    );

    if (response.statusCode != 204) {
      throw Exception('Error al actualizar perfil');
    }
  }
}
