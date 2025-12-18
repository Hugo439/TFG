import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  int _selectedIndex = 1;
  int get selectedIndex => _selectedIndex;

  void select(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
