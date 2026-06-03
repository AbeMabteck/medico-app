class ApiConstants {
  static const String baseUrl =
      'http://10.0.2.2:5224/api'; //10.0.2.2 es la IP especial que usa el emulador de Android para referirse a localhost de tu PC. Cuando pruebas en un celular físico se cambia por la IP local de tu PC.

  // Auth
  static const String login = '$baseUrl/Auth/login';
  static const String register = '$baseUrl/Auth/register';

  // Doctores
  static const String doctores = '$baseUrl/Doctores';

  // Consultas
  static const String consultas = '$baseUrl/Consultas';

  // Recetas
  static const String recetas = '$baseUrl/Recetas';

  // Inventario
  static const String inventario = '$baseUrl/Inventario';
  static const String inventarioCatalogo = '$baseUrl/Inventario/catalogo';
  static const String inventarioStockBajo = '$baseUrl/Inventario/stock-bajo';

  // Tratamientos
  static const String tratamientos = '$baseUrl/Tratamientos';
  static const String tratamientosActivos = '$baseUrl/Tratamientos/activos';
  static const String tomasProximas = '$baseUrl/Tratamientos/tomas/proximas';
}
