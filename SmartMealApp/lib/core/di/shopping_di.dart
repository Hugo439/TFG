import 'package:get_it/get_it.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/data/repositories_impl/shopping_repository_impl.dart';
import 'package:smartmeal/domain/usecases/shopping/get_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/add_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/toggle_shopping_item_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/get_total_price_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/delete_checked_shopping_items_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/set_all_shopping_items_checked_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/get_prices_by_category_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/estimate_ingredient_price_usecase.dart';
import 'package:smartmeal/domain/usecases/shopping/generate_shopping_from_menus_usecase.dart';
import 'package:smartmeal/domain/repositories/menu_repository.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_aggregator.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_parser.dart';
import 'package:smartmeal/domain/services/shopping/smart_category_helper.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';
import 'package:smartmeal/domain/services/shopping/cost_estimator.dart';
import 'package:smartmeal/domain/repositories/statistics_repository.dart';

void setupShoppingDI(GetIt sl) {
  // Repository
  sl.registerLazySingleton<ShoppingRepository>(
    () => ShoppingRepositoryImpl(
      dataSource: sl(),
      userPriceDatasource: sl(),
      localDatasource: sl(),
      getStatisticsRepository: () => sl<StatisticsRepository>(),
      auth: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetShoppingItemsUseCase(sl()));
  sl.registerLazySingleton(() => AddShoppingItemUseCase(sl()));
  sl.registerLazySingleton(() => ToggleShoppingItemUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalPriceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCheckedShoppingItemsUseCase(sl()));
  sl.registerLazySingleton(() => SetAllShoppingItemsCheckedUseCase(sl()));
  sl.registerLazySingleton(() => GetPricesByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => EstimateIngredientPriceUseCase(sl()));
  sl.registerLazySingleton(
    () => GenerateShoppingFromMenusUseCase(
      menuRepository: sl<MenuRepository>(),
      shoppingRepository: sl<ShoppingRepository>(),
      parser: IngredientParser(),
      aggregator: IngredientAggregator(),
      priceEstimator: sl(),
      categoryHelper: sl<SmartCategoryHelper>(),
      normalizer: sl<SmartIngredientNormalizer>(),
      costEstimator: sl<CostEstimator>(),
    ),
  );
}
