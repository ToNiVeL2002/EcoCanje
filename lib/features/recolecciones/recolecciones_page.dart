import 'package:ecocanje/app/app_theme.dart';
import 'package:ecocanje/features/recolecciones/cubit/recolecciones_cubit.dart';
import 'package:ecocanje/features/recolecciones/recolecciones_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecoleccionesPage extends StatelessWidget {
  const RecoleccionesPage({super.key});

  static const List<Map<String, String>> _filtrosEstado = [
    {'clave': 'TODAS', 'nombre': 'Todas'},
    {'clave': 'ACTIVA', 'nombre': 'Activas'},
    {'clave': 'COMPLETADA', 'nombre': 'Completadas'},
    {'clave': 'CANCELADA', 'nombre': 'Canceladas'},
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
      case 'ACTIVA':
        return AppTheme.primary;
      case 'COMPLETADA':
        return Colors.blue.shade800;
      case 'CANCELADA':
        return Colors.red.shade700;
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
    final filtroEstadoNotifier = ValueNotifier<String>('TODAS');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recolecciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<RecoleccionesCubit>().cargarRecolecciones();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra superior de filtro por estado
          _buildFilterBar(filtroEstadoNotifier),

          // Listado de recolecciones
          Expanded(
            child: BlocConsumer<RecoleccionesCubit, RecoleccionesState>(
              listener: (context, state) {
                if (state is RecoleccionesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.mensaje),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is RecoleccionesCargadas) {
                  return ValueListenableBuilder<String>(
                    valueListenable: filtroEstadoNotifier,
                    builder: (context, filtroSeleccionado, _) {
                      final recoleccionesFiltradas = state.recolecciones.where((rec) {
                        if (filtroSeleccionado == 'TODAS') return true;
                        return rec.estadoRecoleccion.toUpperCase() == filtroSeleccionado.toUpperCase();
                      }).toList();

                      if (recoleccionesFiltradas.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () => context.read<RecoleccionesCubit>().cargarRecolecciones(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.6,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.backpack_outlined,
                                    size: 64,
                                    color: AppTheme.primaryDark,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    filtroSeleccionado == 'TODAS'
                                        ? 'No tienes recolecciones aceptadas aún.'
                                        : 'No tienes recolecciones en estado "$filtroSeleccionado".',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppTheme.primaryDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (filtroSeleccionado != 'TODAS') ...[
                                    const SizedBox(height: 16),
                                    TextButton.icon(
                                      onPressed: () {
                                        filtroEstadoNotifier.value = 'TODAS';
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
                        onRefresh: () => context.read<RecoleccionesCubit>().cargarRecolecciones(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: recoleccionesFiltradas.length,
                          itemBuilder: (context, index) {
                            final rec = recoleccionesFiltradas[index];
                            return _buildRecoleccionCard(context, rec);
                          },
                        ),
                      );
                    },
                  );
                }

                if (state is RecoleccionesCargando) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Carga automática inicial si entra en cualquier otro estado
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final cubit = context.read<RecoleccionesCubit>();
                  if (cubit.state is! RecoleccionesCargadas && cubit.state is! RecoleccionesCargando) {
                    cubit.cargarRecolecciones();
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
              children: _filtrosEstado.map((f) {
                final clave = f['clave']!;
                final nombre = f['nombre']!;
                final isSelected = filtroActual == clave;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    avatar: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                    label: Text(nombre),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.primaryDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    backgroundColor: AppTheme.surfaceVariant,
                    selectedColor: AppTheme.primary,
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
      ),
    );
  }

  Widget _buildRecoleccionCard(BuildContext context, RecoleccionModel rec) {
    final estadoColor = _getEstadoColor(rec.estadoRecoleccion);

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
            // Cabecera: Usuario Creador e Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.surfaceVariant,
                  child: Icon(
                    _getMaterialIcon(rec.material),
                    color: AppTheme.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec.nombreCreador.isNotEmpty ? rec.nombreCreador : 'Usuario Creador',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      if (rec.celularCreador.isNotEmpty)
                        Text(
                          'Tel: ${rec.celularCreador}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),

                // Badge Estado Recolección
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: estadoColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    rec.estadoRecoleccion,
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

            // Material y Fecha Aceptación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: Icon(_getMaterialIcon(rec.material), size: 18, color: Colors.white),
                  label: Text(
                    rec.material,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                if (rec.fechaAceptacion != null)
                  Text(
                    'Aceptado: ${_formatFecha(rec.fechaAceptacion)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Descripción
            Text(
              rec.descripcion,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // Estado Informativo / Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: estadoColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: estadoColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    rec.estadoRecoleccion.toUpperCase() == 'COMPLETADA'
                        ? Icons.check_circle_outline
                        : (rec.estadoRecoleccion.toUpperCase() == 'CANCELADA'
                            ? Icons.cancel_outlined
                            : Icons.local_shipping_outlined),
                    size: 20,
                    color: estadoColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec.estadoRecoleccion.toUpperCase() == 'ACTIVA'
                          ? 'Recolección en proceso — Dirigete al punto de entrega más cercano.'
                          : (rec.estadoRecoleccion.toUpperCase() == 'COMPLETADA'
                              ? 'Recolección completada con éxito.'
                              : 'Recolección cancelada.'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: estadoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}