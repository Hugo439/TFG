import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/menu_generation_repository.dart';

class GenerateRecipeStepsUseCase
    implements UseCase<List<String>, GenerateRecipeStepsParams> {
  final MenuGenerationRepository repository;

  GenerateRecipeStepsUseCase(this.repository);

  @override
  Future<List<String>> call(GenerateRecipeStepsParams params) async {
    return await repository.generateRecipeSteps(
      recipeName: params.recipeName,
      ingredients: params.ingredients,
      description: params.description,
    );
  }
}

class GenerateRecipeStepsParams {
  final String recipeName;
  final List<String> ingredients;
  final String description;

  GenerateRecipeStepsParams({
    required this.recipeName,
    required this.ingredients,
    required this.description,
  });
}
