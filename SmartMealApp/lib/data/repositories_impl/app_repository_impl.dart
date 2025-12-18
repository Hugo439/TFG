import 'package:smartmeal/domain/repositories/app_repository.dart';

class AppRepositoryImpl implements AppRepository {
  @override
  Future<void> initialize() async {
    // Firebase ya se inicializa en service_locator.dart
    // Este método ahora está vacío pero se mantiene por si se necesita
    // inicializar otras dependencias en el futuro
  }
}
