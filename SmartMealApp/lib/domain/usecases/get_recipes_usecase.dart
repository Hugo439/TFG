import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';

class GetRecipesUseCase implements UseCase<List<Recipe>, NoParams> {
  final RecipeRepository _repository;

  GetRecipesUseCase(this._repository);

  @override
  Future<List<Recipe>> call(NoParams params) {
    return _repository.getAllRecipes();
  }
}