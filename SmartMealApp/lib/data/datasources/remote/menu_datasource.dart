import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/errors/errors.dart';

class MenuDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MenuDataSource({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  //TODO: borrar este metodo, no me sirve  de nada que me coja todas las recetas de todos los menus del usuario
  /// Obtiene todas las recetas de todos los menús semanales
  Future<List<Map<String, dynamic>>> getMenuItems() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    if (kDebugMode) {
      print('📋 [MenuDS] Buscando weekly_menus para userId: ${user.uid}');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('weekly_menus')
        .orderBy('createdAt', descending: true)
        .get();

    if (kDebugMode) {
      print('📋 [MenuDS] Menús semanales encontrados: ${snapshot.docs.length}');
    }

    // Extraer todas las recetas de todos los días
    final List<Map<String, dynamic>> allRecipes = [];

    for (final menuDoc in snapshot.docs) {
      final menuData = menuDoc.data();
      final days = menuData['days'] as List<dynamic>? ?? [];

      if (kDebugMode) {
        print('📋 [MenuDS] Menú "${menuData['name']}": ${days.length} días');
      }

      for (final dayData in days) {
        final day = dayData as Map<String, dynamic>;
        final recipes = day['recipes'] as List<dynamic>? ?? [];

        for (final recipeId in recipes) {
          final recipeIdStr = recipeId.toString();

          // 1) probar con id completo
          var recipeDoc = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('recipes')
              .doc(recipeIdStr)
              .get();

          // 2) si no existe, probar versión recortada (quitando "{uid}_recipe_")
          if (!recipeDoc.exists) {
            final trimmed = recipeIdStr.replaceFirst('${user.uid}_recipe_', '');
            recipeDoc = await _firestore
                .collection('users')
                .doc(user.uid)
                .collection('recipes')
                .doc(trimmed)
                .get();
          }

          if (!recipeDoc.exists) {
            if (kDebugMode) {
              print('⚠️ [MenuDS] Receta no encontrada: $recipeIdStr');
            }
            continue;
          }

          final data = recipeDoc.data();
          if (data == null) continue;

          final recipeData = {
            'id': recipeDoc.id,
            ...data,
            'menuName': menuData['name'],
            'dayName': day['day'],
          };
          allRecipes.add(recipeData);

          if (kDebugMode) {
            print(
              '✅ Receta encontrada: ${recipeData['name']} (ingredientes: ${(recipeData['ingredients'] as List?)?.length ?? 0})',
            );
          }
        }
      }
    }

    if (kDebugMode) {
      print('📋 [MenuDS] Total recetas extraídas: ${allRecipes.length}');
    }

    return allRecipes;
  }

  Future<List<Map<String, dynamic>>> getRecommendedMenuItems(int limit) async {
    final items = await getMenuItems();
    return items.take(limit).toList();
  }

  Future<Map<String, dynamic>?> getMenuItem(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recipes')
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return {'id': doc.id, ...doc.data()!};
  }

  Future<void> createMenuItem(String id, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recipes')
        .doc(id)
        .set(data);
  }

  Future<void> updateMenuItem(String id, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recipes')
        .doc(id)
        .update(data);
  }

  Future<void> deleteMenuItem(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recipes')
        .doc(id)
        .delete();
  }

  /// Obtiene solo el último menú semanal generado
  Future<List<Map<String, dynamic>>> getLatestWeeklyMenu() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    if (kDebugMode) {
      print('📋 [MenuDS] Buscando último weekly_menu para userId: ${user.uid}');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('weekly_menus')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      if (kDebugMode) {
        print('📋 [MenuDS] No hay menús semanales');
      }
      return [];
    }

    final menuDoc = snapshot.docs.first;
    final menuData = menuDoc.data();
    final days = menuData['days'] as List<dynamic>? ?? [];

    if (kDebugMode) {
      print('📋 [MenuDS] Menú "${menuData['name']}": ${days.length} días');
    }

    final List<Map<String, dynamic>> allRecipes = [];

    for (final dayData in days) {
      final day = dayData as Map<String, dynamic>;
      final recipes = day['recipes'] as List<dynamic>? ?? [];

      for (final recipeId in recipes) {
        final recipeIdStr = recipeId.toString();

        var recipeDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('recipes')
            .doc(recipeIdStr)
            .get();

        if (!recipeDoc.exists) {
          final trimmed = recipeIdStr.replaceFirst('${user.uid}_recipe_', '');
          recipeDoc = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('recipes')
              .doc(trimmed)
              .get();
        }

        if (!recipeDoc.exists) {
          if (kDebugMode) {
            print('⚠️ [MenuDS] Receta no encontrada: $recipeIdStr');
          }
          continue;
        }

        final data = recipeDoc.data();
        if (data == null) continue;

        final recipeData = {
          'id': recipeDoc.id,
          ...data,
          'menuName': menuData['name'],
          'dayName': day['day'],
        };
        allRecipes.add(recipeData);

        if (kDebugMode) {
          print(
            '✅ Receta encontrada: ${recipeData['name']} (ingredientes: ${(recipeData['ingredients'] as List?)?.length ?? 0})',
          );
        }
      }
    }

    if (kDebugMode) {
      print('📋 [MenuDS] Total recetas extraídas: ${allRecipes.length}');
    }

    return allRecipes;
  }
}
