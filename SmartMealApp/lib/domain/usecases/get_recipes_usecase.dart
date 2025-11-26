import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';

class GetRecipesUseCase implements UseCase<List<Recipe>, String> {
  final RecipeRepository _repository;

  GetRecipesUseCase(this._repository);

  @override
  Future<List<Recipe>> call(String userId) {
    return _repository.getAllRecipes(userId);
  }
}