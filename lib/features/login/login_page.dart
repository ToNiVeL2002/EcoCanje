import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ecocanje/app/app_theme.dart';
import 'package:ecocanje/features/login/cubit/login_cubit.dart';


class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _celularCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _iniciarSesion(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().login(_celularCtrl.text.trim());
    }
  }

  void _irARegistro(BuildContext context) {
    context.push('/registro');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // scaffoldBackgroundColor viene del tema global
      body: BlocConsumer<LoginCubit, LoginState>(
            listener: (context, state) {
              switch (state) {
                case UserExists():
                  final tipo = state.item.tipoUsuario?.toUpperCase() ?? 'USUARIO';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Bienvenido ${state.item.nombre ?? ''}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Segmentación por tipo de usuario
                  if (tipo == 'EMPRESA' || tipo == 'PUNTO_ACOPIO') {
                    context.go('/recepcion', extra: state.item);
                  } else {
                    context.go('/home', extra: state.item);
                  }

                case UserDoesNotExists():
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No registrado. ¿Quieres registrar una cuenta?',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  _irARegistro(context);

                case LoginError():
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );

                default:
                  break;
              }
            },
            builder: (context, state) {
              switch (state) {
                case LoginLoading():
                  return const Center(child: CircularProgressIndicator());

                default:
                  return _buildForm(context, state);
              }
            },
      ),
    );
  }

  Widget _buildForm(BuildContext context, LoginState state) {
    final isLoading = state is LoginLoading;
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // Logo / ícono
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.recycling,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Título
            Text(
              'EcoCanje',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: cs.primaryContainer,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Recicla. Acumula. Canjea.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: cs.primary),
            ),
            const SizedBox(height: 48),

            // Formulario — los estilos vienen del inputDecorationTheme global
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _celularCtrl,
                    keyboardType: TextInputType.phone,
                    enabled: !isLoading,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ingresa tu número de celular';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Número de celular',
                      hintText: 'Ej: 04121232',
                      prefixIcon: Icon(Icons.phone_android),
                      // filled, fillColor, borders → vienen del tema global
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ElevatedButton — estilo viene del elevatedButtonTheme global
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _iniciarSesion(context),
                      child: const Text('Iniciar sesión'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Enlace a registro
                  TextButton(
                    onPressed: isLoading ? null : () => _irARegistro(context),
                    child: RichText(
                      text: TextSpan(
                        text: '¿No tienes cuenta? ',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Regístrate aquí',
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
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
