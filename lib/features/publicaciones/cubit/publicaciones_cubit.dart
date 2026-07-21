import 'package:bloc/bloc.dart';
import 'package:ecocanje/features/publicaciones/publicaciones_model.dart';
import 'package:ecocanje/features/publicaciones/publicaciones_repository.dart';
import 'package:equatable/equatable.dart';

part 'publicaciones_state.dart';

class PublicacionesCubit extends Cubit<PublicacionesState> {
  final PublicacionesRepository _repository;
  final int? _usuarioId;

  PublicacionesCubit(this._repository, {int? usuarioId})
      : _usuarioId = usuarioId,
        super(PublicacionesInitial());

  Future<void> cargarPublicaciones({String? estado}) async {
    emit(PublicacionesCargando());
    try {
      final publicaciones = await _repository.obtenerPublicaciones(estado: estado);
      emit(PublicacionesCargadas(publicaciones));
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('ClientException')) {
        emit(const PublicacionesError(
            'Error de conexión a internet o con la base de datos. Por favor verifica tu red e intenta nuevamente.'));
      } else {
        emit(PublicacionesError('Error al cargar publicaciones: $e'));
      }
    }
  }

  Future<void> crearPublicacion({
    required String material,
    required String descripcion,
    int? idUsuarioOverride,
  }) async {
    final targetId = idUsuarioOverride ?? _usuarioId;

    if (targetId == null) {
      emit(const PublicacionesError('Error: No se encontró un usuario activo para crear la publicación.'));
      return;
    }

    emit(PublicacionCreando());
    try {
      final response = await _repository.crearPublicacion(
        idUsuario: targetId,
        material: material,
        descripcion: descripcion,
      );

      if (response.exito) {
        emit(PublicacionCreadaExito(
          mensaje: response.mensaje,
          idPublicacionCreada: response.idPublicacionCreada,
        ));
        await cargarPublicaciones();
      } else {
        emit(PublicacionesError(response.mensaje));
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('ClientException')) {
        emit(const PublicacionesError(
            'Error de conexión a internet o con la base de datos. Por favor verifica tu red e intenta nuevamente.'));
      } else {
        emit(PublicacionesError('Error inesperado: $e'));
      }
    }
  }

  Future<void> aceptarRecoleccion({
    required int idPublicacion,
    int? idUsuarioRecolectorOverride,
  }) async {
    final targetRecolectorId = idUsuarioRecolectorOverride ?? _usuarioId;

    if (targetRecolectorId == null) {
      emit(const PublicacionesError('Error: No se encontró un usuario autenticado para aceptar la recolección.'));
      return;
    }

    try {
      final response = await _repository.aceptarRecoleccion(
        idPublicacion: idPublicacion,
        idUsuarioRecolector: targetRecolectorId,
      );

      if (response.exito) {
        emit(RecoleccionAceptadaExito(
          mensaje: response.mensaje,
          idRecoleccionCreada: response.idRecoleccionCreada,
        ));
        // Recargar la lista de publicaciones para que la publicación cambie a 'OCUPADA'
        await cargarPublicaciones();
      } else {
        emit(PublicacionesError(response.mensaje));
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('ClientException')) {
        emit(const PublicacionesError(
            'Error de conexión a internet o con la base de datos. Por favor verifica tu red e intenta nuevamente.'));
      } else {
        emit(PublicacionesError('Error al aceptar recolección: $e'));
      }
    }
  }

  void resetState() {
    emit(PublicacionesInitial());
  }
}
