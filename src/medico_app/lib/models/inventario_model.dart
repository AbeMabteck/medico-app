class MedicamentoCatalogoModel {
  final int id;
  final String nombre;
  final String? nombreGenerico;
  final String? presentacion;
  final String? concentracion;

  MedicamentoCatalogoModel({
    required this.id,
    required this.nombre,
    this.nombreGenerico,
    this.presentacion,
    this.concentracion,
  });

  factory MedicamentoCatalogoModel.fromJson(Map<String, dynamic> json) {
    return MedicamentoCatalogoModel(
      id: json['id'],
      nombre: json['nombre'],
      nombreGenerico: json['nombreGenerico'],
      presentacion: json['presentacion'],
      concentracion: json['concentracion'],
    );
  }
}

class InventarioModel {
  final int id;
  final int medicamentoId;
  final String medicamentoNombre;
  final String? medicamentoPresentacion;
  final String? medicamentoConcentracion;
  final int cantidadActual;
  final int cantidadMinima;
  final String unidad;
  final DateTime? fechaCaducidad;
  final String? lugarCompra;
  final double? precio;
  final String status;
  final bool stockBajo;
  final DateTime updatedAt;

  InventarioModel({
    required this.id,
    required this.medicamentoId,
    required this.medicamentoNombre,
    this.medicamentoPresentacion,
    this.medicamentoConcentracion,
    required this.cantidadActual,
    required this.cantidadMinima,
    required this.unidad,
    this.fechaCaducidad,
    this.lugarCompra,
    this.precio,
    required this.status,
    required this.stockBajo,
    required this.updatedAt,
  });

  factory InventarioModel.fromJson(Map<String, dynamic> json) {
    return InventarioModel(
      id: json['id'],
      medicamentoId: json['medicamentoId'],
      medicamentoNombre: json['medicamentoNombre'],
      medicamentoPresentacion: json['medicamentoPresentacion'],
      medicamentoConcentracion: json['medicamentoConcentracion'],
      cantidadActual: json['cantidadActual'],
      cantidadMinima: json['cantidadMinima'],
      unidad: json['unidad'],
      fechaCaducidad: json['fechaCaducidad'] != null
          ? DateTime.parse(json['fechaCaducidad'])
          : null,
      lugarCompra: json['lugarCompra'],
      precio: json['precio']?.toDouble(),
      status: json['status'],
      stockBajo: json['stockBajo'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
