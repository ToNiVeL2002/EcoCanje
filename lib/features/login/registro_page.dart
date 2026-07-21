import 'package:ecocanje/app/app_theme.dart';
import 'package:ecocanje/features/login/cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _celularCtrl.dispose();
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    super.dispose();
  }

  void _registrar() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().registrar(
        usuario: _usuarioCtrl.text.trim(),
        celular: _celularCtrl.text.trim(),
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor y AppBar vienen del tema global
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is SuccesfulRegistration) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppTheme.primary,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        child: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            final isLoading = state is LoginLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // Ícono decorativo
                    const Icon(
                      Icons.eco_rounded,
                      size: 64,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Únete a EcoCanje',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Campos — inputDecorationTheme aplica automáticamente
                    _buildTextField(
                      controller: _usuarioCtrl,
                      label: 'Nombre de usuario',
                      hint: 'Ej: juan_perez',
                      icon: Icons.alternate_email,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa un nombre de usuario';
                        }
                        if (v.trim().length > 50) return 'Máximo 50 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _celularCtrl,
                      label: 'Número de celular',
                      hint: 'Ej: 04121234567',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa tu número de celular';
                        }
                        if (v.trim().length > 20) return 'Número muy largo';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _nombreCtrl,
                      label: 'Nombre',
                      hint: 'Ej: Juan',
                      icon: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa tu nombre';
                        }
                        if (v.trim().length > 100)
                          return 'Máximo 100 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _apellidoCtrl,
                      label: 'Apellido',
                      hint: 'Ej: Pérez',
                      icon: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa tu apellido';
                        }
                        if (v.trim().length > 100)
                          return 'Máximo 100 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // ElevatedButton — estilo viene del elevatedButtonTheme global
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _registrar,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Crear cuenta'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: RichText(
                        text: const TextSpan(
                          text: '¿Ya tienes cuenta? ',
                          style: TextStyle(color: Colors.black54),
                          children: [
                            TextSpan(
                              text: 'Inicia sesión',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Los estilos de borde, fill y label vienen del inputDecorationTheme global.
  // Solo especificamos lo específico de cada campo: label, hint, icon y validator.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        // El resto (filled, fillColor, borders) lo maneja el tema global
      ),
    );
  }
}
