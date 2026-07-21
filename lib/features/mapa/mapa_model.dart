import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class UbicacionMapaModel extends Equatable {
  final int id;
  final String tipo; // 'EMPRESA' o 'PUNTO_ACOPIO'
  final String nombre;
  final String ubicacionRaw;
  final String direccion;
  final String telefono;
  final double latitude;
  final double longitude;

  const UbicacionMapaModel({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.ubicacionRaw,
    required this.direccion,
    required this.telefono,
    required this.latitude,
    required this.longitude,
  });

  LatLng get position => LatLng(latitude, longitude);

  factory UbicacionMapaModel.fromJson(Map<String, dynamic> json) {
    final rawUbi = (json['ubicacion'] as String?) ?? '';
    double lat = -17.3895; // Centro por defecto (Cochabamba / Bolivia)
    double lng = -66.1568;

    if (rawUbi.isNotEmpty && rawUbi.contains(',')) {
      final parts = rawUbi.split(',');
      if (parts.length >= 2) {
        final parsedLat = double.tryParse(parts[0].trim());
        final parsedLng = double.tryParse(parts[1].trim());
        if (parsedLat != null && parsedLng != null) {
          lat = parsedLat;
          lng = parsedLng;
        }
      }
    }

    return UbicacionMapaModel(
      id: json['id'] as int,
      tipo: (json['tipo'] as String?) ?? 'PUNTO_ACOPIO',
      nombre: (json['nombre'] as String?) ?? '',
      ubicacionRaw: rawUbi,
      direccion: (json['direccion'] as String?) ?? '',
      telefono: (json['telefono'] as String?) ?? '',
      latitude: lat,
      longitude: lng,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tipo,
        nombre,
        ubicacionRaw,
        direccion,
        telefono,
        latitude,
        longitude,
      ];
}
