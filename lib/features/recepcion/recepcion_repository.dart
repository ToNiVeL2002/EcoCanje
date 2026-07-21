import 'package:ecocanje/features/recepcion/recepcion_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecepcionRepository {
  final SupabaseClient _supabaseClient;

  RecepcionRepository(this._supabaseClient);

  /// Buscar usuario por celular usando login_usuario
  Future<UsuarioBuscadoModel?> buscarUsuarioPorCelular(String celular) async {
    final data = await _supabaseClient.rpc(
      'login_usuario',
      params: {'p_celular': celular},
    );

    final json = data as Map<String, dynamic>;
    final exito = json['o_exito'] as bool;

    if (!exito) return null;

    return UsuarioBuscadoModel(
      idUsuario: json['o_id_usuario'] as int,
      nombre: (json['o_nombre'] as String?) ?? '',
      apellido: (json['o_apellido'] as String?) ?? '',
      usuario: (json['o_usuario'] as String?) ?? '',
      celular: celular,
      saldoEcocupones: (json['o_saldo_ecocupones'] as int?) ?? 0,
      tipoUsuario: (json['o_tipo_usuario'] as String?) ?? 'USUARIO',
    );
  }

  /// Obtener recolecciones activas de un usuario recolector
  Future<List<RecoleccionEntregaModel>> obtenerRecoleccionesActivas(int idUsuarioRecolector) async {
    final data = await _supabaseClient.rpc(
      'obtener_recolecciones_usuario',
      params: {
        'p_id_usuario_recolector': idUsuarioRecolector,
        'p_estado': 'ACTIVA',
      },
    );

    final lista = data as List<dynamic>;
    return lista
        .map((json) => RecoleccionEntregaModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtener id_empresa e id_punto_acopio a partir de id_usuario
  Future<({int? idEmpresa, int? idPuntoAcopio})> obtenerIdEntidad(int idUsuario) async {
    final data = await _supabaseClient.rpc(
      'obtener_id_entidad',
      params: {'p_id_usuario': idUsuario},
    );

    final lista = data as List<dynamic>;
    if (lista.isEmpty) return (idEmpresa: null, idPuntoAcopio: null);

    final json = lista.first as Map<String, dynamic>;
    return (
      idEmpresa: json['id_empresa'] as int?,
      idPuntoAcopio: json['id_punto_acopio'] as int?,
    );
  }

  /// Crear una entrega
  Future<CrearEntregaResponse> crearEntrega({
    required int idUsuarioEntrega,
    required int idUsuarioConfirmador,
    int? idEmpresa,
    int? idPuntoAcopio,
    required String tipoEntrega,
  }) async {
    final params = {
      'p_id_usuario_entrega': idUsuarioEntrega,
      'p_id_usuario_confirmador': idUsuarioConfirmador,
      'p_id_empresa': idEmpresa,
      'p_id_punto_acopio': idPuntoAcopio,
      'p_tipo_entrega': tipoEntrega,
    };
    debugPrint('=== CREAR_ENTREGA params: $params ===');

    final data = await _supabaseClient.rpc(
      'crear_entrega',
      params: params,
    );

    debugPrint('=== CREAR_ENTREGA response: $data ===');
    debugPrint('=== CREAR_ENTREGA type: ${data.runtimeType} ===');

    return CrearEntregaResponse.fromJson(data as Map<String, dynamic>);
  }

  /// Registrar una publicación como entregada dentro de una entrega
  Future<RegistrarPublicacionEntregadaResponse> registrarPublicacionEntregada({
    required int idEntrega,
    required int idPublicacion,
    required int ecocuponesProveedor,
    required int ecocuponesRecolector,
    required String motivo,
    required String detalle,
  }) async {
    final params = {
      'p_id_entrega': idEntrega,
      'p_id_publicacion': idPublicacion,
      'p_ecocupones_proveedor': ecocuponesProveedor,
      'p_ecocupones_recolector': ecocuponesRecolector,
      'p_motivo': motivo,
      'p_detalle': detalle,
    };
    debugPrint('=== REGISTRAR_PUBLICACION_ENTREGADA params: $params ===');

    final data = await _supabaseClient.rpc(
      'registrar_publicacion_entregada',
      params: params,
    );

    debugPrint('=== REGISTRAR_PUBLICACION_ENTREGADA response: $data ===');

    return RegistrarPublicacionEntregadaResponse.fromJson(data as Map<String, dynamic>);
  }
}
