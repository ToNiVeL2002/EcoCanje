import 'package:bloc/bloc.dart';
import 'package:ecocanje/features/recolecciones/recolecciones_model.dart';
import 'package:ecocanje/features/recolecciones/recolecciones_repository.dart';
import 'package:equatable/equatable.dart';

part 'recolecciones_state.dart';

class RecoleccionesCubit extends Cubit<RecoleccionesState> {
  final RecoleccionesRepository _repository;
  final int? _usuarioId;
  String _filtroActual = 'TODAS';

  RecoleccionesCubit(this._repository, {int? usuarioId})
      : _usuarioId = usuarioId,
        super(RecoleccionesInitial());

  String get filtroActual => _filtroActual;

  Future<void> cargarRecolecciones({String? estado}) async {
    if (_usuarioId == null) {
      emit(const RecoleccionesError('Error: No se encontró una sesión activa de usuario.'));
      return;
    }

    if (estado != null) {
      _filtroActual = estado;
    }

    emit(RecoleccionesCargando());
    try {
      final lista = await _repository.obtenerRecoleccionesUsuario(
        idUsuarioRecolector: _usuarioId,
        estado: _filtroActual,
      );
      emit(RecoleccionesCargadas(lista, filtroActual: _filtroActual));
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('ClientException')) {
        emit(const RecoleccionesError(
            'Error de conexión a internet o con la base de datos. Por favor verifica tu red e intenta nuevamente.'));
      } else {
        emit(RecoleccionesError('Error al cargar recolecciones: $e'));
      }
    }
  }
}
