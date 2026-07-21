part of 'publicaciones_cubit.dart';

sealed class PublicacionesState extends Equatable {
  const PublicacionesState();

  @override
  List<Object?> get props => [];
}

final class PublicacionesInitial extends PublicacionesState {}

final class PublicacionCreando extends PublicacionesState {}

final class PublicacionCreadaExito extends PublicacionesState {
  final String mensaje;
  final int? idPublicacionCreada;

  const PublicacionCreadaExito({
    required this.mensaje,
    this.idPublicacionCreada,
  });

  @override
  List<Object?> get props => [mensaje, idPublicacionCreada];
}

final class PublicacionesCargando extends PublicacionesState {}

final class PublicacionesCargadas extends PublicacionesState {
  final List<PublicacionDetalleModel> publicaciones;

  const PublicacionesCargadas(this.publicaciones);

  @override
  List<Object?> get props => [publicaciones];
}

final class RecoleccionAceptadaExito extends PublicacionesState {
  final String mensaje;
  final int? idRecoleccionCreada;

  const RecoleccionAceptadaExito({
    required this.mensaje,
    this.idRecoleccionCreada,
  });

  @override
  List<Object?> get props => [mensaje, idRecoleccionCreada];
}

final class PublicacionesError extends PublicacionesState {
  final String mensaje;

  const PublicacionesError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
