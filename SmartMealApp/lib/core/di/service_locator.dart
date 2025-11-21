import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartmeal/firebase_options.dart';
import 'package:smartmeal/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:smartmeal/data/datasources/remote/firestore_datasource.dart';
import 'package:smartmeal/data/datasources/remote/menu_datasource.dart';
import 'package:smartmeal/data/datasources/remote/shopping_datasource.dart';
import 'package:smartmeal/data/datasources/local/auth_local_datasource.dart';
import 'package:smartmeal/data/repositories_impl/auth_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/user_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/app_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/menu_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/shopping_repository_impl.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';
import 'package:smartmeal/domain/repositories/user_repository.dart';
import 'package:smartmeal/domain/repositories/app_repository.dart';
import 'package:smartmeal/domain/repositories/menu_repository.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/usecases/initialize_app_usecase.dart';
import 'package:smartmeal/domain/usecases/sign_in_usecase.dart';
import 'package:smartmeal/domain/usecases/sign_up_usecase.dart';
import 'package:smartmeal/domain/usecases/check_auth_status_usecase.dart';
import 'package:smartmeal/domain/usecases/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/update_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/sign_out_usecase.dart';
import 'package:smartmeal/domain/usecases/delete_account_usecase.dart';
import 'package:smartmeal/domain/usecases/get_menu_items_usecase.dart';
import 'package:smartmeal/domain/usecases/get_recommended_menu_items_usecase.dart';
import 'package:smartmeal/domain/usecases/create_menu_item_usecase.dart';
import 'package:smartmeal/domain/usecases/delete_menu_item_usecase.dart';
import 'package:smartmeal/domain/usecases/get_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/add_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/toggle_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/delete_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/get_total_price_usecase.dart';
import 'package:smartmeal/domain/usecases/generate_shopping_from_menus_usecase.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Inicializar Firebase PRIMERO
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Data sources
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSource(),
  );
  sl.registerLazySingleton<FirestoreDataSource>(
    () => FirestoreDataSource(),
  );
  sl.registerLazySingleton<MenuDataSource>(
    () => MenuDataSource(),
  );
  sl.registerLazySingleton<ShoppingDataSource>(
    () => ShoppingDataSource(),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(),
  );

  // Repositories
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      authDataSource: sl<FirebaseAuthDataSource>(),
      firestoreDataSource: sl<FirestoreDataSource>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authDataSource: sl<FirebaseAuthDataSource>(),
      userRepository: sl<UserRepository>(),
    ),
  );

  sl.registerLazySingleton<AppRepository>(
    () => AppRepositoryImpl(),
  );
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(
      dataSource: sl<MenuDataSource>(),
    ),
  );
  sl.registerLazySingleton<ShoppingRepository>(
    () => ShoppingRepositoryImpl(
      dataSource: sl<ShoppingDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<InitializeAppUseCase>(
    () => InitializeAppUseCase(sl<AppRepository>()),
  );
  sl.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<CheckAuthStatusUseCase>(
    () => CheckAuthStatusUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<UpdateUserProfileUseCase>(
    () => UpdateUserProfileUseCase(sl<UserRepository>()),
  );
  sl.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<DeleteAccountUseCase>(
    () => DeleteAccountUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetMenuItemsUseCase>(
    () => GetMenuItemsUseCase(sl<MenuRepository>()),
  );
  sl.registerLazySingleton<GetRecommendedMenuItemsUseCase>(
    () => GetRecommendedMenuItemsUseCase(sl<MenuRepository>()),
  );
  sl.registerLazySingleton<CreateMenuItemUseCase>(
    () => CreateMenuItemUseCase(sl<MenuRepository>()),
  );
  sl.registerLazySingleton<DeleteMenuItemUseCase>(
    () => DeleteMenuItemUseCase(sl<MenuRepository>()),
  );
  sl.registerLazySingleton<GetShoppingItemsUseCase>(
    () => GetShoppingItemsUseCase(sl<ShoppingRepository>()),
  );
  sl.registerLazySingleton<AddShoppingItemUseCase>(
    () => AddShoppingItemUseCase(sl<ShoppingRepository>()),
  );
  sl.registerLazySingleton<ToggleShoppingItemUseCase>(
    () => ToggleShoppingItemUseCase(sl<ShoppingRepository>()),
  );
  sl.registerLazySingleton<DeleteShoppingItemUseCase>(
    () => DeleteShoppingItemUseCase(sl<ShoppingRepository>()),
  );
  sl.registerLazySingleton<GetTotalPriceUseCase>(
    () => GetTotalPriceUseCase(sl<ShoppingRepository>()),
  );
  sl.registerLazySingleton<GenerateShoppingFromMenusUseCase>(
    () => GenerateShoppingFromMenusUseCase(
      menuRepository: sl<MenuRepository>(),
      shoppingRepository: sl<ShoppingRepository>(),
    ),
  );
}