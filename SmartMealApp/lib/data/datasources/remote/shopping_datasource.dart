import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/models/shopping_item_model.dart';
import 'package:smartmeal/core/errors/errors.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

/// Datasource para operaciones CRUD de items de lista de compras en Firestore.
///
/// Estructura en Firestore:
/// ```
/// users/{userId}/shopping_items/{itemId}
/// ```
///
/// Funcionalidades:
/// - CRUD de items individuales
/// - Operaciones batch (añadir múltiples items de una vez)
/// - Marcar/desmarcar items como comprados
/// - Eliminar items comprados en batch
/// - Calcular precio total
///
/// Ordenamiento: Items ordenados por createdAt descendente (más recientes primero).
///
/// Nota: Todas las operaciones requieren usuario autenticado.
class ShoppingDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ShoppingDataSource({required this.firestore, required this.auth});

  /// Obtiene todos los items de la lista de compras del usuario.
  ///
  /// Returns: Lista de items ordenados por fecha de creación (más recientes primero).
  ///
  /// Throws: [AuthFailure] si no hay usuario autenticado.
  Future<List<ShoppingItemModel>> getShoppingItems() async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw AuthFailure('Usuario no autenticado');

    final snapshot = await firestore
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .collection(AppConstants.collectionShoppingItems)
        .orderBy(AppConstants.fieldCreatedAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ShoppingItemModel.fromFirestore(doc))
        .toList();
  }

  /// Añade un nuevo item a la lista de compras.
  ///
  /// [id] - ID único del item.
  /// [data] - Datos del item (mapa para Firestore).
  ///
  /// Throws: [AuthFailure] si no hay usuario autenticado.
  Future<void> addShoppingItem(String id, Map<String, dynamic> data) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw AuthFailure('Usuario no autenticado');

    await firestore
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .collection(AppConstants.collectionShoppingItems)
        .doc(id)
        .set(data);
  }

  /// Escribe múltiples items en una sola transacción batch.
  ///
  /// [items] - Lista de mapas con datos de items. Cada item debe tener un 'id' o se generará automáticamente.
  ///
  /// Más eficiente que llamar [addShoppingItem] múltiples veces:
  /// - Una sola transacción de red
  /// - Atómico (todo o nada)
  /// - Más rápido para listas grandes
  ///
  /// Throws: [AuthFailure] si no hay usuario autenticado.
  ///
  /// Nota: Si la lista está vacía, no hace nada.
  Future<void> addShoppingItemsBatch(List<Map<String, dynamic>> items) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw AuthFailure('Usuario no autenticado');

    if (items.isEmpty) return;

    final batch = firestore.batch();
    for (final item in items) {
      final itemId =
          item['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final ref = firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionShoppingItems)
          .doc(itemId);
      batch.set(ref, item);
    }

    await batch.commit();
    if (kDebugMode) {
      print('✅ [ShoppingDS] ${items.length} items guardados en batch');
    }
  }

  /// Actualiza un item existente.
  ///
  /// [id] - ID del item a actualizar.
  /// [data] - Campos a actualizar (mapa parcial).
  ///
  /// Throws: [AuthFailure] si no hay usuario autenticado.
  Future<void> updateShoppingItem(String id, Map<String, dynamic> data) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw AuthFailure('Usuario no autenticado');

    await firestore
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .collection(AppConstants.collectionShoppingItems)
        .doc(id)
        .update(data);
  }

  /// Elimina un item de la lista.
  ///
  /// [id] - ID del item a eliminar.
  ///
  /// Throws: [AuthFailure] si no hay usuario autenticado.
  Future<void> deleteShoppingItem(String id) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw AuthFailure('Usuario no autenticado');

    await firestore
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .collection(AppConstants.collectionShoppingItems)
        .doc(id)
        .delete();
  }

  /// Elimina todos los items marcados como comprados (isChecked = true).
  ///
  /// [userId] - ID del usuario.
  ///
  /// Proceso:
  /// 1. Cargar todos los items del usuario
  /// 2. Filtrar los que tienen isChecked = true
  /// 3. Eliminar en batch
  ///
  /// Nota: Imprime logs detallados en debug mode para facilitar depuración.
  Future<void> deleteCheckedItems(String userId) async {
    if (kDebugMode) {
      print('🗑️ [ShoppingDS] Buscando items marcados para userId: $userId');
    }

    // Obtener TODOS los items primero
    final snap = await firestore
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .collection(AppConstants.collectionShoppingItems)
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
      print(
        '🗑️ [ShoppingDS] Items marcados encontrados: ${checkedItems.length}',
      );
      for (var item in checkedItems) {
        print(
          '   - ${item.id}: ${item.name} (${AppConstants.fieldIsChecked}: ${item.isChecked})',
        );
      }
    }

    if (checkedItems.isEmpty) {
      if (kDebugMode) {
        print(
          '⚠️ [ShoppingDS] No se encontraron items con ${AppConstants.fieldIsChecked}=true',
        );
      }
      return;
    }

    final batch = firestore.batch();
    for (final item in checkedItems) {
      final docRef = firestore
          .collection(AppConstants.collectionUsers)
          .doc(userId)
          .collection(AppConstants.collectionShoppingItems)
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

  /// Calcula el precio total de todos los items.
  ///
  /// Returns: Suma de precios de todos los items, o 0.0 si no hay usuario autenticado.
  Future<double> getTotalPrice() async {
    final userId = auth.currentUser?.uid;
    if (userId == null) return 0.0;

    final items = await getShoppingItems();
    return items.fold<double>(
      0.0,
      (accumulator, item) => accumulator + item.price,
    );
  }

  /// Marca o desmarca todos los items como comprados.
  ///
  /// [checked] - Estado a aplicar (true = comprado, false = pendiente).
  ///
  /// Operación batch para eficiencia.
  ///
  /// Throws: [AuthFailure] si no hay usuario autenticado.
  Future<void> setAllChecked(bool checked) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw AuthFailure('Usuario no autenticado');

    final snap = await firestore
        .collection(AppConstants.collectionUsers)
        .doc(userId)
        .collection(AppConstants.collectionShoppingItems)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {AppConstants.fieldIsChecked: checked});
    }
    await batch.commit();

    if (kDebugMode) {
      print(
        '✅ [ShoppingDS] setAllChecked -> $checked en ${snap.docs.length} items',
      );
    }
  }
}
