import 'package:smartmeal/domain/value_objects/shopping_item_name.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_quantity.dart';
import 'package:smartmeal/domain/value_objects/price.dart';

/// Entidad que representa un item en la lista de compras.
///
/// Agrupa ingredientes similares de múltiples recetas del menú semanal,
/// facilitando la compra organizada por categorías (supermercado, frutería, etc).
///
/// **Características:**
/// - Agrupa cantidades de ingredientes repetidos
/// - Estima precio basado en catálogo
/// - Organiza por categorías de tienda
/// - Permite marcar items como comprados
/// - Rastrea qué menús usan cada ingrediente
class ShoppingItem {
  /// ID único del item en Firestore.
  final String id;

  /// Nombre del producto (validado por ShoppingItemName).
  final ShoppingItemName name;

  /// Cantidad necesaria con unidad (ej: "500g", "2 unidades").
  final ShoppingItemQuantity quantity;

  /// Precio estimado del producto.
  final Price price;

  /// Categoría de tienda: "Supermercado", "Frutería", "Carnicería", "Quesería".
  /// Ayuda a organizar la ruta de compra.
  final String category;

  /// IDs de los menús semanales que requieren este ingrediente.
  /// Permite rastrear el origen de cada item.
  final List<String> usedInMenus;

  /// Indica si el item ya fue comprado/completado.
  final bool isChecked;

  /// Timestamp de creación del item.
  final DateTime createdAt;

  /// Crea una instancia de [ShoppingItem].
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    required this.usedInMenus,
    this.isChecked = false,
    required this.createdAt,
  });

  // ==================== Helper Getters ====================

  /// Obtiene el nombre del producto como String.
  String get nameValue => name.value;

  /// Obtiene la cantidad como String (incluye unidad).
  String get quantityValue => quantity.value;

  /// Obtiene el precio como double.
  double get priceValue => price.value;

  /// Crea una copia del item con campos actualizados.
  ///
  /// Útil para marcar items como comprados o actualizar cantidades.
  ShoppingItem copyWith({
    String? id,
    ShoppingItemName? name,
    ShoppingItemQuantity? quantity,
    Price? price,
    String? category,
    List<String>? usedInMenus,
    bool? isChecked,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: category ?? this.category,
      usedInMenus: usedInMenus ?? this.usedInMenus,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
