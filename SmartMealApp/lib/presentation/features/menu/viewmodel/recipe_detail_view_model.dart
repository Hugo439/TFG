import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/usecases/menus/get_recipe_by_id_usecase.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  final GetRecipeByIdUseCase _getRecipeByIdUseCase = sl<GetRecipeByIdUseCase>();

  Recipe? _recipe;
  Recipe? get recipe => _recipe;

  Future<void> loadRecipe(String id) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');
    final params = GetRecipeByIdParams(id: id, userId: userId);
    _recipe = await _getRecipeByIdUseCase(params);
    notifyListeners();
  }
}