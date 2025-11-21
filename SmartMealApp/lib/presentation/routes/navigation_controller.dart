import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/routes/routes.dart';

class NavigationController {
  static void navigateToIndex(BuildContext context, int index, int currentIndex) {
    if (index == currentIndex) return; // Ya estamos aquí

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(Routes.menu);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(Routes.home);
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed(Routes.shopping);
        break;
    }
  }

  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.home);
  }

  static void navigateToMenu(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.menu);
  }

  static void navigateToShopping(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(Routes.shopping);
  }
}