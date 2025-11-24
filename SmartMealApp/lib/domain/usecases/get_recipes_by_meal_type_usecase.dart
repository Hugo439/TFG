import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';

class GetRecipesByMealTypeUseCase implements UseCase<List<Recipe>, MealType> {
  final RecipeRepository _repository;

  GetRecipesByMealTypeUseCase(this._repository);

  @override
  Future<List<Recipe>> call(MealType mealType) {
    return _repository.getRecipesByMealType(mealType);
  }
}