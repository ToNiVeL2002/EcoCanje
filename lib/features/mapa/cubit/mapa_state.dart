part of 'mapa_cubit.dart';

sealed class MapaState extends Equatable {
  const MapaState();

  @override
  List<Object?> get props => [];
}

final class MapaInitial extends MapaState {}

final class MapaCargando extends MapaState {}

final class MapaCargado extends MapaState {
  final List<UbicacionMapaModel> ubicaciones;
  final LatLng? posicionUsuario;

  const MapaCargado({
    required this.ubicaciones,
    this.posicionUsuario,
  });

  @override
  List<Object?> get props => [ubicaciones, posicionUsuario];
}

final class MapaError extends MapaState {
  final String mensaje;

  const MapaError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
