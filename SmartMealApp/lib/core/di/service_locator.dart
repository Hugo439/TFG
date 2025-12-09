import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Repositories
import 'package:smartmeal/domain/repositories/app_repository.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';
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
import 'package:smartmeal/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:smartmeal/data/datasources/remote/firestore_datasource.dart';
import 'package:smartmeal/data/datasources/remote/menu_datasource.dart';
import 'package:smartmeal/data/datasources/remote/shopping_datasource.dart';
import 'package:smartmeal/data/datasources/remote/gemini_menu_datasource.dart'; // ← CAMBIO AQUÍ
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
import 'package:smartmeal/domain/usecases/auth/delete_account_usecase.dart';

// Use Cases - Menu
import 'package:smartmeal/domain/usecases/get_menu_items_usecase.dart';
import 'package:smartmeal/domain/usecases/menus/get_recommended_menu_items_usecase.dart';
import 'package:smartmeal/domain/usecases/menus/delete_menu_item_usecase.dart';

// Use Cases - Shopping
import 'package:smartmeal/domain/usecases/shopping/get_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/add_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/toggle_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/delete_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/get_total_price_usecase.dart';
import 'package:smartmeal/domain/usecases/generate_shopping_from_menus_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/delete_checked_shopping_items_usecase.dart';

// Use Cases - Recipes & Weekly Menus
import 'package:smartmeal/domain/usecases/get_recipes_usecase.dart';
import 'package:smartmeal/domain/usecases/get_recipes_by_meal_type_usecase.dart';
import 'package:smartmeal/domain/usecases/menus/get_weekly_menus_usecase.dart';
import 'package:smartmeal/domain/usecases/menus/save_menu_recipes_usecase.dart';
import 'package:smartmeal/domain/usecases/get_recipe_by_id_usecase.dart';
import 'package:smartmeal/domain/usecases/support/get_support_messages_usecase.dart';

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

  // Data sources
  sl.registerLazySingleton(() => AuthLocalDataSource());
  sl.registerLazySingleton(() => FirebaseAuthDataSource(auth: sl()));
  sl.registerLazySingleton(() => FirestoreDataSource(firestore: sl()));
  sl.registerLazySingleton(() => MenuDataSource(firestore: sl(), auth: sl()));
  sl.registerLazySingleton(() => ShoppingDataSource(firestore: sl(), auth: sl()));
  sl.registerLazySingleton(() => GeminiMenuDatasource()); // ← CAMBIO AQUÍ

  // Services
  sl.registerLazySingleton<FCMService>(
    () => FCMService(
      firestoreDataSource: sl<FirestoreDataSource>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AppRepository>(
    () => AppRepositoryImpl(),
  );

  sl.registerLazySingleton<MenuGenerationRepository>(
    () => MenuGenerationRepositoryImpl(sl<GeminiMenuDatasource>()), // ← CAMBIO AQUÍ
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authDataSource: sl(),
      firestoreDataSource: sl(),
    ),
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
    ),
  );
  
  sl.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(sl()),
  );
  
  sl.registerLazySingleton<WeeklyMenuRepository>(
    () => WeeklyMenuRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton<SupportMessageRepository>(
    () => SupportMessageRepositoryImpl(),
  );

  // Use Cases - App
  sl.registerLazySingleton(() => InitializeAppUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));

  // Use Cases - Auth
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Use Cases - Profile
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));

  // Use Cases - Menu
  sl.registerLazySingleton(() => GetMenuItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetRecommendedMenuItemsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMenuItemUseCase(sl()));
  sl.registerLazySingleton(() => SaveMenuRecipesUseCase(sl()));
  sl.registerLazySingleton(() => GenerateWeeklyMenuUseCase(sl<MenuGenerationRepository>()));

  // Use Cases - Shopping
  sl.registerLazySingleton(() => GetShoppingItemsUseCase(sl()));
  sl.registerLazySingleton(() => AddShoppingItemUseCase(sl()));
  sl.registerLazySingleton(() => ToggleShoppingItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteShoppingItemUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalPriceUseCase(sl()));
  sl.registerLazySingleton(() => GenerateShoppingFromMenusUseCase(
    menuRepository: sl(),
    shoppingRepository: sl(),
  ));
  sl.registerLazySingleton(() => DeleteCheckedShoppingItemsUseCase(sl()));

  // Use Cases - Recipes & Weekly Menus
  sl.registerLazySingleton(() => GetRecipesUseCase(sl()));
  sl.registerLazySingleton(() => GetRecipesByMealTypeUseCase(sl()));
  sl.registerLazySingleton(() => GetWeeklyMenusUseCase(sl()));
  sl.registerLazySingleton<GetRecipeByIdUseCase>(
    () => GetRecipeByIdUseCase(sl<RecipeRepository>())
  );

  // Use Cases - Support Messages
  sl.registerLazySingleton(() => GetSupportMessagesUseCase(sl()));

  // ViewModels
  sl.registerLazySingleton<MenuViewModel>(() => MenuViewModel());
  sl.registerLazySingleton(() => GenerateMenuViewModel(
    sl<GetUserProfileUseCase>(),
    sl<GetCurrentUserUseCase>(),
    sl<GenerateWeeklyMenuUseCase>(),
    sl<WeeklyMenuRepository>(),
    sl<SaveMenuRecipesUseCase>(),
  ));
}