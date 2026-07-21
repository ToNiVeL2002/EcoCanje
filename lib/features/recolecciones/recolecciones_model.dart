import 'package:equatable/equatable.dart';

class RecoleccionModel extends Equatable {
  final int idRecoleccion;
  final int idPublicacion;
  final String material;
  final String descripcion;
  final String estadoRecoleccion;
  final DateTime? fechaAceptacion;
  final DateTime? fechaCancelacion;
  final int idUsuarioCreador;
  final String nombreCreador;
  final String celularCreador;

  const RecoleccionModel({
    required this.idRecoleccion,
    required this.idPublicacion,
    required this.material,
    required this.descripcion,
    required this.estadoRecoleccion,
    this.fechaAceptacion,
    this.fechaCancelacion,
    required this.idUsuarioCreador,
    required this.nombreCreador,
    required this.celularCreador,
  });

  factory RecoleccionModel.fromJson(Map<String, dynamic> json) {
    return RecoleccionModel(
      idRecoleccion: json['id_recoleccion'] as int,
      idPublicacion: json['id_publicacion'] as int,
      material: (json['material'] as String?) ?? '',
      descripcion: (json['descripcion'] as String?) ?? '',
      estadoRecoleccion: (json['estado_recoleccion'] as String?) ?? 'ACTIVA',
      fechaAceptacion: json['fecha_aceptacion'] != null
          ? DateTime.parse(json['fecha_aceptacion'] as String)
          : null,
      fechaCancelacion: json['fecha_cancelacion'] != null
          ? DateTime.parse(json['fecha_cancelacion'] as String)
          : null,
      idUsuarioCreador: json['id_usuario_creador'] as int,
      nombreCreador: (json['nombre_creador'] as String?) ?? '',
      celularCreador: (json['celular_creador'] as String?) ?? '',
    );
  }

  @override
  List<Object?> get props => [
        idRecoleccion,
        idPublicacion,
        material,
        descripcion,
        estadoRecoleccion,
        fechaAceptacion,
        fechaCancelacion,
        idUsuarioCreador,
        nombreCreador,
        celularCreador,
      ];
}
