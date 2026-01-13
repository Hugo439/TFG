import 'package:flutter/material.dart';
import 'package:smartmeal/presentation/app/splash_gate.dart';
import 'package:smartmeal/presentation/features/auth/view/login_view.dart';
import 'package:smartmeal/presentation/features/auth/view/register_view.dart';
import 'package:smartmeal/presentation/features/home/view/home_view.dart';
import 'package:smartmeal/presentation/features/profile/view/profile_view.dart';
import 'package:smartmeal/presentation/features/profile/view/edit_profile_view.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/presentation/features/menu/view/menu_view.dart';
import 'package:smartmeal/presentation/features/menu/view/generate_menu_view.dart';
import 'package:smartmeal/presentation/features/menu/view/recipe_detail_view.dart';
import 'package:smartmeal/presentation/features/menu/viewmodel/recipe_detail_view_model.dart';
import 'package:smartmeal/presentation/features/shopping/view/shopping_view.dart';
import 'package:smartmeal/presentation/features/shopping/view/add_shopping_item_view.dart';
import 'package:smartmeal/presentation/features/settings/view/settings_view.dart';
import 'package:smartmeal/presentation/features/support/view/support_view.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/presentation/features/statistics/view/statistics_view.dart';
import 'package:smartmeal/presentation/features/settings/view/privacy_policy_view.dart';
import 'package:smartmeal/presentation/features/settings/view/terms_conditions_view.dart';
import 'package:smartmeal/presentation/features/statistics/viewmodel/statistics_view_model.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/usecases/user/get_current_user_usecase.dart';
import 'package:smartmeal/domain/usecases/statistics/get_statistics_summary_usecase.dart';
import 'package:smartmeal/domain/usecases/user/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/entities/shopping_item.dart';

/// Configuración de rutas de la aplicación.
///
/// Responsabilidades:
/// - Definir rutas con nombres constantes
/// - onGenerateRoute: factory de rutas
/// - Pasar argumentos entre pantallas
/// - Configurar ViewModels con Provider
///
/// Rutas disponibles:
/// - **splash** (/): SplashGate (auth gate)
/// - **login** (/login): LoginView
/// - **register** (/register): RegisterView
/// - **home** (/home): HomeView (dashboard)
/// - **profile** (/profile): ProfileView
/// - **editProfile** (/edit-profile): EditProfileView
/// - **menu** (/menu): MenuView
/// - **generateMenu** (/generate-menu): GenerateMenuView
/// - **recipeDetail** (/recipe-detail): RecipeDetailView
/// - **shopping** (/shopping): ShoppingView
/// - **addShoppingItem** (/add-shopping-item): AddShoppingItemView
/// - **settings** (/settings): SettingsView
/// - **support** (/support): SupportView
/// - **statistics** (/statistics): StatisticsView
/// - **privacy** (/privacy): PrivacyPolicyView
/// - **terms** (/terms): TermsConditionsView
///
/// Argumentos:
/// - login: String? prefilledEmail
/// - editProfile: UserProfile profile
/// - recipeDetail: String recipeId
/// - addShoppingItem: ShoppingItem? item (opcional)
/// - statistics: sin argumentos, pero crea ViewModel con UseCases
///
/// Provider injection:
/// - recipeDetail: ChangeNotifierProvider<RecipeDetailViewModel>
/// - statistics: ChangeNotifierProvider<StatisticsViewModel>
/// - UseCases inyectados desde Service Locator (sl<T>)
///
/// Navegación:
/// ```dart
/// // Sin argumentos
/// Navigator.pushNamed(context, Routes.home);
///
/// // Con argumentos
/// Navigator.pushNamed(
///   context,
///   Routes.login,
///   arguments: 'user@example.com',
/// );
///
/// // Navegación global (desde main.dart)
/// navigatorKey.currentState!.pushNamed(Routes.support);
/// ```
///
/// Patrón:
/// - Rutas simples: MaterialPageRoute directo
/// - Rutas con ViewModel: Provider wrapping
/// - Rutas con argumentos: cast de routeSettings.arguments
///
/// Manejo de errores:
/// - Si ruta no existe: null (MaterialApp muestra error screen)
class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String menu = '/menu';
  static const String generateMenu = '/generate-menu';
  static const String recipeDetail = '/recipe-detail';
  static const String shopping = '/shopping';
  static const String addShoppingItem = '/add-shopping-item';
  static const String settings = '/settings';
  static const String support = '/support';
  static const String statistics = '/statistics';
  static const String privacy = '/privacy';
  static const String terms = '/terms';

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashGate());
      case login:
        final email = routeSettings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => LoginView(prefilledEmail: email),
        );
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterView());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileView());
      case editProfile:
        final profile = routeSettings.arguments as UserProfile;
        return MaterialPageRoute(
          builder: (_) => EditProfileView(profile: profile),
        );
      case menu:
        return MaterialPageRoute(builder: (_) => const MenuView());
      case generateMenu:
        return MaterialPageRoute(builder: (_) => const GenerateMenuView());
      case recipeDetail:
        final recipeId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => RecipeDetailViewModel(),
            child: RecipeDetailView(recipeId: recipeId),
          ),
        );
      case shopping:
        return MaterialPageRoute(builder: (_) => const ShoppingView());
      case addShoppingItem:
        final item = routeSettings.arguments as ShoppingItem?;
        return MaterialPageRoute(
          builder: (_) => AddShoppingItemView(itemToEdit: item),
        );
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsView());
      case support:
        return MaterialPageRoute(builder: (_) => const SupportView());
      case privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyView());
      case terms:
        return MaterialPageRoute(
          builder: (_) => const TermsAndConditionsView(),
        );
      case statistics:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: sl<StatisticsViewModel>(),
            child: const StatisticsView(),
          ),
        );
      default:
        return null;
    }
  }
}
