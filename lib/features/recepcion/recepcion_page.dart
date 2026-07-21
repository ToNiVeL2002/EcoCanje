import 'package:ecocanje/app/app_theme.dart';
import 'package:ecocanje/features/perfil/cubit/perfil_cubit.dart';
import 'package:ecocanje/features/recepcion/cubit/recepcion_cubit.dart';
import 'package:ecocanje/features/recepcion/recepcion_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RecepcionPage extends StatelessWidget {
  const RecepcionPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final celularCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final filtroNotifier = ValueNotifier<String>('TODOS');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recepción de Material'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.red),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Deseas cerrar la sesión actual?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<PerfilCubit>().cerrarSesion();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<PerfilCubit, PerfilState>(
        listener: (context, state) {
          if (state is PerfilSesionCerrada) {
            context.go('/login');
          }
        },
        child: BlocConsumer<RecepcionCubit, RecepcionState>(
          listener: (context, state) {
            if (state is RecepcionEntregaExitosa) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  icon: const Icon(Icons.check_circle, color: AppTheme.primary, size: 48),
                  title: const Text('¡Entrega Exitosa!'),
                  content: Text(state.mensaje),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<RecepcionCubit>().resetear();
                      },
                      child: const Text('Nueva Recepción'),
                    ),
                  ],
                ),
              );
            } else if (state is RecepcionUsuarioNoEncontrado) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usuario no encontrado. Verifica el número de celular.'),
                  backgroundColor: Colors.orange,
                ),
              );
            } else if (state is RecepcionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.mensaje),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is RecepcionBuscandoUsuario || state is RecepcionProcesandoEntrega) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RecepcionUsuarioEncontrado) {
              return _buildUsuarioEncontrado(
                context,
                state.usuario,
                state.recoleccionesActivas,
                filtroNotifier,
              );
            }

            // Estado inicial / reset: formulario de búsqueda
            return _buildFormularioBusqueda(context, celularCtrl, formKey);
          },
        ),
      ),
    );
  }

  // Formulario para buscar un usuario por celular
  Widget _buildFormularioBusqueda(
    BuildContext context,
    TextEditingController celularCtrl,
    GlobalKey<FormState> formKey,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),

          // Ícono descriptivo
          const Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: AppTheme.surfaceVariant,
              child: Icon(Icons.qr_code_scanner, size: 42, color: AppTheme.primaryDark),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Buscar Usuario',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ingresa el número de celular del usuario que realizará la entrega de material reciclable.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 32),

          Form(
            key: formKey,
            child: TextFormField(
              controller: celularCtrl,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa el número de celular';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Número de celular',
                hintText: 'Ej: 04121232',
                prefixIcon: Icon(Icons.phone_android),
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<RecepcionCubit>().buscarUsuario(celularCtrl.text.trim());
                }
              },
              icon: const Icon(Icons.search),
              label: const Text('Buscar Usuario', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // Vista después de encontrar un usuario
  Widget _buildUsuarioEncontrado(
    BuildContext context,
    UsuarioBuscadoModel usuario,
    List<RecoleccionEntregaModel> recolecciones,
    ValueNotifier<String> filtroNotifier,
  ) {
    return Column(
      children: [
        // Tarjeta de info del usuario
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary,
                child: Text(
                  usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nombreCompleto,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    Text(
                      'Tel: ${usuario.celular}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                tooltip: 'Nueva Búsqueda',
                onPressed: () => context.read<RecepcionCubit>().resetear(),
              ),
            ],
          ),
        ),

        // Decidir qué mostrar según las recolecciones
        if (recolecciones.isEmpty)
          _buildEntregaDirectaView(context, usuario)
        else
          _buildRecoleccionView(context, usuario, recolecciones, filtroNotifier),
      ],
    );
  }

  // CASO 1: Entrega Directa (sin recolecciones)
  Widget _buildEntregaDirectaView(BuildContext context, UsuarioBuscadoModel usuario) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.inbox_outlined, size: 64, color: AppTheme.primaryDark),
            const SizedBox(height: 12),
            const Text(
              'Este usuario no tiene recolecciones activas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Se procederá a una entrega directa.\nEl usuario recibirá +10 EcoCupones.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Confirmar Entrega Directa'),
                      content: Text(
                        '¿Confirmar la entrega directa de ${usuario.nombreCompleto}?\n\n'
                        'El usuario recibirá +10 EcoCupones.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            context.read<RecepcionCubit>().procesarEntregaDirecta(usuario.idUsuario);
                          },
                          child: const Text('Confirmar'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 22),
                label: const Text(
                  'Registrar Entrega Directa (+10 EC)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CASO 2: Entrega de Recolección (con publicaciones activas)
  Widget _buildRecoleccionView(
    BuildContext context,
    UsuarioBuscadoModel usuario,
    List<RecoleccionEntregaModel> recolecciones,
    ValueNotifier<String> filtroNotifier,
  ) {
    return Expanded(
      child: Column(
        children: [
          // Barra de Filtros por Material
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ValueListenableBuilder<String>(
                valueListenable: filtroNotifier,
                builder: (context, filtroActual, _) {
                  return Row(
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
                  );
                },
              ),
            ),
          ),

          // Lista de Recolecciones + Botón Recibir
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: filtroNotifier,
              builder: (context, filtro, _) {
                final filtradas = recolecciones.where((r) {
                  if (filtro == 'TODOS') return true;
                  return r.material.toUpperCase() == filtro.toUpperCase();
                }).toList();

                if (filtradas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.filter_alt_off, size: 48, color: AppTheme.primaryDark),
                        const SizedBox(height: 12),
                        Text(
                          'No hay recolecciones de "$filtro".',
                          style: const TextStyle(fontSize: 14, color: AppTheme.primaryDark),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Header info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filtradas.length} recolección(es) ${filtro == "TODOS" ? "" : "de $filtro"}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                          Text(
                            '+${filtradas.length * 5} EC recolector',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Lista de tarjetas
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtradas.length,
                        itemBuilder: (context, index) {
                          final rec = filtradas[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.surfaceVariant,
                                child: Icon(
                                  _getMaterialIcon(rec.material),
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                              title: Text(
                                rec.material,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(rec.descripcion),
                                  Text(
                                    'Proveedor: ${rec.nombreCreador}',
                                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                                  ),
                                ],
                              ),
                              trailing: Chip(
                                label: const Text(
                                  '+5 EC',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.green.shade600,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Botón Recibir
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Confirmar Recepción'),
                                  content: Text(
                                    '¿Recibir ${filtradas.length} publicación(es) '
                                    '${filtro == "TODOS" ? "" : "de $filtro "}de ${usuario.nombreCompleto}?\n\n'
                                    '• +5 EC al proveedor de cada publicación\n'
                                    '• +5 EC al recolector por cada publicación',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                        context.read<RecepcionCubit>().procesarEntregaRecoleccion(
                                              idUsuarioRecolector: usuario.idUsuario,
                                              recoleccionesSeleccionadas: filtradas,
                                            );
                                      },
                                      child: const Text('Confirmar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.local_shipping, size: 22),
                            label: Text(
                              'Recibir ${filtradas.length} publicación(es)',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
