import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/models/shopping_item_model.dart';

class ShoppingDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ShoppingDataSource({required this.firestore, required this.auth});

  Future<List<ShoppingItemModel>> getShoppingItems() async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');

    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('shoppingItems')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => ShoppingItemModel.fromFirestore(doc)).toList();
  }

  Future<void> addShoppingItem(String id, Map<String, dynamic> data) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');

    await firestore
        .collection('users')
        .doc(userId)
        .collection('shoppingItems')
        .doc(id)
        .set(data);
  }

  Future<void> updateShoppingItem(String id, Map<String, dynamic> data) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');

    await firestore
        .collection('users')
        .doc(userId)
        .collection('shoppingItems')
        .doc(id)
        .update(data);
  }

  Future<void> deleteShoppingItem(String id) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');

    await firestore
        .collection('users')
        .doc(userId)
        .collection('shoppingItems')
        .doc(id)
        .delete();
  }

  Future<void> deleteCheckedItems(String userId) async {
    if (kDebugMode) {
      print('🗑️ [ShoppingDS] Buscando items marcados para userId: $userId');
    }

    // Obtener TODOS los items primero
    final snap = await firestore
        .collection('users')
        .doc(userId)
        .collection('shoppingItems')
        .get();

    if (kDebugMode) {
      print('🗑️ [ShoppingDS] Total de items encontrados: ${snap.docs.length}');
    }

    // Convertir a modelos y filtrar los marcados
    final allItems = snap.docs
        .map((doc) => ShoppingItemModel.fromFirestore(doc))
        .toList();

    final checkedItems = allItems.where((item) => item.isChecked).toList();

    if (kDebugMode) {
      print('🗑️ [ShoppingDS] Items marcados encontrados: ${checkedItems.length}');
      for (var item in checkedItems) {
        print('   - ${item.id}: ${item.name} (isChecked: ${item.isChecked})');
      }
    }

    if (checkedItems.isEmpty) {
      if (kDebugMode) {
        print('⚠️ [ShoppingDS] No se encontraron items con isChecked=true');
      }
      return;
    }

    final batch = firestore.batch();
    for (final item in checkedItems) {
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection('shoppingItems')
          .doc(item.id);
      batch.delete(docRef);
      if (kDebugMode) {
        print('🗑️ [ShoppingDS] Marcado para borrar: ${item.id}');
      }
    }

    await batch.commit();

    if (kDebugMode) {
      print('✅ [ShoppingDS] ${checkedItems.length} items eliminados');
    }
  }

  Future<double> getTotalPrice() async {
    final userId = auth.currentUser?.uid;
    if (userId == null) return 0.0;

    final items = await getShoppingItems();
    return items.fold<double>(0.0, (sum, item) => sum + item.price);
  }
}