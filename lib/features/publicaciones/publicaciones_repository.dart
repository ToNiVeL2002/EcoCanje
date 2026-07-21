import 'package:ecocanje/features/publicaciones/publicaciones_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PublicacionesRepository {
  final SupabaseClient _supabaseClient;

  PublicacionesRepository(this._supabaseClient);

  Future<CrearPublicacionResponse> crearPublicacion({
    required int idUsuario,
    required String material,
    required String descripcion,
  }) async {
    final data = await _supabaseClient.rpc(
      'crear_publicacion',
      params: {
        'p_id_usuario': idUsuario,
        'p_material': material,
        'p_descripcion': descripcion,
      },
    );

    return CrearPublicacionResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<List<PublicacionDetalleModel>> obtenerPublicaciones({String? estado}) async {
    final data = await _supabaseClient.rpc(
      'obtener_publicaciones',
      params: {
        if (estado != null) 'p_estado': estado,
      },
    );

    final lista = data as List<dynamic>;
    return lista
        .map((json) => PublicacionDetalleModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<AceptarRecoleccionResponse> aceptarRecoleccion({
    required int idPublicacion,
    required int idUsuarioRecolector,
  }) async {
    final data = await _supabaseClient.rpc(
      'aceptar_recoleccion',
      params: {
        'p_id_publicacion': idPublicacion,
        'p_id_usuario_recolector': idUsuarioRecolector,
      },
    );

    return AceptarRecoleccionResponse.fromJson(data as Map<String, dynamic>);
  }
}
