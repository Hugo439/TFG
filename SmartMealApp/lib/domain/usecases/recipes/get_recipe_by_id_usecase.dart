import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';

class GetRecipeByIdUseCase implements UseCase<Recipe?, GetRecipeByIdParams> {
  final RecipeRepository repository;

  GetRecipeByIdUseCase(this.repository);

  @override
  Future<Recipe?> call(GetRecipeByIdParams params) {
    return repository.getRecipeById(params.id, params.userId);
  }
}

class GetRecipeByIdParams {
  final String id;
  final String userId;

  GetRecipeByIdParams({required this.id, required this.userId});
}

//Se usa en el recipe detail view model
