import 'package:flutter/foundation.dart';

/// ViewModel para navegación de pantalla principal.
///
/// Responsabilidad:
/// - Gestionar índice de tab seleccionado en BottomNavigationBar
///
/// Tabs:
/// 0. **Compras**: lista de compra
/// 1. **Menús**: menús semanales (tab por defecto)
/// 2. **Perfil**: perfil de usuario
///
/// Uso:
/// ```dart
/// final vm = Provider.of<HomeViewModel>(context);
/// BottomNavigationBar(
///   currentIndex: vm.selectedIndex,
///   onTap: vm.select,
/// )
/// ```
class HomeViewModel extends ChangeNotifier {
  int _selectedIndex = 1;
  int get selectedIndex => _selectedIndex;

  /// Cambia el tab seleccionado.
  ///
  /// Parámetros:
  /// - **index**: índice del tab (0=Compras, 1=Menús, 2=Perfil)
  void select(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
