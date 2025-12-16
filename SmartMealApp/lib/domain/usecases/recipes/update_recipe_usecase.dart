import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';

class UpdateRecipeUseCase implements UseCase<void, UpdateRecipeParams> {
  final RecipeRepository repository;

  UpdateRecipeUseCase(this.repository);

  @override
  Future<void> call(UpdateRecipeParams params) async {
    await repository.saveRecipe(params.recipe);
  }
}

class UpdateRecipeParams {
  final Recipe recipe;

  UpdateRecipeParams(this.recipe);
}
