import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';
import 'package:smartmeal/data/models/recipe_model.dart';
import 'package:smartmeal/data/mappers/recipe_mapper.dart';
import 'package:smartmeal/core/utils/meal_type_utils.dart';
import 'package:smartmeal/core/errors/errors.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

/// Implementación del repositorio de recetas.
///
/// Gestiona la persistencia de recetas en Firestore bajo la estructura:
/// ```
/// users/{userId}/recipes/{recipeId}
/// ```
///
/// Funcionalidades:
/// - CRUD de recetas individuales
/// - Consulta de recetas por tipo de comida (breakfast, lunch, snack, dinner)
/// - Actualización de pasos de receta (para recetas generadas por IA)
///
/// Nota: El userId se extrae del ID de la receta (formato: {userId}_recipe_{timestamp}_{index}).
class RecipeRepositoryImpl implements RecipeRepository {
  final FirebaseFirestore _firestore;

  RecipeRepositoryImpl(this._firestore);

  /// Obtiene una receta por su ID.
  ///
  /// [id] - ID de la receta.
  /// [userId] - ID del usuario dueño de la receta.
  ///
  /// Returns:
  /// - Receta si existe
  /// - null si no se encuentra
  ///
  /// Throws: [ServerFailure] si falla la consulta a Firestore.
  @override
  Future<Recipe?> getRecipeById(String id, String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionRecipes)
          .doc(id)
          .get();
      if (!doc.exists) return null;
      return RecipeModel.fromFirestore(doc).toEntity();
    } catch (e) {
      throw ServerFailure('Error al obtener receta: $e');
    }
  }

  /// Guarda una nueva receta.
  ///
  /// [recipe] - Receta a guardar.
  ///
  /// El userId se extrae automáticamente del ID de la receta.
  /// Formato esperado del ID: {userId}_recipe_{timestamp}_{index}
  ///
  /// Throws: [ServerFailure] si falla la operación.
  @override
  Future<void> saveRecipe(Recipe recipe) async {
    try {
      final model = RecipeMapper.fromEntity(recipe);
      // FIX: Extraer userId del ID de la receta (formato: {userId}_recipe_{timestamp}_{index})
      final userId = recipe.id.split('_')[0];

      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionRecipes)
          .doc(model.id)
          .set(model.toFirestore());
    } catch (e) {
      throw ServerFailure('Error al guardar receta: $e');
    }
  }

  /// Obtiene todas las recetas de un usuario.
  ///
  /// [userId] - ID del usuario.
  ///
  /// Returns: Lista de todas las recetas del usuario.
  ///
  /// Throws: [ServerFailure] si falla la consulta.
  @override
  Future<List<Recipe>> getAllRecipes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionRecipes)
          .get();
      return snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw ServerFailure('Error al obtener todas las recetas: $e');
    }
  }

  /// Obtiene recetas filtradas por tipo de comida.
  ///
  /// [mealType] - Tipo de comida: MealType.breakfast, lunch, snack, o dinner.
  /// [userId] - ID del usuario.
  ///
  /// Returns: Lista de recetas que coinciden con el tipo especificado.
  ///
  /// Throws: [ServerFailure] si falla la consulta.
  @override
  Future<List<Recipe>> getRecipesByMealType(
    MealType mealType,
    String userId,
  ) async {
    try {
      final mealTypeString = mealTypeToString(mealType);
      final snapshot = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionRecipes)
          .where(AppConstants.fieldMealType, isEqualTo: mealTypeString)
          .get();
      return snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw ServerFailure('Error al obtener recetas por tipo: $e');
    }
  }

  /// Actualiza solo los pasos de una receta existente.
  ///
  /// [recipeId] - ID de la receta a actualizar.
  /// [userId] - ID del usuario dueño de la receta.
  /// [steps] - Nueva lista de pasos.
  ///
  /// También actualiza el timestamp updatedAt.
  ///
  /// Throws: [ServerFailure] si falla la actualización.
  ///
  /// Nota: Usado cuando la IA genera pasos para recetas que no los tenían.
  @override
  Future<void> updateRecipeSteps(
    String recipeId,
    String userId,
    List<String> steps,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionRecipes)
          .doc(recipeId)
          .update({
            'steps': steps,
            AppConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw ServerFailure('Error al actualizar pasos de receta: $e');
    }
  }
}
