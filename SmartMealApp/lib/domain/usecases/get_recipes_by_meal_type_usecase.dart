import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';

class GetRecipesByMealTypeUseCase implements UseCase<List<Recipe>, GetRecipesByMealTypeParams> {
  final RecipeRepository _repository;

  GetRecipesByMealTypeUseCase(this._repository);

  @override
  Future<List<Recipe>> call(GetRecipesByMealTypeParams params) {
    return _repository.getRecipesByMealType(params.mealType, params.userId);
  }
}

class GetRecipesByMealTypeParams {
  final MealType mealType;
  final String userId;

  GetRecipesByMealTypeParams({required this.mealType, required this.userId});
}