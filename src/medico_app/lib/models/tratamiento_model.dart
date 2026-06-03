class TratamientoModel {
  final int id;
  final int? recetaId;
  final int medicamentoId;
  final String medicamentoNombre;
  final String dosis;
  final int frecuenciaHoras;
  final int duracionDias;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String status;
  final String? notas;
  final int totalTomas;
  final int tomasTomadas;
  final int tomasPendientes;
  final DateTime createdAt;

  TratamientoModel({
    required this.id,
    this.recetaId,
    required this.medicamentoId,
    required this.medicamentoNombre,
    required this.dosis,
    required this.frecuenciaHoras,
    required this.duracionDias,
    required this.fechaInicio,
    required this.fechaFin,
    required this.status,
    this.notas,
    required this.totalTomas,
    required this.tomasTomadas,
    required this.tomasPendientes,
    required this.createdAt,
  });

  factory TratamientoModel.fromJson(Map<String, dynamic> json) {
    return TratamientoModel(
      id: json['id'],
      recetaId: json['recetaId'],
      medicamentoId: json['medicamentoId'],
      medicamentoNombre: json['medicamentoNombre'],
      dosis: json['dosis'],
      frecuenciaHoras: json['frecuenciaHoras'],
      duracionDias: json['duracionDias'],
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: DateTime.parse(json['fechaFin']),
      status: json['status'],
      notas: json['notas'],
      totalTomas: json['totalTomas'],
      tomasTomadas: json['tomasTomadas'],
      tomasPendientes: json['tomasPendientes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class TomaModel {
  final int id;
  final int tratamientoId;
  final String medicamentoNombre;
  final String dosis;
  final DateTime horaProgramada;
  final DateTime? horaTomada;
  final String status;
  final bool descontadoInventario;

  TomaModel({
    required this.id,
    required this.tratamientoId,
    required this.medicamentoNombre,
    required this.dosis,
    required this.horaProgramada,
    this.horaTomada,
    required this.status,
    required this.descontadoInventario,
  });

  factory TomaModel.fromJson(Map<String, dynamic> json) {
    return TomaModel(
      id: json['id'],
      tratamientoId: json['tratamientoId'],
      medicamentoNombre: json['medicamentoNombre'],
      dosis: json['dosis'],
      horaProgramada: DateTime.parse(json['horaProgramada']),
      horaTomada: json['horaTomada'] != null
          ? DateTime.parse(json['horaTomada'])
          : null,
      status: json['status'],
      descontadoInventario: json['descontadoInventario'],
    );
  }
}
