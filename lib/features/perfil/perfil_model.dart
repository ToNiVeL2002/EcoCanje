import 'package:ecocanje/features/login/login_model.dart';
import 'package:equatable/equatable.dart';

class TransaccionEcocuponModel extends Equatable {
  final String id;
  final String concepto;
  final int puntos;
  final DateTime fecha;
  final bool esIngreso;

  const TransaccionEcocuponModel({
    required this.id,
    required this.concepto,
    required this.puntos,
    required this.fecha,
    required this.esIngreso,
  });

  @override
  List<Object?> get props => [id, concepto, puntos, fecha, esIngreso];
}

class MiPublicacionResumenModel extends Equatable {
  final int idPublicacion;
  final String material;
  final String descripcion;
  final String estado;
  final DateTime fecha;

  const MiPublicacionResumenModel({
    required this.idPublicacion,
    required this.material,
    required this.descripcion,
    required this.estado,
    required this.fecha,
  });

  @override
  List<Object?> get props => [idPublicacion, material, descripcion, estado, fecha];
}

class PerfilModel extends Equatable {
  final LoginModel loginData;
  final List<TransaccionEcocuponModel> transacciones;
  final List<MiPublicacionResumenModel> misPublicaciones;

  const PerfilModel({
    required this.loginData,
    required this.transacciones,
    required this.misPublicaciones,
  });

  @override
  List<Object?> get props => [loginData, transacciones, misPublicaciones];
}
