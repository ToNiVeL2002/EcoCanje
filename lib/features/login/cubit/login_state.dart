part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class UserExists extends LoginState {
  final LoginModel item;
  const UserExists(this.item);

  @override
  List<Object> get props => [item];
}

final class UserDoesNotExists extends LoginState {}

final class SuccesfulRegistration extends LoginState {
  final String mensaje;
  const SuccesfulRegistration(this.mensaje);

  @override
  List<Object> get props => [mensaje];
}

final class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);

  @override
  List<Object> get props => [message];
}
