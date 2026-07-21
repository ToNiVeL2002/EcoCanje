import 'package:ecocanje/features/login/login_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginRepository {
  final SupabaseClient _supabaseClient;
  LoginRepository(this._supabaseClient);

  Future<LoginModel> buscarPorCelular(String celular) async {
    final data = await _supabaseClient.rpc(
      'login_usuario',
      params: {'p_celular': celular},
    );

    return LoginModel.fromJson(data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> registrarUsuario({
    required String usuario,
    required String celular,
    required String nombre,
    required String apellido,
  }) async {
    final data = await _supabaseClient.rpc(
      'registrar_usuario',
      params: {
        'p_usuario': usuario,
        'p_celular': celular,
        'p_nombre': nombre,
        'p_apellido': apellido,
      },
    );

    return data as Map<String, dynamic>;
  }
}