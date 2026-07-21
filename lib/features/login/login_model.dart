import 'package:equatable/equatable.dart';

class LoginModel extends Equatable {
  final bool isSuccesfull;
  final int? idUsuario;
  final String? usuario;
  final String? nombre;
  final String? apellido;
  final int? saldoEcocupones;
  final String? tipoUsuario;

  const LoginModel({
    required this.isSuccesfull,
    this.idUsuario,
    this.usuario,
    this.nombre,
    this.apellido,
    this.saldoEcocupones,
    this.tipoUsuario,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      isSuccesfull: json['o_exito'] as bool,
      idUsuario: json['o_id_usuario'] as int?,
      usuario: json['o_usuario'] as String?,
      nombre: json['o_nombre'] as String?,
      apellido: json['o_apellido'] as String?,
      saldoEcocupones: json['o_saldo_ecocupones'] as int?,
      tipoUsuario: json['o_tipo_usuario'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        isSuccesfull,
        idUsuario,
        usuario,
        nombre,
        apellido,
        saldoEcocupones,
        tipoUsuario,
      ];
}
