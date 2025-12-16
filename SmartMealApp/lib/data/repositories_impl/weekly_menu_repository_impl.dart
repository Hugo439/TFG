import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';
import 'package:smartmeal/domain/repositories/recipe_repository.dart';
import 'package:smartmeal/data/models/weekly_menu_model.dart';
import 'package:smartmeal/data/datasources/local/weekly_menu_local_datasource.dart';
import 'package:smartmeal/data/mappers/weekly_menu_mapper.dart';

class WeeklyMenuRepositoryImpl implements WeeklyMenuRepository {
  final FirebaseFirestore _firestore;
  final RecipeRepository _recipeRepository;
  final WeeklyMenuLocalDatasource _localDS;
  final FirebaseAuth _auth;

  WeeklyMenuRepositoryImpl(this._firestore, this._recipeRepository, this._localDS, {FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _userMenusRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('weekly_menus');

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    return user.uid;
  }

  @override
  Future<List<WeeklyMenu>> getUserMenus(String userId) async {
    final snapshot = await _userMenusRef(userId)
        .orderBy('updatedAt', descending: true)  // Primero por updatedAt
        .get();

    final menus = <WeeklyMenu>[];
    for (final doc in snapshot.docs) {
      final model = WeeklyMenuModel.fromFirestore(doc);
      final menu = await WeeklyMenuMapper.toEntity(model, (id) => _getRecipeById(userId, id));
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
    return getUserMenus(userId); // Ya ordena correctamente
  }

  @override
  Future<WeeklyMenu> getMenuById(String id) async {
    final doc = await _userMenusRef(_currentUserId).doc(id).get();
    if (!doc.exists) throw Exception('Menú no encontrado');
    final model = WeeklyMenuModel.fromFirestore(doc);
    return await WeeklyMenuMapper.toEntity(model, (rid) => _getRecipeById(_currentUserId, rid));
  }

  @override
  Future<void> saveMenu(WeeklyMenu menu) async {
    final model = WeeklyMenuMapper.fromEntity(menu);
    await _userMenusRef(menu.userId)
        .doc(menu.id)
        .set(WeeklyMenuMapper.toFirestore(model));
  }

  @override
  Future<void> updateMenu(WeeklyMenu menu) async {
    final model = WeeklyMenuMapper.fromEntity(menu);
    await _userMenusRef(menu.userId)
        .doc(menu.id)
        .update(WeeklyMenuMapper.toFirestore(model));
  }

  @override
  Future<void> deleteMenu(String id) async {
    await _userMenusRef(_currentUserId).doc(id).delete();
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
      return await WeeklyMenuMapper.toEntity(cached, (id) => _getRecipeById(userId, id));
    }

    final model = WeeklyMenuModel.fromFirestore(snapshot.docs.first);
    // Guardar en caché local
    await _localDS.saveLatest(model);
    return await WeeklyMenuMapper.toEntity(model, (id) => _getRecipeById(userId, id));
  }

  Future<Recipe?> _getRecipeById(String userId, String id) async {
    // Busca la receta en la subcolección del usuario
    return await _recipeRepository.getRecipeById(id, userId);
  }
}