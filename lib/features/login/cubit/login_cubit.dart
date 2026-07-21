import 'package:bloc/bloc.dart';
import 'package:ecocanje/features/login/login_model.dart';
import 'package:ecocanje/features/login/login_repository.dart';
import 'package:equatable/equatable.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepository _loginRepository;

  LoginCubit(this._loginRepository) : super(LoginInitial());

  Future<void> login(String celular) async {
    emit(LoginLoading());
    try {
      final LoginModel user = await _loginRepository.buscarPorCelular(celular);

      if (user.isSuccesfull) {
        emit(UserExists(user));
      } else {
        emit(UserDoesNotExists());
      }
    } catch (e) {
      emit(LoginError('Error al cargar: $e'));
    }
  }

  Future<void> registrar({
    required String usuario,
    required String celular,
    required String nombre,
    required String apellido,
  }) async {
    emit(LoginLoading());
    try {
      final result = await _loginRepository.registrarUsuario(
        usuario: usuario,
        celular: celular,
        nombre: nombre,
        apellido: apellido,
      );

      final exito = result['o_exito'] as bool;
      final mensaje = result['o_mensaje'] as String;

      if (exito) {
        emit(SuccesfulRegistration(mensaje));
      } else {
        emit(LoginError(mensaje));
      }
    } catch (e) {
      emit(LoginError('Error al registrar: $e'));
    }
  }
}
