import 'package:ecocanje/features/home/cubit/home_cubit.dart';
import 'package:ecocanje/features/home/home_page.dart';
import 'package:ecocanje/features/login/cubit/login_cubit.dart';
import 'package:ecocanje/features/login/login_model.dart';
import 'package:ecocanje/features/login/login_page.dart';
import 'package:ecocanje/features/login/login_repository.dart';
import 'package:ecocanje/features/login/registro_page.dart';
import 'package:ecocanje/features/mapa/cubit/mapa_cubit.dart';
import 'package:ecocanje/features/mapa/mapa_repository.dart';
import 'package:ecocanje/features/perfil/cubit/perfil_cubit.dart';
import 'package:ecocanje/features/perfil/perfil_repository.dart';
import 'package:ecocanje/features/publicaciones/cubit/publicaciones_cubit.dart';
import 'package:ecocanje/features/publicaciones/publicaciones_repository.dart';
import 'package:ecocanje/features/recepcion/cubit/recepcion_cubit.dart';
import 'package:ecocanje/features/recepcion/recepcion_page.dart';
import 'package:ecocanje/features/recepcion/recepcion_repository.dart';
import 'package:ecocanje/features/recolecciones/cubit/recolecciones_cubit.dart';
import 'package:ecocanje/features/recolecciones/recolecciones_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => BlocProvider(
        create: (_) => LoginCubit(LoginRepository(Supabase.instance.client)),
        child: LoginPage(),
      ),
    ),
    GoRoute(
      path: '/registro',
      builder: (context, state) => BlocProvider(
        create: (_) => LoginCubit(LoginRepository(Supabase.instance.client)),
        child: const RegistroPage(),
      ),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final usuario = state.extra as LoginModel?;
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => HomeCubit()),
            BlocProvider(
              create: (_) => PublicacionesCubit(
                PublicacionesRepository(Supabase.instance.client),
                usuarioId: usuario?.idUsuario,
              ),
            ),
            BlocProvider(
              create: (_) => RecoleccionesCubit(
                RecoleccionesRepository(Supabase.instance.client),
                usuarioId: usuario?.idUsuario,
              ),
            ),
            BlocProvider(
              create: (_) => MapaCubit(
                MapaRepository(Supabase.instance.client),
              ),
            ),
            BlocProvider(
              create: (_) => PerfilCubit(
                PerfilRepository(Supabase.instance.client),
                loginModel: usuario,
              ),
            ),
          ],
          child: const HomePage(),
        );
      },
    ),
    // Ruta exclusiva para usuarios EMPRESA / PUNTO_ACOPIO
    GoRoute(
      path: '/recepcion',
      builder: (context, state) {
        final usuario = state.extra as LoginModel?;
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => RecepcionCubit(
                RecepcionRepository(Supabase.instance.client),
                idUsuarioConfirmador: usuario?.idUsuario ?? 0,
                tipoUsuarioConfirmador: usuario?.tipoUsuario ?? 'EMPRESA',
              ),
            ),
            BlocProvider(
              create: (_) => PerfilCubit(
                PerfilRepository(Supabase.instance.client),
                loginModel: usuario,
              ),
            ),
          ],
          child: const RecepcionPage(),
        );
      },
    ),
  ],
);
