import 'package:ecocanje/app/app_theme.dart';
import 'package:ecocanje/features/mapa/cubit/mapa_cubit.dart';
import 'package:ecocanje/features/mapa/mapa_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaPage extends StatelessWidget {
  const MapaPage({super.key});

  static const List<Map<String, String>> _filtrosTipo = [
    {'clave': 'TODOS', 'nombre': 'Todos'},
    {'clave': 'PUNTO_ACOPIO', 'nombre': 'Puntos de Acopio'},
    {'clave': 'EMPRESA', 'nombre': 'Empresas Recicladoras'},
  ];

  @override
  Widget build(BuildContext context) {
    final MapController mapController = MapController();
    final filtroTipoNotifier = ValueNotifier<String>('TODOS');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puntos & Empresas Recicladoras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MapaCubit>().cargarMapa();
            },
          ),
        ],
      ),
      body: BlocConsumer<MapaCubit, MapaState>(
        listener: (context, state) {
          if (state is MapaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MapaCargando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MapaCargado) {
            final ubicaciones = state.ubicaciones;
            final userPos = state.posicionUsuario;

            // Determinar centro del mapa: posición de usuario -> primera ubicación -> por defecto
            final LatLng centroInicial = userPos ??
                (ubicaciones.isNotEmpty
                    ? ubicaciones.first.position
                    : const LatLng(-17.3895, -66.1568));

            return Stack(
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: filtroTipoNotifier,
                  builder: (context, filtroSeleccionado, _) {
                    final ubicacionesFiltradas = ubicaciones.where((u) {
                      if (filtroSeleccionado == 'TODOS') return true;
                      return u.tipo.toUpperCase() == filtroSeleccionado.toUpperCase();
                    }).toList();

                    return FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: centroInicial,
                        initialZoom: 14.0,
                        maxZoom: 18.0,
                        minZoom: 4.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.ecocanje',
                        ),

                        // Capa de Marcadores (Puntos de acopio / Empresas / Usuario)
                        MarkerLayer(
                          markers: [
                            // Marcadores de Ubicaciones
                            ...ubicacionesFiltradas.map((ubi) {
                              final isEmpresa = ubi.tipo.toUpperCase() == 'EMPRESA';
                              final color = isEmpresa ? AppTheme.primaryDark : AppTheme.primary;
                              final iconData = isEmpresa ? Icons.factory_outlined : Icons.recycling;

                              return Marker(
                                point: ubi.position,
                                width: 48,
                                height: 48,
                                child: GestureDetector(
                                  onTap: () {
                                    _mostrarDetallesBottomSheet(context, ubi);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(color: color, width: 2.5),
                                    ),
                                    child: Icon(
                                      iconData,
                                      color: color,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              );
                            }),

                            // Marcador de Posición de Usuario (GPS)
                            if (userPos != null)
                              Marker(
                                point: userPos,
                                width: 44,
                                height: 44,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade600,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  child: const Icon(
                                    Icons.my_location,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                // Barra superior de Filtros
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: _buildFilterBar(filtroTipoNotifier),
                ),

                // Botón flotante para centrar mapa en ubicación del usuario (GPS)
                Positioned(
                  bottom: 24,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'btnGPS',
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      if (userPos != null) {
                        mapController.move(userPos, 15.5);
                      } else {
                        context.read<MapaCubit>().cargarMapa();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Obteniendo tu ubicación GPS...'),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            );
          }

          // Carga inicial automática si no se ha cargado
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final cubit = context.read<MapaCubit>();
            if (cubit.state is! MapaCargado && cubit.state is! MapaCargando) {
              cubit.cargarMapa();
            }
          });

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildFilterBar(ValueNotifier<String> filtroNotifier) {
    return ValueListenableBuilder<String>(
      valueListenable: filtroNotifier,
      builder: (context, filtroActual, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filtrosTipo.map((f) {
              final clave = f['clave']!;
              final nombre = f['nombre']!;
              final isSelected = filtroActual == clave;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  selected: isSelected,
                  showCheckmark: false,
                  avatar: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                  label: Text(nombre),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                  backgroundColor: Colors.white.withOpacity(0.92),
                  selectedColor: AppTheme.primary,
                  elevation: 3,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : Colors.transparent,
                    ),
                  ),
                  onSelected: (_) {
                    filtroNotifier.value = clave;
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _mostrarDetallesBottomSheet(BuildContext context, UbicacionMapaModel ubi) {
    final isEmpresa = ubi.tipo.toUpperCase() == 'EMPRESA';
    final color = isEmpresa ? AppTheme.primaryDark : AppTheme.primary;
    final tipoTexto = isEmpresa ? 'Empresa Recicladora' : 'Punto de Acopio';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de arrastre superior
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cabecera: Badge de Tipo + Icono
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tipoTexto.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nombre
              Text(
                ubi.nombre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 16),

              // Dirección
              if (ubi.direccion.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ubi.direccion,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Teléfono
              if (ubi.telefono.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.phone, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      ubi.telefono,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Coordenadas GPS
              Row(
                children: [
                  const Icon(Icons.map_outlined, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Lat: ${ubi.latitude.toStringAsFixed(4)}, Lng: ${ubi.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botón de Cerrar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
