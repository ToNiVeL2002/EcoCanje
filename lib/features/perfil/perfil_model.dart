import 'package:ecocanje/features/login/login_model.dart';
import 'package:equatable/equatable.dart';

class TransaccionEcocuponModel extends Equatable {
  final int idTransaccion;
  final int cantidadEcocupones;
  final int? saldoResultante;
  final String tipoTransaccion;
  final String motivo;
  final String? detalle;
  final DateTime? fecha;
  final String nombreOrigen;

  const TransaccionEcocuponModel({
    required this.idTransaccion,
    required this.cantidadEcocupones,
    this.saldoResultante,
    required this.tipoTransaccion,
    required this.motivo,
    this.detalle,
    this.fecha,
    required this.nombreOrigen,
  });

  bool get esIngreso => cantidadEcocupones >= 0;

  factory TransaccionEcocuponModel.fromJson(Map<String, dynamic> json) {
    return TransaccionEcocuponModel(
      idTransaccion: json['id_transaccion'] as int,
      cantidadEcocupones: (json['cantidad_ecocupones'] as int?) ?? 0,
      saldoResultante: json['saldo_resultante'] as int?,
      tipoTransaccion: (json['tipo_transaccion'] as String?) ?? 'TRANSACCION',
      motivo: (json['motivo'] as String?) ?? '',
      detalle: json['detalle'] as String?,
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : null,
      nombreOrigen: (json['nombre_origen'] as String?) ?? 'SISTEMA',
    );
  }

  @override
  List<Object?> get props => [
        idTransaccion,
        cantidadEcocupones,
        saldoResultante,
        tipoTransaccion,
        motivo,
        detalle,
        fecha,
        nombreOrigen,
      ];
}

class MiPublicacionResumenModel extends Equatable {
  final int idPublicacion;
  final String material;
  final String descripcion;
  final String estado;
  final DateTime? fecha;
  final int? idEntrega;

  const MiPublicacionResumenModel({
    required this.idPublicacion,
    required this.material,
    required this.descripcion,
    required this.estado,
    this.fecha,
    this.idEntrega,
  });

  factory MiPublicacionResumenModel.fromJson(Map<String, dynamic> json) {
    return MiPublicacionResumenModel(
      idPublicacion: json['id_publicacion'] as int,
      material: (json['material'] as String?) ?? '',
      descripcion: (json['descripcion'] as String?) ?? '',
      estado: (json['estado'] as String?) ?? 'DISPONIBLE',
      fecha: json['fecha_publicacion'] != null
          ? DateTime.parse(json['fecha_publicacion'] as String)
          : null,
      idEntrega: json['id_entrega'] as int?,
    );
  }

  @override
  List<Object?> get props => [idPublicacion, material, descripcion, estado, fecha, idEntrega];
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
