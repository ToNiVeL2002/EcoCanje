part of 'recolecciones_cubit.dart';

sealed class RecoleccionesState extends Equatable {
  const RecoleccionesState();

  @override
  List<Object?> get props => [];
}

final class RecoleccionesInitial extends RecoleccionesState {}

final class RecoleccionesCargando extends RecoleccionesState {}

final class RecoleccionesCargadas extends RecoleccionesState {
  final List<RecoleccionModel> recolecciones;

  const RecoleccionesCargadas(this.recolecciones);

  @override
  List<Object?> get props => [recolecciones];
}

final class RecoleccionesError extends RecoleccionesState {
  final String mensaje;

  const RecoleccionesError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
