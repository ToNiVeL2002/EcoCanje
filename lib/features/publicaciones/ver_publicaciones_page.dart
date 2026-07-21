import 'package:ecocanje/app/app_theme.dart';
import 'package:ecocanje/features/publicaciones/cubit/publicaciones_cubit.dart';
import 'package:ecocanje/features/publicaciones/publicaciones_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerPublicacionesPage extends StatelessWidget {
  const VerPublicacionesPage({super.key});

  static const List<Map<String, String>> _filtrosMateriales = [
    {'clave': 'TODOS', 'nombre': 'Todos'},
    {'clave': 'CARTON', 'nombre': 'Cartón'},
    {'clave': 'PAPEL', 'nombre': 'Papel'},
    {'clave': 'VIDRIO', 'nombre': 'Vidrio'},
    {'clave': 'PLASTICO', 'nombre': 'Plástico'},
    {'clave': 'LATAS', 'nombre': 'Latas'},
  ];

  IconData _getMaterialIcon(String material) {
    switch (material.toUpperCase()) {
      case 'CARTON':
        return Icons.inventory_2_outlined;
      case 'PAPEL':
        return Icons.description_outlined;
      case 'VIDRIO':
        return Icons.wine_bar_outlined;
      case 'PLASTICO':
        return Icons.local_drink_outlined;
      case 'LATAS':
        return Icons.view_in_ar_outlined;
      default:
        return Icons.recycling;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'DISPONIBLE':
        return AppTheme.primary;
      case 'OCUPADA':
        return Colors.orange.shade800;
      case 'ENTREGADA':
        return Colors.blue.shade800;
      default:
        return AppTheme.primaryDark;
    }
  }

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return '';
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final filtroMaterialNotifier = ValueNotifier<String>('TODOS');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones Disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PublicacionesCubit>().cargarPublicaciones();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra superior de filtros por material
          _buildFilterBar(filtroMaterialNotifier),

          // Listado filtrado de publicaciones
          Expanded(
            child: BlocConsumer<PublicacionesCubit, PublicacionesState>(
              listener: (context, state) {
                if (state is RecoleccionAceptadaExito) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.mensaje),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                } else if (state is PublicacionesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.mensaje),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is PublicacionesCargadas) {
                  return ValueListenableBuilder<String>(
                    valueListenable: filtroMaterialNotifier,
                    builder: (context, filtroSeleccionado, _) {
                      final publicacionesFiltradas = state.publicaciones.where((
                        pub,
                      ) {
                        if (filtroSeleccionado == 'TODOS') return true;
                        return pub.material.toUpperCase() ==
                            filtroSeleccionado.toUpperCase();
                      }).toList();

                      if (publicacionesFiltradas.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () => context
                              .read<PublicacionesCubit>()
                              .cargarPublicaciones(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.6,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: AppTheme.primaryDark,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    filtroSeleccionado == 'TODOS'
                                        ? 'No hay publicaciones registradas aún.'
                                        : 'No hay publicaciones para el material "$filtroSeleccionado".',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppTheme.primaryDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (filtroSeleccionado != 'TODOS') ...[
                                    const SizedBox(height: 16),
                                    TextButton.icon(
                                      onPressed: () {
                                        filtroMaterialNotifier.value = 'TODOS';
                                      },
                                      icon: const Icon(Icons.filter_alt_off),
                                      label: const Text('Mostrar todas'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => context
                            .read<PublicacionesCubit>()
                            .cargarPublicaciones(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: publicacionesFiltradas.length,
                          itemBuilder: (context, index) {
                            final pub = publicacionesFiltradas[index];
                            return _buildPublicacionCard(context, pub);
                          },
                        ),
                      );
                    },
                  );
                }

                if (state is PublicacionesCargando) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Si entra en cualquier otro estado (ej: PublicacionesInitial), gatilla la carga automáticamente
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final cubit = context.read<PublicacionesCubit>();
                  if (cubit.state is! PublicacionesCargadas &&
                      cubit.state is! PublicacionesCargando) {
                    cubit.cargarPublicaciones();
                  }
                });

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ValueNotifier<String> filtroNotifier) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ValueListenableBuilder<String>(
        valueListenable: filtroNotifier,
        builder: (context, filtroActual, _) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filtrosMateriales.map((f) {
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
                        : (clave != 'TODOS'
                              ? Icon(
                                  _getMaterialIcon(clave),
                                  size: 16,
                                  color: AppTheme.primaryDark,
                                )
                              : null),
                    label: Text(nombre),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.primaryDark,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    backgroundColor: AppTheme.surfaceVariant,
                    selectedColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primary
                            : Colors.transparent,
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
      ),
    );
  }

  Widget _buildPublicacionCard(
    BuildContext context,
    PublicacionDetalleModel pub,
  ) {
    final estadoColor = _getEstadoColor(pub.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Usuario e Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.surfaceVariant,
                  child: Icon(
                    _getMaterialIcon(pub.material),
                    color: AppTheme.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pub.nombreUsuario.isNotEmpty
                            ? pub.nombreUsuario
                            : 'Usuario Anónimo',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      if (pub.celularUsuario.isNotEmpty)
                        Text(
                          'Tel: ${pub.celularUsuario}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),

                // Badge Estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: estadoColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    pub.estado,
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Material y Fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: Icon(
                    _getMaterialIcon(pub.material),
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    pub.material,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                if (pub.fechaPublicacion != null)
                  Text(
                    _formatFecha(pub.fechaPublicacion),
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Dirección / Ubicación
            if (pub.direccion != null && pub.direccion!.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.primaryDark),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pub.direccion!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Descripción
            Text(
              pub.descripcion,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 16),

            // Botón de Acción: Aceptar Recolección
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: pub.estado.toUpperCase() == 'DISPONIBLE'
                    ? () {
                        context.read<PublicacionesCubit>().aceptarRecoleccion(
                              idPublicacion: pub.idPublicacion,
                            );
                      }
                    : null,
                icon: const Icon(Icons.local_shipping_outlined, size: 20),
                label: Text(
                  pub.estado.toUpperCase() == 'DISPONIBLE'
                      ? 'Me encargo de la entrega'
                      : 'Recolección ${pub.estado.toLowerCase()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
