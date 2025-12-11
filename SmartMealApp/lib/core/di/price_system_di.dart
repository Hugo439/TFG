import 'package:get_it/get_it.dart';
import 'package:smartmeal/domain/repositories/price_catalog_repository.dart';
import 'package:smartmeal/domain/repositories/user_price_repository.dart';
import 'package:smartmeal/domain/repositories/missing_price_repository.dart';
import 'package:smartmeal/data/repositories_impl/price_catalog_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/user_price_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/missing_price_repository_impl.dart';
import 'package:smartmeal/data/datasources/remote/price_catalog_firestore_datasource.dart';
import 'package:smartmeal/data/datasources/remote/user_price_firestore_datasource.dart';
import 'package:smartmeal/data/datasources/remote/missing_price_firestore_datasource.dart';
import 'package:smartmeal/domain/services/shopping/price_cache_service.dart';
import 'package:smartmeal/domain/usecases/shopping/get_ingredient_price_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/save_user_price_override_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/get_missing_prices_usecase.dart';

/// Configuración adicional para el sistema de precios robusto
/// LLAMAR ESTA FUNCIÓN desde setupServiceLocator() en service_locator.dart
void setupPriceSystemDI(GetIt sl) {
  // ===== DATASOURCES =====
  sl.registerLazySingleton(() => PriceCatalogFirestoreDatasource(sl()));
  sl.registerLazySingleton(() => UserPriceFirestoreDatasource(sl()));
  sl.registerLazySingleton(() => MissingPriceFirestoreDatasource(sl()));

  // ===== SERVICES =====
  sl.registerLazySingleton(() => PriceCacheService());

  // ===== REPOSITORIES =====
  sl.registerLazySingleton<PriceCatalogRepository>(
    () => PriceCatalogRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<UserPriceRepository>(
    () => UserPriceRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<MissingPriceRepository>(
    () => MissingPriceRepositoryImpl(sl()),
  );

  // ===== USE CASES =====
  sl.registerLazySingleton(() => GetIngredientPriceUseCase(sl(), sl(), sl()));
  sl.registerLazySingleton(() => SaveUserPriceOverrideUseCase(sl()));
  sl.registerLazySingleton(() => GetMissingPricesUseCase(sl()));
}
