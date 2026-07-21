import 'package:ecocanje/app/app_router.dart';
import 'package:ecocanje/app/app_theme.dart';
import 'package:ecocanje/app/supabase_config.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme.theme,
    );
  }
}