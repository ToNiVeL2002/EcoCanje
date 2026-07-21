import 'package:ecocanje/app/app_theme.dart';
import 'package:ecocanje/features/home/cubit/home_cubit.dart';
import 'package:ecocanje/features/mapa/mapa_page.dart';
import 'package:ecocanje/features/perfil/perfil_page.dart';
import 'package:ecocanje/features/publicaciones/crear_publicaciones_page.dart';

import 'package:ecocanje/features/publicaciones/ver_publicaciones_page.dart';
import 'package:ecocanje/features/recolecciones/recolecciones_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<Widget> _pages = [
    CrearPublicacionesPage(),
    MapaPage(),
    VerPublicacionesPage(),
    RecoleccionesPage(),
    PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.tabIndex,
            children: _pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: state.tabIndex,
            onDestinationSelected: (int index) {
              context.read<HomeCubit>().cambiarTab(index);
            },
            backgroundColor: AppTheme.surfaceVariant,
            indicatorColor: AppTheme.primary.withOpacity(0.2),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryDark),
                selectedIcon: Icon(Icons.add_circle, color: AppTheme.primary),
                label: 'Crear',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined, color: AppTheme.primaryDark),
                selectedIcon: Icon(Icons.map, color: AppTheme.primary),
                label: 'Mapa',
              ),
              NavigationDestination(
                icon: Icon(Icons.view_list_outlined, color: AppTheme.primaryDark),
                selectedIcon: Icon(Icons.view_list, color: AppTheme.primary),
                label: 'Publicaciones',
              ),
              NavigationDestination(
                icon: Icon(Icons.backpack_outlined, color: AppTheme.primaryDark),
                selectedIcon: Icon(Icons.backpack, color: AppTheme.primary),
                label: 'mochila',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: AppTheme.primaryDark),
                selectedIcon: Icon(Icons.person, color: AppTheme.primary),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}