import 'package:bloc/bloc.dart';
import 'package:ecocanje/features/login/login_model.dart';
import 'package:ecocanje/features/perfil/perfil_model.dart';
import 'package:ecocanje/features/perfil/perfil_repository.dart';
import 'package:equatable/equatable.dart';

part 'perfil_state.dart';

class PerfilCubit extends Cubit<PerfilState> {
  final PerfilRepository _repository;
  final LoginModel? _loginModel;

  PerfilCubit(this._repository, {LoginModel? loginModel})
      : _loginModel = loginModel,
        super(PerfilInitial());

  Future<void> cargarPerfil() async {
    emit(PerfilCargando());
    try {
      final user = _loginModel ??
          const LoginModel(
            isSuccesfull: true,
            idUsuario: 1,
            usuario: 'eco_usuario',
            nombre: 'Usuario',
            apellido: 'EcoCanje',
            saldoEcocupones: 105,
            tipoUsuario: 'CIUDADANO',
          );

      final perfil = await _repository.cargarPerfilUsuario(user);
      emit(PerfilCargado(perfil));
    } catch (e) {
      emit(PerfilError('Error al cargar perfil: $e'));
    }
  }
}
