part of 'perfil_cubit.dart';

sealed class PerfilState extends Equatable {
  const PerfilState();

  @override
  List<Object?> get props => [];
}

final class PerfilInitial extends PerfilState {}

final class PerfilCargando extends PerfilState {}

final class PerfilCargado extends PerfilState {
  final PerfilModel perfil;

  const PerfilCargado(this.perfil);

  @override
  List<Object?> get props => [perfil];
}

final class PerfilCerrandoSesion extends PerfilState {}

final class PerfilSesionCerrada extends PerfilState {}

final class PerfilError extends PerfilState {
  final String mensaje;

  const PerfilError(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}
