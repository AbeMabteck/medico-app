import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/consulta_model.dart';
import 'auth_service.dart';

class ConsultaService {
  final _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtener todas las consultas
  Future<List<ConsultaModel>> getConsultas() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.consultas),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((c) => ConsultaModel.fromJson(c)).toList();
    }
    throw Exception('Error al obtener consultas');
  }

  // Crear consulta
  Future<void> createConsulta({
    required DateTime fecha,
    int? doctorId,
    String? motivo,
    String? sintomas,
    String? diagnostico,
    String? notas,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.consultas),
      headers: headers,
      body: jsonEncode({
        'fecha': fecha.toIso8601String(),
        'doctorId': doctorId,
        'motivo': motivo,
        'sintomas': sintomas,
        'diagnostico': diagnostico,
        'notas': notas,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear consulta');
    }
  }

  // Eliminar consulta
  Future<void> deleteConsulta(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.consultas}/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar consulta');
    }
  }

  // Obtener doctores
  Future<List<DoctorModel>> getDoctores() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.doctores),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((d) => DoctorModel.fromJson(d)).toList();
    }
    throw Exception('Error al obtener doctores');
  }

  // Crear doctor
  Future<void> createDoctor({
    required String nombre,
    String? especialidad,
    String? consultorio,
    String? telefono,
    String? notas,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.doctores),
      headers: headers,
      body: jsonEncode({
        'nombre': nombre,
        'especialidad': especialidad,
        'consultorio': consultorio,
        'telefono': telefono,
        'notas': notas,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear doctor');
    }
  }
}
