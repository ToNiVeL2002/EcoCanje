import 'package:ecocanje/features/recolecciones/recolecciones_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecoleccionesRepository {
  final SupabaseClient _supabaseClient;

  RecoleccionesRepository(this._supabaseClient);

  Future<List<RecoleccionModel>> obtenerRecoleccionesUsuario({
    required int idUsuarioRecolector,
    String? estado,
  }) async {
    final String? filtroEstado =
        (estado == null || estado == 'TODAS' || estado == 'TODOS') ? null : estado;

    final data = await _supabaseClient.rpc(
      'obtener_recolecciones_usuario',
      params: {
        'p_id_usuario_recolector': idUsuarioRecolector,
        if (filtroEstado != null) 'p_estado': filtroEstado,
      },
    );

    final lista = data as List<dynamic>;
    return lista
        .map((json) => RecoleccionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
