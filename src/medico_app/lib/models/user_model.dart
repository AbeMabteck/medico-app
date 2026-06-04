class UserModel {
  final String token;
  final String nombre;
  final String email;
  final DateTime expiration;

  UserModel({
    required this.token,
    required this.nombre,
    required this.email,
    required this.expiration,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'],
      nombre: json['nombre'],
      email: json['email'],
      expiration: DateTime.parse(json['expiration']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'nombre': nombre,
      'email': email,
      'expiration': expiration.toIso8601String(),
    };
  }
}
