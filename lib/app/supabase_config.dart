import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {

  static const String url = 'https://ckbowwzzhjvuxxrbftxx.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNrYm93d3p6aGp2dXh4cmJmdHh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzMzk1OTUsImV4cCI6MjA5OTkxNTU5NX0.BfCYzS-NzZvxYF6Mgn4PGV-DKhnVo9XLhZdk5dcRLmw';

}


Future<void> initSupabase() async {
  // assert(
  //   SupabaseConfig.url.isNotEmpty && SupabaseConfig.anonKey.isNotEmpty,
  //   'Faltan las credenciales de Supabase. Corre con:\n'
  //   'flutter run --dart-define-from-file=.env',
  // );
 
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
}