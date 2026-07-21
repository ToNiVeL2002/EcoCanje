import 'package:ecocanje/features/login/login_model.dart';
import 'package:ecocanje/features/perfil/perfil_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilRepository {
  final SupabaseClient _supabaseClient;

  PerfilRepository(this._supabaseClient);

  Future<List<MiPublicacionResumenModel>> obtenerPublicacionesUsuario(int idUsuario) async {
    final data = await _supabaseClient.rpc(
      'obtener_publicaciones_usuario',
      params: {'p_id_usuario': idUsuario},
    );

    final lista = data as List<dynamic>;
    return lista
        .map((json) => MiPublicacionResumenModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<TransaccionEcocuponModel>> obtenerHistorialTransacciones(int idUsuario) async {
    final data = await _supabaseClient.rpc(
      'obtener_historial_transacciones',
      params: {'p_id_usuario': idUsuario},
    );

    final lista = data as List<dynamic>;
    return lista
        .map((json) => TransaccionEcocuponModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PerfilModel> cargarPerfilUsuario(LoginModel loginData) async {
    List<MiPublicacionResumenModel> misPublicaciones = [];
    List<TransaccionEcocuponModel> transacciones = [];

    if (loginData.idUsuario != null) {
      try {
        misPublicaciones = await obtenerPublicacionesUsuario(loginData.idUsuario!);
      } catch (_) {
        misPublicaciones = [];
      }

      try {
        transacciones = await obtenerHistorialTransacciones(loginData.idUsuario!);
      } catch (_) {
        transacciones = [];
      }
    }

    return PerfilModel(
      loginData: loginData,
      transacciones: transacciones,
      misPublicaciones: misPublicaciones,
    );
  }
}
