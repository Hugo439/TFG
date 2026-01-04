import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartmeal/core/di/price_system_di.dart';
import 'package:smartmeal/core/di/app_di.dart';
import 'package:smartmeal/core/di/auth_di.dart';
import 'package:smartmeal/core/di/menus_di.dart';
import 'package:smartmeal/core/di/recipes_di.dart';
import 'package:smartmeal/core/di/shopping_di.dart';
import 'package:smartmeal/core/di/statistics_di.dart';
import 'package:smartmeal/core/di/support_di.dart';
import 'package:smartmeal/data/datasources/remote/price_datasource.dart';
import 'package:smartmeal/data/repositories_impl/price_repository_impl.dart';

// Repositories
import 'package:smartmeal/domain/repositories/price_repository.dart';
import 'package:smartmeal/domain/repositories/user_repository.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';
import 'package:smartmeal/domain/repositories/statistics_repository.dart';

// Repository Implementations
import 'package:smartmeal/data/repositories_impl/user_repository_impl.dart';

// Data Sources
import 'package:smartmeal/data/datasources/local/auth_local_datasource.dart';
import 'package:smartmeal/data/datasources/local/shopping_local_datasource.dart';
import 'package:smartmeal/data/datasources/local/weekly_menu_local_datasource.dart';
import 'package:smartmeal/data/datasources/local/faq_local_datasource.dart';
import 'package:smartmeal/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:smartmeal/data/datasources/remote/firestore_datasource.dart';
import 'package:smartmeal/data/datasources/remote/menu_datasource.dart';
import 'package:smartmeal/data/datasources/remote/shopping_datasource.dart';
import 'package:smartmeal/data/datasources/remote/gemini_menu_datasource.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_aggregator.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_parser.dart';
import 'package:smartmeal/domain/services/shopping/smart_category_helper.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';
import 'package:smartmeal/domain/services/shopping/cost_estimator.dart';
import 'package:smartmeal/domain/usecases/auth/load_saved_credentials_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/save_credentials_usecase.dart';
import 'package:smartmeal/domain/usecases/menus/generate_weekly_menu_usecase.dart';

// Use Cases - App
// (módulos DI)

// Use Cases - Auth
import 'package:smartmeal/domain/usecases/auth/sign_in_usecase.dart';
import 'package:smartmeal/domain/usecases/user/get_current_user_usecase.dart';

// Use Cases - Profile
import 'package:smartmeal/domain/usecases/user/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/profile/update_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/profile/upload_profile_photo_usecase.dart';

// Use Cases - Shopping
import 'package:smartmeal/domain/usecases/shopping/initialize_price_database_usecase.dart';

// Use Cases - Recipes & Weekly Menus
import 'package:smartmeal/domain/usecases/menus/save_menu_recipes_usecase.dart';
import 'package:smartmeal/presentation/features/auth/viewmodel/login_view_model.dart';

// ViewModels
import 'package:smartmeal/presentation/features/menu/viewmodel/menu_view_model.dart';
import 'package:smartmeal/presentation/features/menu/viewmodel/generate_menu_view_model.dart';
import 'package:smartmeal/core/services/fcm_service.dart';

/// Service Locator central de la aplicación usando GetIt.
///
/// Responsabilidades:
/// - Registro de dependencias (DI)
/// - Singleton pattern para servicios
/// - Factory pattern para casos de uso
/// - Modularización con DI sub-modules
///
/// GetIt (sl):
/// - Singleton global: sl = GetIt.instance
/// - Acceso: sl<T>() para obtener instancia
/// - Tipos de registro:
///   * registerLazySingleton: instancia única lazy
///   * registerSingleton: instancia única eager
///   * registerFactory: nueva instancia cada vez
///
/// setupServiceLocator():
/// - Función async de inicialización
/// - Llamada desde main() antes de runApp
/// - Orden de registro:
///   1. External dependencies (Firebase, SharedPreferences)
///   2. Data Sources (local y remote)
///   3. Repositories
///   4. Services
///   5. Use Cases
///   6. ViewModels
///   7. Sub-modules (setupXXX)
///
/// External dependencies:
/// - SharedPreferences: persistencia local
/// - FirebaseAuth: autenticación
/// - FirebaseFirestore: base de datos
///
/// Data Sources:
/// - Local: AuthLocalDataSource, ShoppingLocalDatasource, etc.
/// - Remote: FirebaseAuthDatasource, FirestoreDatasource, etc.
///
/// Sub-modules:
/// - setupAuthDI(): auth use cases, repositories, ViewModels
/// - setupMenusDI(): menu generation, weekly menus
/// - setupRecipesDI(): recipe management
/// - setupShoppingDI(): shopping list, aggregation, prices
/// - setupStatisticsDI(): statistics calculation
/// - setupSupportDI(): FAQs, support messages
/// - setupPriceSystemDI(): price database, estimation
/// - setupAppDI(): app-level dependencies
///
/// Services registrados:
/// - FCMService: Firebase Cloud Messaging
/// - IngredientAggregator: agregación de ingredientes
/// - IngredientParser: parsing de cantidades
/// - SmartCategoryHelper: categorización inteligente
/// - SmartIngredientNormalizer: normalización de nombres
/// - CostEstimator: estimación de costos
///
/// ViewModels registrados:
/// - LoginViewModel: Singleton para mantener estado
/// - MenuViewModel: Singleton para cache de menús
/// - GenerateMenuViewModel: Singleton para generación
/// - Otros ViewModels: registrados en sus respectivos sub-modules
///
/// Patrones de uso:
/// ```dart
/// // Obtener instancia
/// final repo = sl<UserRepository>();
///
/// // Inyectar en constructor
/// class UseCase {
///   final Repository repo;
///   UseCase(this.repo);
/// }
/// sl.registerFactory(() => UseCase(sl()));
///
/// // En widgets
/// final vm = sl<MenuViewModel>();
/// ```
///
/// Ventajas:
/// - Desacoplamiento de código
/// - Facilita testing (mocks)
/// - Singleton automático
/// - Lazy initialization
/// - Organización modular
final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // ===== DATA SOURCES =====
  sl.registerLazySingleton(() => AuthLocalDataSource());
  sl.registerLazySingleton(() => ShoppingLocalDatasource(sl()));
  sl.registerLazySingleton(() => WeeklyMenuLocalDatasource(sl()));
  sl.registerLazySingleton(() => FAQLocalDatasource(sl()));
  sl.registerLazySingleton(() => FirebaseAuthDataSource(auth: sl()));
  sl.registerLazySingleton(() => FirestoreDataSource(firestore: sl()));
  sl.registerLazySingleton(() => MenuDataSource(firestore: sl(), auth: sl()));
  sl.registerLazySingleton(
    () => ShoppingDataSource(firestore: sl(), auth: sl()),
  );
  sl.registerLazySingleton(() => GeminiMenuDatasource());
  sl.registerLazySingleton<PriceDatasource>(
    () => FirestorePriceDatasource(sl<FirebaseFirestore>()),
  );
  // Registro movido a setupPriceSystemDI(sl) para evitar duplicados
  // de UserPriceFirestoreDatasource.

  // ===== SERVICES =====
  sl.registerLazySingleton<FCMService>(
    () => FCMService(firestoreDataSource: sl<FirestoreDataSource>()),
  );

  sl.registerLazySingleton(() => SmartCategoryHelper());
  sl.registerLazySingleton(() => SmartIngredientNormalizer());
  sl.registerLazySingleton(
    () => PriceEstimator(
      getIngredientPriceUseCase: sl(),
      getPricesByCategoryUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => CostEstimator(
      sl<PriceEstimator>(),
      sl<SmartCategoryHelper>(),
      sl<SmartIngredientNormalizer>(),
      IngredientParser(),
    ),
  );

  // ===== REPOSITORIES =====
  // App/Auth/Menu/Recipe/Statistics/Support repos movidos a módulos DI

  sl.registerLazySingleton<PriceRepository>(
    () => PriceRepositoryImpl(sl<PriceDatasource>()),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(authDataSource: sl(), firestoreDataSource: sl()),
  );

  // Menu/Shopping/Recipe/WeeklyMenu/Statistics/Support repos movidos a módulos DI

  // ===== USE CASES - APP ===== (módulo DI)
  sl.registerLazySingleton(() => InitializePriceDatabaseUseCase());

  // ===== USE CASES - AUTH ===== (módulo DI)

  // ===== USE CASES - PROFILE =====
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadProfilePhotoUseCase(sl()));

  // ===== USE CASES - MENU ===== (módulo DI)

  // ===== USE CASES - SHOPPING ===== (módulo DI)

  // ===== USE CASES - RECIPES ===== (módulo DI)

  // ===== USE CASES - STATISTICS ===== (módulo DI)

  // ===== USE CASES - SUPPORT ===== (módulo DI)

  // ===== MODULAR DI =====
  setupAppDI(sl);
  setupAuthDI(sl);
  setupMenusDI(sl);
  setupRecipesDI(sl);
  setupStatisticsDI(sl);
  setupSupportDI(sl);
  setupShoppingDI(sl);
  setupPriceSystemDI(sl);

  // ===== VIEW MODELS =====
  sl.registerLazySingleton(
    () => LoginViewModel(
      sl<SignInUseCase>(),
      sl<LoadSavedCredentialsUseCase>(),
      sl<SaveCredentialsUseCase>(),
    ),
  );

  sl.registerLazySingleton<MenuViewModel>(() => MenuViewModel());

  sl.registerLazySingleton(
    () => GenerateMenuViewModel(
      sl<GetUserProfileUseCase>(),
      sl<GetCurrentUserUseCase>(),
      sl<GenerateWeeklyMenuUseCase>(),
      sl<WeeklyMenuRepository>(),
      sl<SaveMenuRecipesUseCase>(),
      sl<StatisticsRepository>(),
    ),
  );

  // Not registered globally: StatisticsViewModel is created per-route
}
