import 'package:get_it/get_it.dart';
import 'package:smartmeal/data/datasources/local/statistics_local_datasource.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';
import 'package:smartmeal/domain/repositories/statistics_repository.dart';
import 'package:smartmeal/data/repositories_impl/statistics_repository_impl.dart';
import 'package:smartmeal/domain/usecases/statistics/get_statistics_summary_usecase.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';
import 'package:smartmeal/domain/services/shopping/smart_category_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void setupStatisticsDI(GetIt sl) {
  // Repository
  sl.registerLazySingleton(
    () => StatisticsLocalDatasource(sl()),
  ); // sl() es SharedPreferences
  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(
      sl<WeeklyMenuRepository>(),
      sl<ShoppingRepository>(),
      sl<SmartIngredientNormalizer>(),
      sl<SmartCategoryHelper>(),
      localDatasource: sl<StatisticsLocalDatasource>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // Use case
  sl.registerLazySingleton(
    () => GetStatisticsSummaryUseCase(sl<StatisticsRepository>()),
  );
}
