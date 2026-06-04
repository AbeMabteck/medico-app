import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/consulta_model.dart';
import 'auth_service.dart';

class DoctorService {
  final _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

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

  Future<void> updateDoctor(
    int id, {
    String? nombre,
    String? especialidad,
    String? consultorio,
    String? telefono,
    String? notas,
  }) async {
    final headers = await _getHeaders();
    await http.put(
      Uri.parse('${ApiConstants.doctores}/$id'),
      headers: headers,
      body: jsonEncode({
        'nombre': nombre,
        'especialidad': especialidad,
        'consultorio': consultorio,
        'telefono': telefono,
        'notas': notas,
      }),
    );
  }

  Future<void> deleteDoctor(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.doctores}/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar doctor');
    }
  }
}
