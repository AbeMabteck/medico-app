class DoctorModel {
  final int id;
  final String nombre;
  final String? especialidad;
  final String? consultorio;
  final String? telefono;
  final String? notas;
  final bool activo;

  DoctorModel({
    required this.id,
    required this.nombre,
    this.especialidad,
    this.consultorio,
    this.telefono,
    this.notas,
    required this.activo,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'],
      nombre: json['nombre'],
      especialidad: json['especialidad'],
      consultorio: json['consultorio'],
      telefono: json['telefono'],
      notas: json['notas'],
      activo: json['activo'],
    );
  }
}

class ConsultaModel {
  final int id;
  final int? doctorId;
  final String? doctorNombre;
  final String? doctorEspecialidad;
  final DateTime fecha;
  final String? motivo;
  final String? sintomas;
  final String? diagnostico;
  final String? notas;
  final DateTime createdAt;
  final List<RecetaModel> recetas;

  ConsultaModel({
    required this.id,
    this.doctorId,
    this.doctorNombre,
    this.doctorEspecialidad,
    required this.fecha,
    this.motivo,
    this.sintomas,
    this.diagnostico,
    this.notas,
    required this.createdAt,
    required this.recetas,
  });

  factory ConsultaModel.fromJson(Map<String, dynamic> json) {
    return ConsultaModel(
      id: json['id'],
      doctorId: json['doctorId'],
      doctorNombre: json['doctorNombre'],
      doctorEspecialidad: json['doctorEspecialidad'],
      fecha: DateTime.parse(json['fecha']),
      motivo: json['motivo'],
      sintomas: json['sintomas'],
      diagnostico: json['diagnostico'],
      notas: json['notas'],
      createdAt: DateTime.parse(json['createdAt']),
      recetas: (json['recetas'] as List)
          .map((r) => RecetaModel.fromJson(r))
          .toList(),
    );
  }
}

class RecetaModel {
  final int id;
  final int consultaId;
  final String? fotoPath;
  final String? notas;
  final DateTime createdAt;

  RecetaModel({
    required this.id,
    required this.consultaId,
    this.fotoPath,
    this.notas,
    required this.createdAt,
  });

  factory RecetaModel.fromJson(Map<String, dynamic> json) {
    return RecetaModel(
      id: json['id'],
      consultaId: json['consultaId'],
      fotoPath: json['fotoPath'],
      notas: json['notas'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
