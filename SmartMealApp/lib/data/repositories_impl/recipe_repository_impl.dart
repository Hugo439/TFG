import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';
import 'package:smartmeal/data/models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'recipes';

  RecipeRepositoryImpl(this._firestore);

  @override
  Future<List<Recipe>> getAllRecipes() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener recetas: $e');
    }
  }

  @override
  Future<List<Recipe>> getRecipesByMealType(MealType mealType) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('mealType', isEqualTo: mealType.name)
          .get();

      return snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al obtener recetas por tipo: $e');
    }
  }

  @override
  Future<List<Recipe>> getRecipesByTags(List<String> tags) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('tags', arrayContainsAny: tags)
          .get();

      return snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al buscar recetas por tags: $e');
    }
  }

  @override
  Future<Recipe> getRecipeById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) {
        throw Exception('Receta no encontrada');
      }

      return RecipeModel.fromFirestore(doc).toEntity();
    } catch (e) {
      throw Exception('Error al obtener receta: $e');
    }
  }

  @override
  Future<void> addRecipe(Recipe recipe) async {
    try {
      final model = RecipeModel.fromEntity(recipe);
      await _firestore
          .collection(_collection)
          .doc(recipe.id)
          .set(model.toFirestore());
    } catch (e) {
      throw Exception('Error al añadir receta: $e');
    }
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    try {
      final model = RecipeModel.fromEntity(recipe);
      await _firestore
          .collection(_collection)
          .doc(recipe.id)
          .update(model.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar receta: $e');
    }
  }

  @override
  Future<void> deleteRecipe(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar receta: $e');
    }
  }

  @override
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      
      final allRecipes = snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc).toEntity())
          .toList();

      // Búsqueda simple por nombre (en producción usarías Algolia o similar)
      final lowerQuery = query.toLowerCase();
      return allRecipes.where((recipe) {
        return recipe.nameValue.toLowerCase().contains(lowerQuery) ||
            recipe.descriptionValue.toLowerCase().contains(lowerQuery) ||
            recipe.ingredients.any((i) => i.toLowerCase().contains(lowerQuery));
      }).toList();
    } catch (e) {
      throw Exception('Error al buscar recetas: $e');
    }
  }
}