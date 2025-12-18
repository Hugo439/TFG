import 'package:get_it/get_it.dart';
import 'package:smartmeal/domain/repositories/menu_repository.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';
import 'package:smartmeal/domain/repositories/menu_generation_repository.dart';
import 'package:smartmeal/data/repositories_impl/menu_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/weekly_menu_repository_impl.dart';
import 'package:smartmeal/data/repositories_impl/menu_generation_repository_impl.dart';
import 'package:smartmeal/domain/usecases/menus/save_menu_recipes_usecase.dart';

import 'package:smartmeal/domain/usecases/menus/generate_weekly_menu_usecase.dart';
import 'package:smartmeal/data/datasources/local/statistics_local_datasource.dart';

void setupMenusDI(GetIt sl) {
  // Repositories
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<WeeklyMenuRepository>(
    () => WeeklyMenuRepositoryImpl(
      sl(),
      sl(),
      sl(),
      StatisticsLocalDatasource(sl()),
    ),
  );
  sl.registerLazySingleton<MenuGenerationRepository>(
    () => MenuGenerationRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SaveMenuRecipesUseCase(sl()));
  sl.registerLazySingleton(
    () => GenerateWeeklyMenuUseCase(sl<MenuGenerationRepository>()),
  );
}
