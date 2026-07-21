import 'package:ecocanje/app/app_theme.dart';
import 'package:ecocanje/features/publicaciones/cubit/publicaciones_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CrearPublicacionesPage extends StatelessWidget {
  const CrearPublicacionesPage({super.key});

  static const List<String> _materialesPermitidos = [
    'CARTON',
    'PAPEL',
    'VIDRIO',
    'PLASTICO',
    'LATAS',
  ];

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final descripcionCtrl = TextEditingController();
    final materialNotifier = ValueNotifier<String?>(null);

    void submit(BuildContext context) {
      if (formKey.currentState!.validate()) {
        final material = materialNotifier.value;
        final descripcion = descripcionCtrl.text.trim();

        if (material == null || material.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, selecciona un tipo de material.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        context.read<PublicacionesCubit>().crearPublicacion(
              material: material,
              descripcion: descripcion,
            );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Publicación'),
      ),
      body: BlocConsumer<PublicacionesCubit, PublicacionesState>(
        listener: (context, state) {
          if (state is PublicacionCreadaExito) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: AppTheme.primary,
              ),
            );
            descripcionCtrl.clear();
            materialNotifier.value = null;
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
          final isCreando = state is PublicacionCreando;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Publica tu material reciclable',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ingresa los datos del material para que un recolector pueda recogerlo.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Dropdown Tipo de Material
                  ValueListenableBuilder<String?>(
                    valueListenable: materialNotifier,
                    builder: (context, selectedMaterial, _) {
                      return DropdownButtonFormField<String>(
                        value: selectedMaterial,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Selecciona un tipo de material';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Material',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _materialesPermitidos.map((mat) {
                          return DropdownMenuItem<String>(
                            value: mat,
                            child: Text(mat),
                          );
                        }).toList(),
                        onChanged: isCreando
                            ? null
                            : (value) {
                                materialNotifier.value = value;
                              },
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo Descripción
                  TextFormField(
                    controller: descripcionCtrl,
                    maxLines: 4,
                    enabled: !isCreando,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ingresa una descripción del material';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Ej: 2 cajas grandes de cartón dobladas.',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón Publicar
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isCreando ? null : () => submit(context),
                      child: isCreando
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Publicar Material'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}