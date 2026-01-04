import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';

/// UseCase para actualizar una receta existente.
///
/// Responsabilidad:
/// - Persistir cambios en Recipe en Firestore
///
/// Entrada:
/// - UpdateRecipeParams con Recipe completo
///
/// Salida:
/// - void (éxito) o excepción si falla
///
/// Uso típico:
/// ```dart
/// final updatedRecipe = recipe.copyWith(
///   name: RecipeName('Pollo al horno mejorado'),
///   calories: 450,
///   updatedAt: DateTime.now(),
/// );
///
/// await updateRecipeUseCase(UpdateRecipeParams(updatedRecipe));
/// ```
///
/// Nota: saveRecipe hace upsert (crea si no existe, actualiza si existe).
class UpdateRecipeUseCase implements UseCase<void, UpdateRecipeParams> {
  final RecipeRepository repository;

  UpdateRecipeUseCase(this.repository);

  @override
  Future<void> call(UpdateRecipeParams params) async {
    await repository.saveRecipe(params.recipe);
  }
}

/// Parámetros para actualizar receta.
class UpdateRecipeParams {
  final Recipe recipe;

  UpdateRecipeParams(this.recipe);
}
