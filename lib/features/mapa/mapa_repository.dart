import 'package:ecocanje/features/mapa/mapa_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapaRepository {
  final SupabaseClient _supabaseClient;

  MapaRepository(this._supabaseClient);

  Future<List<UbicacionMapaModel>> obtenerUbicacionesMapa() async {
    final data = await _supabaseClient.rpc('obtener_ubicaciones_mapa');
    final lista = data as List<dynamic>;
    return lista
        .map((json) => UbicacionMapaModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
