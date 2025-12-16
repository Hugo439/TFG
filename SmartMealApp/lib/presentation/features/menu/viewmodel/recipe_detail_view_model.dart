import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/usecases/menus/get_recipe_by_id_usecase.dart';
import 'package:smartmeal/domain/usecases/recipes/generate_recipe_steps_usecase.dart';
import 'package:smartmeal/domain/usecases/recipes/update_recipe_usecase.dart';
import 'package:smartmeal/core/di/service_locator.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  final GetRecipeByIdUseCase _getRecipeByIdUseCase = sl<GetRecipeByIdUseCase>();
  final GenerateRecipeStepsUseCase _generateStepsUseCase = sl<GenerateRecipeStepsUseCase>();
  final UpdateRecipeUseCase _updateRecipeUseCase = sl<UpdateRecipeUseCase>();

  Recipe? _recipe;
  Recipe? get recipe => _recipe;

  bool _isGeneratingSteps = false;
  bool get isGeneratingSteps => _isGeneratingSteps;

  String? _stepsError;
  String? get stepsError => _stepsError;

  Future<void> loadRecipe(String id) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');
    final params = GetRecipeByIdParams(id: id, userId: userId);
    _recipe = await _getRecipeByIdUseCase(params);
    notifyListeners();
  }

  Future<void> generateSteps() async {
    if (_recipe == null || _isGeneratingSteps) return;

    _isGeneratingSteps = true;
    _stepsError = null;
    notifyListeners();

    try {
      final params = GenerateRecipeStepsParams(
        recipeName: _recipe!.name.value,
        ingredients: _recipe!.ingredients,
        description: _recipe!.description.value,
      );

      final steps = await _generateStepsUseCase(params);

      _recipe = _recipe!.copyWith(
        steps: steps,
        updatedAt: DateTime.now(),
      );

      await _updateRecipeUseCase(UpdateRecipeParams(_recipe!));

      _isGeneratingSteps = false;
      notifyListeners();
    } catch (e) {
      _stepsError = e.toString();
      _isGeneratingSteps = false;
      notifyListeners();
    }
  }
}
