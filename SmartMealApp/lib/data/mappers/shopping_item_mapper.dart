import 'package:smartmeal/domain/entities/shopping_item.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_name.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_quantity.dart';
import 'package:smartmeal/domain/value_objects/price.dart';
import 'package:smartmeal/data/models/shopping_item_model.dart';

/// Mapper para convertir entre ShoppingItem (dominio) y ShoppingItemModel (datos).
///
/// Conversiones:
/// - **fromModel**: Model → Entity (con Value Objects)
/// - **toModel**: Entity → Model (valores primitivos)
///
/// Los Value Objects encapsulan validación:
/// - ShoppingItemName: validación de longitud
/// - ShoppingItemQuantity: formato de cantidad con unidad
/// - Price: validación de precio >= 0
///
/// Uso típico:
/// ```dart
/// // Desde Firestore
/// final model = ShoppingItemModel.fromFirestore(doc);
/// final entity = ShoppingItemMapper.fromModel(model);
///
/// // Hacia Firestore
/// final model = ShoppingItemMapper.toModel(entity);
/// await firestore.doc(id).set(model.toFirestore());
/// ```
class ShoppingItemMapper {
  /// Convierte Model (capa de datos) a Entity (dominio).
  ///
  /// Encapsula valores primitivos en Value Objects que validan:
  /// - name: no vacío, longitud máxima
  /// - quantity: formato válido (ej: "200 g", "2 ud")
  /// - price: >= 0
  ///
  /// [model] - Modelo desde Firestore.
  ///
  /// Returns: ShoppingItem con Value Objects validados.
  static ShoppingItem fromModel(ShoppingItemModel model) {
    return ShoppingItem(
      id: model.id,
      name: ShoppingItemName(model.name),
      quantity: ShoppingItemQuantity(model.quantity),
      price: Price(model.price),
      category: model.category,
      usedInMenus: model.usedInMenus,
      isChecked: model.isChecked,
      createdAt: model.createdAt,
    );
  }

  /// Convierte Entity (dominio) a Model (capa de datos).
  ///
  /// Extrae valores primitivos de los Value Objects para persistencia.
  ///
  /// [item] - Entidad del dominio.
  ///
  /// Returns: Modelo listo para Firestore.
  static ShoppingItemModel toModel(ShoppingItem item) {
    return ShoppingItemModel(
      id: item.id,
      name: item.name.value,
      quantity: item.quantity.value,
      price: item.price.value,
      category: item.category,
      usedInMenus: item.usedInMenus,
      isChecked: item.isChecked,
      createdAt: item.createdAt,
    );
  }
}
