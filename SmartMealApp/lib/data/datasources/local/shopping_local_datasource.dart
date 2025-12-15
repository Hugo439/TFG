import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartmeal/data/models/shopping_item_model.dart';

/// Datasource local para cachear la lista de compra
class ShoppingLocalDatasource {
  static const String _cacheKey = 'shopping_list_cache';

  final SharedPreferences _prefs;

  ShoppingLocalDatasource(this._prefs);

  /// Obtiene la lista de compra cacheada localmente
  /// Retorna null si no hay caché disponible
  Future<List<ShoppingItemModel>?> getCachedShoppingItems() async {
    try {
      final jsonString = _prefs.getString(_cacheKey);
      if (jsonString == null) {
        if (kDebugMode) {
          print('📦 [ShoppingLocalDS] No hay caché de compra');
        }
        return null;
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final items = jsonList
          .map((item) => _shoppingItemModelFromJson(item as Map<String, dynamic>))
          .toList();

      if (kDebugMode) {
        print('📦 [ShoppingLocalDS] Caché cargado: ${items.length} items');
      }

      return items;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ShoppingLocalDS] Error al cargar caché: $e');
      }
      return null;
    }
  }

  /// Guarda la lista de compra en caché local
  Future<void> cacheShoppingItems(List<ShoppingItemModel> items) async {
    try {
      final jsonList = items.map((item) => _shoppingItemModelToJson(item)).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_cacheKey, jsonString);

      if (kDebugMode) {
        print('💾 [ShoppingLocalDS] Caché guardado: ${items.length} items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ShoppingLocalDS] Error al guardar caché: $e');
      }
    }
  }

  /// Limpia el caché local (se llama al generar una nueva lista)
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_cacheKey);
      if (kDebugMode) {
        print('🗑️  [ShoppingLocalDS] Caché limpiado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ShoppingLocalDS] Error al limpiar caché: $e');
      }
    }
  }

  // ===== HELPERS para serialización =====

  /// Convierte ShoppingItemModel a JSON
  static Map<String, dynamic> _shoppingItemModelToJson(ShoppingItemModel item) {
    return {
      'id': item.id,
      'name': item.name,
      'quantity': item.quantity,
      'price': item.price,
      'category': item.category,
      'usedInMenus': item.usedInMenus,
      'isChecked': item.isChecked,
      'createdAt': item.createdAt.toIso8601String(),
    };
  }

  /// Convierte JSON a ShoppingItemModel
  static ShoppingItemModel _shoppingItemModelFromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'Supermercado',
      usedInMenus: List<String>.from(json['usedInMenus'] as List<dynamic>? ?? []),
      isChecked: json['isChecked'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
