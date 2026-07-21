import 'package:bloc/bloc.dart';
import 'package:ecocanje/features/recepcion/recepcion_model.dart';
import 'package:ecocanje/features/recepcion/recepcion_repository.dart';
import 'package:equatable/equatable.dart';

part 'recepcion_state.dart';

class RecepcionCubit extends Cubit<RecepcionState> {
  final RecepcionRepository _repository;
  final int _idUsuarioConfirmador;
  final String _tipoUsuarioConfirmador; // 'EMPRESA' o 'PUNTO_ACOPIO'

  RecepcionCubit(
    this._repository, {
    required int idUsuarioConfirmador,
    required String tipoUsuarioConfirmador,
  })  : _idUsuarioConfirmador = idUsuarioConfirmador,
        _tipoUsuarioConfirmador = tipoUsuarioConfirmador,
        super(RecepcionInitial());

  /// Buscar un usuario por su celular y cargar sus recolecciones activas
  Future<void> buscarUsuario(String celular) async {
    emit(RecepcionBuscandoUsuario());
    try {
      final usuario = await _repository.buscarUsuarioPorCelular(celular);

      if (usuario == null) {
        emit(RecepcionUsuarioNoEncontrado());
        return;
      }

      // Obtener las recolecciones activas del usuario
      final recolecciones = await _repository.obtenerRecoleccionesActivas(usuario.idUsuario);

      emit(RecepcionUsuarioEncontrado(
        usuario: usuario,
        recoleccionesActivas: recolecciones,
      ));
    } catch (e) {
      emit(RecepcionError('Error al buscar usuario: $e'));
    }
  }

  /// Procesar entrega DIRECTA (sin recolecciones, 10 ecocupones al usuario)
  Future<void> procesarEntregaDirecta(int idUsuarioEntrega) async {
    emit(RecepcionProcesandoEntrega());
    try {
      // Obtener id_empresa o id_punto_acopio del confirmador
      final entidad = await _repository.obtenerIdEntidad(_idUsuarioConfirmador);
      final idEmpresa = entidad.idEmpresa;
      final idPuntoAcopio = entidad.idPuntoAcopio;

      if (idEmpresa == null && idPuntoAcopio == null) {
        emit(const RecepcionError('Error: No se encontró la entidad asociada al usuario confirmador.'));
        return;
      }

      final entregaResp = await _repository.crearEntrega(
        idUsuarioEntrega: idUsuarioEntrega,
        idUsuarioConfirmador: _idUsuarioConfirmador,
        idEmpresa: idEmpresa,
        idPuntoAcopio: idPuntoAcopio,
        tipoEntrega: 'DIRECTA',
      );

      if (!entregaResp.exito) {
        emit(RecepcionError(entregaResp.mensaje));
        return;
      }

      emit(const RecepcionEntregaExitosa(
        mensaje: 'Entrega directa registrada. +10 EcoCupones al usuario.',
        publicacionesProcesadas: 0,
      ));
    } catch (e) {
      emit(RecepcionError('Error al procesar entrega directa: $e'));
    }
  }

  /// Procesar entrega de RECOLECCIÓN (5 ec proveedor + 5 ec recolector por publicación)
  Future<void> procesarEntregaRecoleccion({
    required int idUsuarioRecolector,
    required List<RecoleccionEntregaModel> recoleccionesSeleccionadas,
  }) async {
    if (recoleccionesSeleccionadas.isEmpty) {
      emit(const RecepcionError('Debe seleccionar al menos una recolección para procesar.'));
      return;
    }

    emit(RecepcionProcesandoEntrega());
    try {
      // Obtener id_empresa o id_punto_acopio del confirmador
      final entidad = await _repository.obtenerIdEntidad(_idUsuarioConfirmador);
      final idEmpresa = entidad.idEmpresa;
      final idPuntoAcopio = entidad.idPuntoAcopio;

      if (idEmpresa == null && idPuntoAcopio == null) {
        emit(const RecepcionError('Error: No se encontró la entidad asociada al usuario confirmador.'));
        return;
      }

      // 1. Crear la entrega
      final entregaResp = await _repository.crearEntrega(
        idUsuarioEntrega: idUsuarioRecolector,
        idUsuarioConfirmador: _idUsuarioConfirmador,
        idEmpresa: idEmpresa,
        idPuntoAcopio: idPuntoAcopio,
        tipoEntrega: 'RECOLECCION',
      );

      if (!entregaResp.exito || entregaResp.idEntrega == null) {
        emit(RecepcionError(entregaResp.mensaje));
        return;
      }

      final idEntrega = entregaResp.idEntrega!;

      // 2. Registrar cada publicación en la entrega (5 ec proveedor + 5 ec recolector)
      int procesadas = 0;
      for (final rec in recoleccionesSeleccionadas) {
        try {
          final res = await _repository.registrarPublicacionEntregada(
            idEntrega: idEntrega,
            idPublicacion: rec.idPublicacion,
            ecocuponesProveedor: 5,
            ecocuponesRecolector: 5,
            motivo: 'Entrega de ${rec.material.toLowerCase()}',
            detalle: rec.descripcion,
          );
          print('=== REGISTRAR_PUBLICACION_ENTREGADA result: exito=${res.exito}, mensaje=${res.mensaje} ===');
          if (res.exito) {
            procesadas++;
          }
        } catch (e) {
          print('=== REGISTRAR_PUBLICACION_ENTREGADA error: $e ===');
        }
      }

      emit(RecepcionEntregaExitosa(
        mensaje: 'Entrega completada. $procesadas publicación(es) procesada(s).\n'
            '+5 EC por publicación al proveedor.\n'
            '+5 EC por publicación al recolector.',
        publicacionesProcesadas: procesadas,
      ));
    } catch (e) {
      emit(RecepcionError('Error al procesar entrega: $e'));
    }
  }

  /// Resetear al estado inicial para nueva búsqueda
  void resetear() {
    emit(RecepcionInitial());
  }
}
