import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';

/// UseCase para obtener una receta por su ID.
///
/// Responsabilidad:
/// - Recuperar Recipe desde Firestore usando ID
///
/// Entrada:
/// - GetRecipeByIdParams:
///   - id: ID de la receta
///   - userId: ID del usuario propietario
///
/// Salida:
/// - Recipe? (null si no se encuentra)
///
/// Uso típico:
/// ```dart
/// final recipe = await getRecipeUseCase(GetRecipeByIdParams(
///   id: 'user123_recipe_1704124800000_5',
///   userId: 'user123',
/// ));
///
/// if (recipe != null) {
///   print('Receta: ${recipe.name.value}');
/// }
/// ```
///
/// Usado por: RecipeDetailViewModel para mostrar detalles de receta.
class GetRecipeByIdUseCase implements UseCase<Recipe?, GetRecipeByIdParams> {
  final RecipeRepository repository;

  GetRecipeByIdUseCase(this.repository);

  @override
  Future<Recipe?> call(GetRecipeByIdParams params) {
    return repository.getRecipeById(params.id, params.userId);
  }
}

/// Parámetros para obtener receta por ID.
class GetRecipeByIdParams {
  final String id;
  final String userId;

  GetRecipeByIdParams({required this.id, required this.userId});
}

// Se usa en el recipe detail view model
