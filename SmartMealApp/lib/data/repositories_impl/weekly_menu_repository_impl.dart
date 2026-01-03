import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';
import 'package:smartmeal/data/models/weekly_menu_model.dart';
import 'package:smartmeal/data/datasources/local/statistics_local_datasource.dart';
import 'package:smartmeal/data/datasources/local/weekly_menu_local_datasource.dart';
import 'package:smartmeal/data/mappers/weekly_menu_mapper.dart';
import 'package:smartmeal/core/errors/errors.dart';

class WeeklyMenuRepositoryImpl implements WeeklyMenuRepository {
  final FirebaseFirestore _firestore;
  final RecipeRepository _recipeRepository;
  final WeeklyMenuLocalDatasource _localDS;
  final FirebaseAuth _auth;
  final StatisticsLocalDatasource _statisticsLocalDS;

  WeeklyMenuRepositoryImpl(
    this._firestore,
    this._recipeRepository,
    this._localDS,
    this._statisticsLocalDS, {
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _userMenusRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('weekly_menus');

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw AuthFailure('Usuario no autenticado');
    return user.uid;
  }

  @override
  Future<List<WeeklyMenu>> getUserMenus(String userId) async {
    final snapshot = await _userMenusRef(userId)
        .orderBy('updatedAt', descending: true) // Primero por updatedAt
        .get();

    final menus = <WeeklyMenu>[];
    for (final doc in snapshot.docs) {
      final model = WeeklyMenuModel.fromFirestore(doc);
      final menu = await WeeklyMenuMapper.toEntity(
        model,
        (id) => _getRecipeById(userId, id),
      );
      menus.add(menu);
    }

    // Si updatedAt es null, ordenar por createdAt
    menus.sort((a, b) {
      final dateA = a.updatedAt ?? a.createdAt;
      final dateB = b.updatedAt ?? b.createdAt;
      return dateB.compareTo(dateA); // Descendente
    });

    return menus;
  }

  @override
  Future<List<WeeklyMenu>> getWeeklyMenus(String userId) async {
    // Intentar cargar desde caché local primero
    try {
      final cachedMenu = await _localDS.getLatest();
      if (cachedMenu != null) {
        final menu = await WeeklyMenuMapper.toEntity(
          cachedMenu,
          (id) => _getRecipeById(userId, id),
        );
        // Devolver lista con el menú cacheado
        return [menu];
      }
    } catch (e) {
      // Si hay error con el caché, continuar con Firestore
      if (kDebugMode) {
        print('⚠️ [WeeklyMenuRepo] Error cargando caché: $e');
      }
    }

    // Si no hay caché, cargar desde Firestore
    final menus = await getUserMenus(userId);

    // Cachear el último menú si existe
    if (menus.isNotEmpty) {
      final latestMenu = menus.first;
      final model = WeeklyMenuMapper.fromEntity(latestMenu);
      await _localDS.saveLatest(model);
    }

    return menus;
  }

  @override
  Future<WeeklyMenu> getMenuById(String id) async {
    final doc = await _userMenusRef(_currentUserId).doc(id).get();
    if (!doc.exists) throw NotFoundFailure('Menú no encontrado');
    final model = WeeklyMenuModel.fromFirestore(doc);
    return await WeeklyMenuMapper.toEntity(
      model,
      (rid) => _getRecipeById(_currentUserId, rid),
    );
  }

  @override
  Future<void> saveMenu(WeeklyMenu menu) async {
    final model = WeeklyMenuMapper.fromEntity(menu);
    await _userMenusRef(
      menu.userId,
    ).doc(menu.id).set(WeeklyMenuMapper.toFirestore(model));

    // Guardar en caché local el menú recién creado
    await _localDS.saveLatest(model);

    // Invalidar caché local de estadísticas
    await _statisticsLocalDS.clear();
  }

  @override
  Future<void> updateMenu(WeeklyMenu menu) async {
    final model = WeeklyMenuMapper.fromEntity(menu);
    await _userMenusRef(
      menu.userId,
    ).doc(menu.id).update(WeeklyMenuMapper.toFirestore(model));

    // Actualizar caché local con el menú modificado
    await _localDS.saveLatest(model);

    // Invalidar caché local de estadísticas
    await _statisticsLocalDS.clear();
  }

  @override
  Future<void> deleteMenu(String id) async {
    await _userMenusRef(_currentUserId).doc(id).delete();

    // Limpiar caché local ya que el menú fue eliminado
    await _localDS.clear();

    // Invalidar caché local de estadísticas
    await _statisticsLocalDS.clear();
  }

  @override
  Future<WeeklyMenu?> getCurrentWeekMenu(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekMidnight = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    final snapshot = await _userMenusRef(userId)
        .where('weekStart', isEqualTo: Timestamp.fromDate(startOfWeekMidnight))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      // Fallback a caché local
      final cached = await _localDS.getLatest();
      if (cached == null) return null;
      return await WeeklyMenuMapper.toEntity(
        cached,
        (id) => _getRecipeById(userId, id),
      );
    }

    final model = WeeklyMenuModel.fromFirestore(snapshot.docs.first);
    // Guardar en caché local
    await _localDS.saveLatest(model);
    return await WeeklyMenuMapper.toEntity(
      model,
      (id) => _getRecipeById(userId, id),
    );
  }

  Future<Recipe?> _getRecipeById(String userId, String id) async {
    // Busca la receta en la subcolección del usuario
    return await _recipeRepository.getRecipeById(id, userId);
  }
}
