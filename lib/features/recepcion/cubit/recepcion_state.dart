part of 'recepcion_cubit.dart';

sealed class RecepcionState extends Equatable {
  const RecepcionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - esperando que se busque un usuario
final class RecepcionInitial extends RecepcionState {}

/// Buscando usuario por celular
final class RecepcionBuscandoUsuario extends RecepcionState {}

/// Usuario encontrado con sus recolecciones activas
final class RecepcionUsuarioEncontrado extends RecepcionState {
  final UsuarioBuscadoModel usuario;
  final List<RecoleccionEntregaModel> recoleccionesActivas;

  const RecepcionUsuarioEncontrado({
    required this.usuario,
    required this.recoleccionesActivas,
  });

  bool get tieneRecolecciones => recoleccionesActivas.isNotEmpty;

  @override
  List<Object?> get props => [usuario, recoleccionesActivas];
}

/// Procesando la entrega
final class RecepcionProcesandoEntrega extends RecepcionState {}

/// Entrega completada exitosamente
final class RecepcionEntregaExitosa extends RecepcionState {
  final String mensaje;
  final int publicacionesProcesadas;

  const RecepcionEntregaExitosa({
    required this.mensaje,
    required this.publicacionesProcesadas,
  });

  @override
  List<Object?> get props => [mensaje, publicacionesProcesadas];
}

/// Error
final class RecepcionError extends RecepcionState {
  final String mensaje;

  const RecepcionError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}

/// Usuario no encontrado
final class RecepcionUsuarioNoEncontrado extends RecepcionState {}
