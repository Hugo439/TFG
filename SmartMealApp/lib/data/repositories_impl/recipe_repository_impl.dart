import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';
import 'package:smartmeal/data/models/recipe_model.dart';
import 'package:smartmeal/data/mappers/recipe_mapper.dart';
import 'package:smartmeal/core/utils/meal_type_utils.dart';
import 'package:smartmeal/core/errors/errors.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final FirebaseFirestore _firestore;

  RecipeRepositoryImpl(this._firestore);

  @override
  Future<Recipe?> getRecipeById(String id, String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .doc(id)
          .get();
      if (!doc.exists) return null;
      return RecipeModel.fromFirestore(doc).toEntity();
    } catch (e) {
      throw ServerFailure('Error al obtener receta: $e');
    }
  }

  @override
  Future<void> saveRecipe(Recipe recipe) async {
    try {
      final model = RecipeMapper.fromEntity(recipe);
      // FIX: Extraer userId del ID de la receta (formato: {userId}_recipe_{timestamp}_{index})
      final userId = recipe.id.split('_')[0];

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .doc(model.id)
          .set(model.toFirestore());
    } catch (e) {
      throw ServerFailure('Error al guardar receta: $e');
    }
  }

  @override
  Future<List<Recipe>> getAllRecipes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .get();
      return snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw ServerFailure('Error al obtener todas las recetas: $e');
    }
  }

  @override
  Future<List<Recipe>> getRecipesByMealType(
    MealType mealType,
    String userId,
  ) async {
    try {
      final mealTypeString = mealTypeToString(mealType);
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .where('mealType', isEqualTo: mealTypeString)
          .get();
      return snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw ServerFailure('Error al obtener recetas por tipo: $e');
    }
  }

  @override
  Future<void> updateRecipeSteps(
    String recipeId,
    String userId,
    List<String> steps,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .doc(recipeId)
          .update({'steps': steps, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      throw ServerFailure('Error al actualizar pasos de receta: $e');
    }
  }
}
