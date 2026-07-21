import 'package:equatable/equatable.dart';

/// Modelo para una recolección activa que un usuario trae a entregar
class RecoleccionEntregaModel extends Equatable {
  final int idRecoleccion;
  final int idPublicacion;
  final String material;
  final String descripcion;
  final String estadoRecoleccion;
  final DateTime? fechaAceptacion;
  final int idUsuarioCreador;
  final String nombreCreador;
  final String celularCreador;

  const RecoleccionEntregaModel({
    required this.idRecoleccion,
    required this.idPublicacion,
    required this.material,
    required this.descripcion,
    required this.estadoRecoleccion,
    this.fechaAceptacion,
    required this.idUsuarioCreador,
    required this.nombreCreador,
    required this.celularCreador,
  });

  factory RecoleccionEntregaModel.fromJson(Map<String, dynamic> json) {
    return RecoleccionEntregaModel(
      idRecoleccion: json['id_recoleccion'] as int,
      idPublicacion: json['id_publicacion'] as int,
      material: (json['material'] as String?) ?? '',
      descripcion: (json['descripcion'] as String?) ?? '',
      estadoRecoleccion: (json['estado_recoleccion'] as String?) ?? 'ACTIVA',
      fechaAceptacion: json['fecha_aceptacion'] != null
          ? DateTime.parse(json['fecha_aceptacion'] as String)
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
        idUsuarioCreador,
        nombreCreador,
        celularCreador,
      ];
}

/// Respuesta de crear_entrega RPC
class CrearEntregaResponse extends Equatable {
  final bool exito;
  final String mensaje;
  final int? idEntrega;

  const CrearEntregaResponse({
    required this.exito,
    required this.mensaje,
    this.idEntrega,
  });

  factory CrearEntregaResponse.fromJson(Map<String, dynamic> json) {
    return CrearEntregaResponse(
      exito: json['o_exito'] as bool,
      mensaje: (json['o_mensaje'] as String?) ?? '',
      idEntrega: json['o_id_entrega'] as int?,
    );
  }

  @override
  List<Object?> get props => [exito, mensaje, idEntrega];
}

/// Respuesta de registrar_publicacion_entregada RPC
class RegistrarPublicacionEntregadaResponse extends Equatable {
  final bool exito;
  final String mensaje;

  const RegistrarPublicacionEntregadaResponse({
    required this.exito,
    required this.mensaje,
  });

  factory RegistrarPublicacionEntregadaResponse.fromJson(Map<String, dynamic> json) {
    return RegistrarPublicacionEntregadaResponse(
      exito: json['o_exito'] as bool,
      mensaje: (json['o_mensaje'] as String?) ?? '',
    );
  }

  @override
  List<Object?> get props => [exito, mensaje];
}

/// Datos del usuario buscado por celular
class UsuarioBuscadoModel extends Equatable {
  final int idUsuario;
  final String nombre;
  final String apellido;
  final String usuario;
  final String celular;
  final int saldoEcocupones;
  final String tipoUsuario;

  const UsuarioBuscadoModel({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.usuario,
    required this.celular,
    required this.saldoEcocupones,
    required this.tipoUsuario,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  @override
  List<Object?> get props => [
        idUsuario,
        nombre,
        apellido,
        usuario,
        celular,
        saldoEcocupones,
        tipoUsuario,
      ];
}
