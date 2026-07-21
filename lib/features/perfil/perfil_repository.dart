import 'package:ecocanje/features/login/login_model.dart';
import 'package:ecocanje/features/perfil/perfil_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilRepository {
  final SupabaseClient _supabaseClient;

  PerfilRepository(this._supabaseClient);

  Future<PerfilModel> cargarPerfilUsuario(LoginModel loginData) async {
    final transacciones = [
      TransaccionEcocuponModel(
        id: '1',
        concepto: 'Reciclaje de Cartón completado',
        puntos: 50,
        fecha: DateTime.now().subtract(const Duration(days: 1)),
        esIngreso: true,
      ),
      TransaccionEcocuponModel(
        id: '2',
        concepto: 'Reciclaje de Plástico y Latas',
        puntos: 35,
        fecha: DateTime.now().subtract(const Duration(days: 3)),
        esIngreso: true,
      ),
      TransaccionEcocuponModel(
        id: '3',
        concepto: 'Bono de bienvenida EcoCanje',
        puntos: 20,
        fecha: DateTime.now().subtract(const Duration(days: 7)),
        esIngreso: true,
      ),
    ];

    final misPublicaciones = [
      MiPublicacionResumenModel(
        idPublicacion: 101,
        material: 'CARTON',
        descripcion: '2 Cajas de cartón corrugado limpias',
        estado: 'DISPONIBLE',
        fecha: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      MiPublicacionResumenModel(
        idPublicacion: 102,
        material: 'PLASTICO',
        descripcion: 'Botellas PET aplastadas 5kg',
        estado: 'OCUPADA',
        fecha: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    return PerfilModel(
      loginData: loginData,
      transacciones: transacciones,
      misPublicaciones: misPublicaciones,
    );
  }
}
