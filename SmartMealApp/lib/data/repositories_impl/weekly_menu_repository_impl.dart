import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';
import 'package:smartmeal/data/models/weekly_menu_model.dart';
import 'package:smartmeal/data/mappers/weekly_menu_mapper.dart';

class WeeklyMenuRepositoryImpl implements WeeklyMenuRepository {
  final FirebaseFirestore _firestore;
  final RecipeRepository _recipeRepository;
  static const String _collection = 'weekly_menus';

  WeeklyMenuRepositoryImpl(this._firestore, this._recipeRepository);

  @override
  Future<List<WeeklyMenu>> getUserMenus(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('semana', descending: true)
          .get();

      final menus = <WeeklyMenu>[];
      for (final doc in snapshot.docs) {
        final model = WeeklyMenuModel.fromFirestore(doc);
        final menu = await WeeklyMenuMapper.toEntity(model, _getRecipeById);
        menus.add(menu);
      }

      return menus;
    } catch (e) {
      throw Exception('Error al obtener menús: $e');
    }
  }

  @override
  Future<List<WeeklyMenu>> getWeeklyMenus(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('semana', descending: true)
        .get();

    final menus = <WeeklyMenu>[];
    for (final doc in snapshot.docs) {
      final model = WeeklyMenuModel.fromFirestore(doc);
      final menu = await WeeklyMenuMapper.toEntity(model, _getRecipeById);
      menus.add(menu);
    }
    return menus;
  }

  @override
  Future<WeeklyMenu> getMenuById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        throw Exception('Menú no encontrado');
      }

      final model = WeeklyMenuModel.fromFirestore(doc);
      return await WeeklyMenuMapper.toEntity(model, _getRecipeById);
    } catch (e) {
      throw Exception('Error al obtener menú: $e');
    }
  }

  @override
  Future<void> saveMenu(WeeklyMenu menu) async {
    try {
      final model = WeeklyMenuMapper.fromEntity(menu);
      await _firestore
          .collection(_collection)
          .doc(menu.id)
          .set(WeeklyMenuMapper.toFirestore(model));
    } catch (e) {
      throw Exception('Error al guardar menú: $e');
    }
  }

  @override
  Future<void> updateMenu(WeeklyMenu menu) async {
    try {
      final model = WeeklyMenuMapper.fromEntity(menu);
      await _firestore
          .collection(_collection)
          .doc(menu.id)
          .update(WeeklyMenuMapper.toFirestore(model));
    } catch (e) {
      throw Exception('Error al actualizar menú: $e');
    }
  }

  @override
  Future<void> deleteMenu(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar menú: $e');
    }
  }

  @override
  Future<WeeklyMenu?> getCurrentWeekMenu(String userId) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekMidnight = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );

      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('semana', isEqualTo: Timestamp.fromDate(startOfWeekMidnight))
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final model = WeeklyMenuModel.fromFirestore(snapshot.docs.first);
      return await WeeklyMenuMapper.toEntity(model, _getRecipeById);
    } catch (e) {
      throw Exception('Error al obtener menú actual: $e');
    }
  }

  Future<Recipe?> _getRecipeById(String id) async {
    try {
      return await _recipeRepository.getRecipeById(id);
    } catch (e) {
      return null;
    }
  }
}