import 'package:equatable/equatable.dart';

class PublicacionModel extends Equatable {
  final int? idPublicacion;
  final int idUsuario;
  final String material;
  final String descripcion;
  final String? estado;
  final DateTime? fechaPublicacion;

  const PublicacionModel({
    this.idPublicacion,
    required this.idUsuario,
    required this.material,
    required this.descripcion,
    this.estado,
    this.fechaPublicacion,
  });

  factory PublicacionModel.fromJson(Map<String, dynamic> json) {
    return PublicacionModel(
      idPublicacion: json['id_publicacion'] as int?,
      idUsuario: json['id_usuario'] as int,
      material: json['material'] as String,
      descripcion: json['descripcion'] as String,
      estado: json['estado'] as String?,
      fechaPublicacion: json['fecha_publicacion'] != null
          ? DateTime.parse(json['fecha_publicacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'material': material,
      'descripcion': descripcion,
    };
  }

  @override
  List<Object?> get props => [
        idPublicacion,
        idUsuario,
        material,
        descripcion,
        estado,
        fechaPublicacion,
      ];
}

class PublicacionDetalleModel extends Equatable {
  final int idPublicacion;
  final int idUsuario;
  final String nombreUsuario;
  final String celularUsuario;
  final String? direccion;
  final String material;
  final String descripcion;
  final String estado;
  final DateTime? fechaPublicacion;
  final int? idEntrega;

  const PublicacionDetalleModel({
    required this.idPublicacion,
    required this.idUsuario,
    required this.nombreUsuario,
    required this.celularUsuario,
    this.direccion,
    required this.material,
    required this.descripcion,
    required this.estado,
    this.fechaPublicacion,
    this.idEntrega,
  });

  factory PublicacionDetalleModel.fromJson(Map<String, dynamic> json) {
    return PublicacionDetalleModel(
      idPublicacion: json['id_publicacion'] as int,
      idUsuario: json['id_usuario'] as int,
      nombreUsuario: (json['nombre_usuario'] as String?) ?? '',
      celularUsuario: (json['celular_usuario'] as String?) ?? '',
      direccion: (json['direccion'] as String?) ??
          (json['direccion_usuario'] as String?) ??
          (json['ubicacion'] as String?),
      material: (json['material'] as String?) ?? '',
      descripcion: (json['descripcion'] as String?) ?? '',
      estado: (json['estado'] as String?) ?? 'DISPONIBLE',
      fechaPublicacion: json['fecha_publicacion'] != null
          ? DateTime.parse(json['fecha_publicacion'] as String)
          : null,
      idEntrega: json['id_entrega'] as int?,
    );
  }

  @override
  List<Object?> get props => [
        idPublicacion,
        idUsuario,
        nombreUsuario,
        celularUsuario,
        direccion,
        material,
        descripcion,
        estado,
        fechaPublicacion,
        idEntrega,
      ];
}

class CrearPublicacionResponse extends Equatable {
  final bool exito;
  final String mensaje;
  final int? idPublicacionCreada;

  const CrearPublicacionResponse({
    required this.exito,
    required this.mensaje,
    this.idPublicacionCreada,
  });

  factory CrearPublicacionResponse.fromJson(Map<String, dynamic> json) {
    return CrearPublicacionResponse(
      exito: json['o_exito'] as bool,
      mensaje: json['o_mensaje'] as String,
      idPublicacionCreada: json['o_id_publicacion_creada'] as int?,
    );
  }

  @override
  List<Object?> get props => [exito, mensaje, idPublicacionCreada];
}

class AceptarRecoleccionResponse extends Equatable {
  final bool exito;
  final String mensaje;
  final int? idRecoleccionCreada;

  const AceptarRecoleccionResponse({
    required this.exito,
    required this.mensaje,
    this.idRecoleccionCreada,
  });

  factory AceptarRecoleccionResponse.fromJson(Map<String, dynamic> json) {
    return AceptarRecoleccionResponse(
      exito: json['o_exito'] as bool,
      mensaje: json['o_mensaje'] as String,
      idRecoleccionCreada: json['o_id_recoleccion_creada'] as int?,
    );
  }

  @override
  List<Object?> get props => [exito, mensaje, idRecoleccionCreada];
}
