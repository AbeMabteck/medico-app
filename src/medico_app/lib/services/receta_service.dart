import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/consulta_model.dart';
import 'auth_service.dart';

class RecetaService {
  final _authService = AuthService();

  Future<String?> getToken() async {
    return await _authService.getToken();
  }

  Future<RecetaModel> subirReceta({
    required int consultaId,
    required File foto,
    String? notas,
  }) async {
    final token = await _authService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.recetas),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['consultaId'] = consultaId.toString();
    if (notas != null) request.fields['notas'] = notas;

    request.files.add(await http.MultipartFile.fromPath('foto', foto.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return RecetaModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al subir receta');
  }

  Future<void> eliminarReceta(int id) async {
    final token = await _authService.getToken();
    final response = await http.delete(
      Uri.parse('${ApiConstants.recetas}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar receta');
    }
  }
}
