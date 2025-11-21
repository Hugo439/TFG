import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/app/splash_gate.dart';
import 'package:smartmeal/presentation/features/auth/view/login_view.dart';
import 'package:smartmeal/presentation/features/auth/view/register_view.dart';
import 'package:smartmeal/presentation/features/home/view/home_view.dart';
import 'package:smartmeal/presentation/features/profile/view/profile_view.dart';
import 'package:smartmeal/presentation/features/profile/view/edit_profile_view.dart';
import 'package:smartmeal/presentation/features/menu/view/menu_view.dart';
import 'package:smartmeal/presentation/features/shopping/view/shopping_view.dart';
import 'package:smartmeal/presentation/features/shopping/view/add_shopping_item_view.dart';
import 'package:smartmeal/presentation/features/settings/view/settings_view.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String menu = '/menu';
  static const String shopping = '/shopping';
  static const String addShoppingItem = '/add-shopping-item';
  static const String settings = '/settings';

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashGate());
      case login:
        final email = routeSettings.arguments as String?;
        return MaterialPageRoute(builder: (_) => LoginView(prefilledEmail: email));
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterView());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileView());
      case editProfile:
        final profile = routeSettings.arguments as UserProfile;
        return MaterialPageRoute(builder: (_) => EditProfileView(profile: profile));
      case menu:
        return MaterialPageRoute(builder: (_) => const MenuView());
      case shopping:
        return MaterialPageRoute(builder: (_) => const ShoppingView());
      case addShoppingItem:
        final item = routeSettings.arguments as ShoppingItem?;
        return MaterialPageRoute(
          builder: (_) => AddShoppingItemView(itemToEdit: item),
        );
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsView());
      default:
        return null;
    }
  }
}