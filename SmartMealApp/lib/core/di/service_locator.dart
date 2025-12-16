import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartmeal/core/di/price_system_di.dart';
import 'package:smartmeal/data/datasources/remote/price_datasource.dart';
import 'package:smartmeal/data/repositories_impl/price_repository_impl.dart';

// Repositories
import 'package:smartmeal/domain/repositories/app_repository.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';
import 'package:smartmeal/domain/repositories/price_repository.dart';
import 'package:smartmeal/domain/repositories/user_repository.dart';
import 'package:smartmeal/domain/repositories/menu_repository.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';
import 'package:smartmeal/domain/repositories/support_message_repository.dart';
import 'package:smartmeal/domain/repositories/menu_generation_repository.dart';

// Repository Implementations
import 'package:smartmeal/data/repositories_impl/app_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/auth_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/user_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/menu_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/shopping_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/recipe_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/weekly_menu_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/support_message_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/menu_generation_repository_impl.dart';

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
import 'package:smartmeal/domain/usecases/auth/load_saved_credentials_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/save_credentials_usecase.dart';
import 'package:smartmeal/domain/usecases/menus/generate_weekly_menu_usecase.dart';

// Use Cases - App
import 'package:smartmeal/domain/usecases/initialize_app_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/check_auth_status_usecase.dart';

// Use Cases - Auth
import 'package:smartmeal/domain/usecases/auth/sign_in_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/sign_up_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/sign_out_usecase.dart';
import 'package:smartmeal/domain/usecases/user/get_current_user_usecase.dart';

// Use Cases - Profile
import 'package:smartmeal/domain/usecases/user/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/profile/update_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/profile/upload_profile_photo_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/delete_account_usecase.dart';

// Use Cases - Shopping
import 'package:smartmeal/domain/usecases/shopping/get_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/add_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/toggle_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/get_total_price_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/generate_shopping_from_menus_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/delete_checked_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/set_all_shopping_items_checked_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/get_prices_by_category_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/estimate_ingredient_price_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/initialize_price_database_usecase.dart';

// Use Cases - Recipes & Weekly Menus
import 'package:smartmeal/domain/usecases/menus/save_menu_recipes_usecase.dart';
import 'package:smartmeal/domain/usecases/menus/get_recipe_by_id_usecase.dart';
import 'package:smartmeal/domain/usecases/support/get_support_messages_usecase.dart';
import 'package:smartmeal/presentation/features/auth/viewmodel/login_view_model.dart';

// ViewModels
import 'package:smartmeal/presentation/features/menu/viewmodel/menu_view_model.dart';
import 'package:smartmeal/presentation/features/menu/viewmodel/generate_menu_view_model.dart';
import 'package:smartmeal/core/services/fcm_service.dart';

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
  sl.registerLazySingleton(() => ShoppingDataSource(firestore: sl(), auth: sl()));
  sl.registerLazySingleton(() => GeminiMenuDatasource());
  sl.registerLazySingleton<PriceDatasource>(
    () => FirestorePriceDatasource(sl<FirebaseFirestore>()),
  );
  // Registro movido a setupPriceSystemDI(sl) para evitar duplicados
  // de UserPriceFirestoreDatasource.

  // ===== SERVICES =====
  sl.registerLazySingleton<FCMService>(
    () => FCMService(
      firestoreDataSource: sl<FirestoreDataSource>(),
    ),
  );

  sl.registerLazySingleton(() => SmartCategoryHelper());
  sl.registerLazySingleton(() => SmartIngredientNormalizer());
  sl.registerLazySingleton(() => PriceEstimator(
        getIngredientPriceUseCase: sl(),
        getPricesByCategoryUseCase: sl(),
      ));

  // ===== REPOSITORIES =====
  sl.registerLazySingleton<AppRepository>(
    () => AppRepositoryImpl(),
  );

  sl.registerLazySingleton<MenuGenerationRepository>(
    () => MenuGenerationRepositoryImpl(sl<GeminiMenuDatasource>()),
  );

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    authDataSource: sl(),
    authLocalDataSource: sl(),
    firestoreDataSource: sl(),
  ));

  sl.registerLazySingleton<PriceRepository>(
    () => PriceRepositoryImpl(sl<PriceDatasource>()),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      authDataSource: sl(),
      firestoreDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(
      dataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ShoppingRepository>(
    () => ShoppingRepositoryImpl(
      dataSource: sl(),
      userPriceDatasource: sl(),
      localDatasource: sl(),
      auth: sl(),
    ),
  );

  sl.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<WeeklyMenuRepository>(
    () => WeeklyMenuRepositoryImpl(sl(), sl(), sl()),
  );

  sl.registerLazySingleton<SupportMessageRepository>(
    () => SupportMessageRepositoryImpl(),
  );

  // ===== USE CASES - APP =====
  sl.registerLazySingleton(() => InitializeAppUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => InitializePriceDatabaseUseCase());

  // ===== USE CASES - AUTH =====
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LoadSavedCredentialsUseCase(sl()));
  sl.registerLazySingleton(() => SaveCredentialsUseCase(sl()));

  // ===== USE CASES - PROFILE =====
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadProfilePhotoUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));

  // ===== USE CASES - MENU =====
  sl.registerLazySingleton(() => SaveMenuRecipesUseCase(sl()));
  sl.registerLazySingleton(() => GenerateWeeklyMenuUseCase(sl<MenuGenerationRepository>()));

  // ===== USE CASES - SHOPPING =====
  sl.registerLazySingleton(() => GetShoppingItemsUseCase(sl()));
  sl.registerLazySingleton(() => AddShoppingItemUseCase(sl()));
  sl.registerLazySingleton(() => ToggleShoppingItemUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalPriceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCheckedShoppingItemsUseCase(sl()));
  sl.registerLazySingleton(() => SetAllShoppingItemsCheckedUseCase(sl()));
  sl.registerLazySingleton(() => GetPricesByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => EstimateIngredientPriceUseCase(sl()));
  sl.registerLazySingleton(() => GenerateShoppingFromMenusUseCase(
    menuRepository: sl(),
    shoppingRepository: sl(),
    parser: IngredientParser(),
    aggregator: IngredientAggregator(),
    priceEstimator: sl<PriceEstimator>(),
    categoryHelper: sl<SmartCategoryHelper>(),
    normalizer: sl<SmartIngredientNormalizer>(),
  ));

  // ===== USE CASES - RECIPES & WEEKLY MENUS =====
  sl.registerLazySingleton<GetRecipeByIdUseCase>(
    () => GetRecipeByIdUseCase(sl<RecipeRepository>())
  );

  // ===== USE CASES - SUPPORT =====
  sl.registerLazySingleton(() => GetSupportMessagesUseCase(sl()));

  // ===== PRICE SYSTEM =====
  setupPriceSystemDI(sl);

  // ===== VIEW MODELS =====
  sl.registerLazySingleton(() => LoginViewModel(
    sl<SignInUseCase>(),
    sl<LoadSavedCredentialsUseCase>(),
    sl<SaveCredentialsUseCase>(),
  ));

  sl.registerLazySingleton<MenuViewModel>(() => MenuViewModel());
  
  sl.registerLazySingleton(() => GenerateMenuViewModel(
    sl<GetUserProfileUseCase>(),
    sl<GetCurrentUserUseCase>(),
    sl<GenerateWeeklyMenuUseCase>(),
    sl<WeeklyMenuRepository>(),
    sl<SaveMenuRecipesUseCase>(),
  ));
}