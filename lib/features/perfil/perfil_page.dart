import 'package:ecocanje/app/app_theme.dart';
import 'package:ecocanje/features/perfil/cubit/perfil_cubit.dart';
import 'package:ecocanje/features/perfil/perfil_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  String _formatFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
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

  void _mostrarConfirmacionCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar la sesión actual?'),
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
  }

  @override
  Widget build(BuildContext context) {
    final tabNotifier = ValueNotifier<int>(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil & Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              context.read<PerfilCubit>().cargarPerfil();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.red),
            tooltip: 'Cerrar Sesión',
            onPressed: () => _mostrarConfirmacionCerrarSesion(context),
          ),
        ],
      ),
      body: BlocConsumer<PerfilCubit, PerfilState>(
        listener: (context, state) {
          if (state is PerfilSesionCerrada) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesión cerrada exitosamente.'),
                backgroundColor: AppTheme.primaryDark,
              ),
            );
            context.go('/login');
          } else if (state is PerfilError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PerfilCargando || state is PerfilCerrandoSesion) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PerfilCargado) {
            final perfil = state.perfil;
            final user = perfil.loginData;
            final nombreCompleto = '${user.nombre ?? ''} ${user.apellido ?? ''}'.trim();
            final iniciales = (user.nombre != null && user.nombre!.isNotEmpty)
                ? user.nombre![0].toUpperCase()
                : 'U';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Cabecera de Perfil de Usuario
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primary,
                        child: Text(
                          iniciales,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
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
                              nombreCompleto.isNotEmpty ? nombreCompleto : 'Usuario EcoCanje',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '@${user.usuario ?? 'usuario'}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Badge Tipo de Usuario
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryDark.withOpacity(0.3)),
                        ),
                        child: Text(
                          (user.tipoUsuario ?? 'CIUDADANO').toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 2. Tarjeta Estilo Banco / Wallet para EcoCupones
                  _buildBankCard(context, user),

                  const SizedBox(height: 24),

                  // 3. Pestañas de Navegación entre Listas
                  ValueListenableBuilder<int>(
                    valueListenable: tabNotifier,
                    builder: (context, currentTab, _) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTabButton(
                                  titulo: 'Mis Publicaciones',
                                  isSelected: currentTab == 0,
                                  onTap: () => tabNotifier.value = 0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTabButton(
                                  titulo: 'Historial Canjes',
                                  isSelected: currentTab == 1,
                                  onTap: () => tabNotifier.value = 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Contenido según la pestaña activa
                          currentTab == 0
                              ? _buildListaMisPublicaciones(perfil.misPublicaciones)
                              : _buildListaHistorialTransacciones(perfil.transacciones),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // 4. Botón inferior de Cerrar Sesión
                  OutlinedButton.icon(
                    onPressed: () => _mostrarConfirmacionCerrarSesion(context),
                    icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                    label: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          }

          // Carga automática inicial si no ha cargado aún
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final cubit = context.read<PerfilCubit>();
            if (cubit.state is! PerfilCargado &&
                cubit.state is! PerfilCargando &&
                cubit.state is! PerfilCerrandoSesion &&
                cubit.state is! PerfilSesionCerrada) {
              cubit.cargarPerfil();
            }
          });

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // Tarjeta Bancaria / Wallet de EcoCupones
  Widget _buildBankCard(BuildContext context, dynamic user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryDark,
            AppTheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila Superior: Marca Wallet y Chip bancario
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white70,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'EcoCanje Wallet',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.nfc,
                  color: Colors.white54,
                  size: 26,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Saldo Destacado (EcoCupones)
            const Text(
              'SALDO DISPONIBLE',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${user.saldoEcocupones ?? 0}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'EC',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ID de Tarjeta & Botón de Canjear
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ID USUARIO',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '**** **** **** ${(user.idUsuario ?? 1).toString().padLeft(4, '0')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),

                // Botón de Canje de EcoCupones
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Próximamente podrás canjear tus EcoCupones por premios!'),
                        backgroundColor: AppTheme.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.card_giftcard, size: 18),
                  label: const Text(
                    'Canjear',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryDark,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Botón de Pestaña personalizada
  Widget _buildTabButton({
    required String titulo,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          titulo,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Lista 1: Mis Publicaciones
  Widget _buildListaMisPublicaciones(List<MiPublicacionResumenModel> publicaciones) {
    if (publicaciones.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text('No tienes publicaciones creadas aún.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: publicaciones.length,
      itemBuilder: (context, index) {
        final pub = publicaciones[index];
        final estadoColor = _getEstadoColor(pub.estado);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.surfaceVariant,
              child: const Icon(Icons.recycling, color: AppTheme.primaryDark),
            ),
            title: Text(
              pub.material,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pub.descripcion),
                if (pub.fecha != null)
                  Text(
                    'Fecha: ${_formatFecha(pub.fecha!)}',
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
              ],
            ),
            trailing: Chip(
              label: Text(
                pub.estado,
                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: estadoColor,
              padding: EdgeInsets.zero,
            ),
          ),
        );
      },
    );
  }

  // Lista 2: Historial de Transacciones de EcoCupones
  Widget _buildListaHistorialTransacciones(List<TransaccionEcocuponModel> transacciones) {
    if (transacciones.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text('No hay transacciones registradas.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transacciones.length,
      itemBuilder: (context, index) {
        final tx = transacciones[index];
        final titulo = tx.motivo.isNotEmpty ? tx.motivo : tx.tipoTransaccion;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: tx.esIngreso ? Colors.green.shade50 : Colors.orange.shade50,
              child: Icon(
                tx.esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                color: tx.esIngreso ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Origen: ${tx.nombreOrigen}'),
                if (tx.fecha != null)
                  Text(
                    _formatFecha(tx.fecha!),
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
              ],
            ),
            trailing: Text(
              '${tx.esIngreso ? "+" : ""}${tx.cantidadEcocupones} EC',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: tx.esIngreso ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
        );
      },
    );
  }
}