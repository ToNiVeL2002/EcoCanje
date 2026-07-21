import 'package:bloc/bloc.dart';
import 'package:ecocanje/features/mapa/mapa_model.dart';
import 'package:ecocanje/features/mapa/mapa_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

part 'mapa_state.dart';

class MapaCubit extends Cubit<MapaState> {
  final MapaRepository _repository;

  MapaCubit(this._repository) : super(MapaInitial());

  Future<void> cargarMapa() async {
    emit(MapaCargando());
    try {
      final ubicaciones = await _repository.obtenerUbicacionesMapa();
      final userPos = await _obtenerPosicionUsuario();

      LatLng? posicionUsuario;
      if (userPos != null) {
        posicionUsuario = LatLng(userPos.latitude, userPos.longitude);
      }

      emit(MapaCargado(
        ubicaciones: ubicaciones,
        posicionUsuario: posicionUsuario,
      ));
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('ClientException')) {
        emit(const MapaError('Error de conexión a internet o con la base de datos.'));
      } else {
        emit(MapaError('Error al cargar datos del mapa: $e'));
      }
    }
  }

  Future<Position?> _obtenerPosicionUsuario() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
    } catch (_) {
      return null;
    }
  }
}
