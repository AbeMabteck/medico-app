import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _nombreKey = 'user_nombre';
  static const String _emailKey = 'user_email';

  // Registro
  Future<UserModel> register({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
    String? tipoSangre,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'email': email,
        'password': password,
        'telefono': telefono,
        'tipoSangre': tipoSangre,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final user = UserModel.fromJson(jsonDecode(response.body));
      await _saveSession(user);
      return user;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al registrarse');
    }
  }

  // Login
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final user = UserModel.fromJson(jsonDecode(response.body));
      await _saveSession(user);
      return user;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Credenciales incorrectas');
    }
  }

  // Guardar sesión
  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, user.token);
    await prefs.setString(_nombreKey, user.nombre);
    await prefs.setString(_emailKey, user.email);
  }

  // Obtener token guardado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Obtener nombre guardado
  Future<String?> getNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nombreKey);
  }

  // Verificar si hay sesión activa
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
