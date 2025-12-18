import 'package:get_it/get_it.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';
import 'package:smartmeal/data/repositories_impl/recipe_repository_impl.dart';
import 'package:smartmeal/domain/usecases/recipes/get_recipe_by_id_usecase.dart';
import 'package:smartmeal/domain/usecases/recipes/generate_recipe_steps_usecase.dart';
import 'package:smartmeal/domain/usecases/recipes/update_recipe_usecase.dart';
import 'package:smartmeal/domain/repositories/menu_generation_repository.dart';

void setupRecipesDI(GetIt sl) {
  // Repository
  sl.registerLazySingleton<RecipeRepository>(() => RecipeRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton<GetRecipeByIdUseCase>(
    () => GetRecipeByIdUseCase(sl<RecipeRepository>()),
  );
  sl.registerLazySingleton(
    () => GenerateRecipeStepsUseCase(sl<MenuGenerationRepository>()),
  );
  sl.registerLazySingleton(() => UpdateRecipeUseCase(sl<RecipeRepository>()));
}
