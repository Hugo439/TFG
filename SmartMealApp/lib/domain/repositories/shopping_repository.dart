import 'package:smartmeal/domain/entities/shopping_item.dart';

/// Contrato para operaciones sobre la lista de compras.
///
/// Gestiona los [ShoppingItem] que se generan automáticamente desde
/// los ingredientes de los menús semanales.
///
/// **Funcionalidades:**
/// - Obtención de items de la lista
/// - Añadir items individuales o en lote (batch)
/// - Marcar items como comprados (checked)
/// - Eliminar items individuales o todos los comprados
/// - Cálculo del costo total estimado
/// - Caché local para mejor rendimiento
///
/// Los items se agrupan por producto, sumando cantidades de
/// múltiples recetas que usan el mismo ingrediente.
abstract class ShoppingRepository {
  /// Obtiene todos los items de la lista de compras del usuario.
  ///
  /// **Retorna:** Lista de items ordenados por categoría y nombre.
  Future<List<ShoppingItem>> getShoppingItems();

  /// Añade un item individual a la lista de compras.
  ///
  /// **Parámetro:**
  /// - [item]: Item a añadir
  Future<void> addShoppingItem(ShoppingItem item);

  /// Añade múltiples items en una operación batch.
  ///
  /// **Parámetro:**
  /// - [items]: Lista de items a añadir
  ///
  /// Más eficiente que llamar [addShoppingItem] múltiples veces.
  /// Se usa al generar lista desde un menú completo.
  Future<void> addShoppingItemsBatch(List<ShoppingItem> items);

  /// Actualiza un item existente en la lista.
  ///
  /// **Parámetro:**
  /// - [item]: Item con datos actualizados
  Future<void> updateShoppingItem(ShoppingItem item);

  /// Marca/desmarca un item como comprado.
  ///
  /// **Parámetros:**
  /// - [id]: ID del item
  /// - [isChecked]: `true` para marcar como comprado, `false` para desmarcar
  Future<void> toggleItemChecked(String id, bool isChecked);

  /// Elimina un item individual de la lista.
  ///
  /// **Parámetro:**
  /// - [itemId]: ID del item a eliminar
  Future<void> deleteShoppingItem(String itemId);

  /// Elimina todos los items marcados como comprados.
  ///
  /// **Parámetro:**
  /// - [userId]: ID del usuario
  ///
  /// Útil para limpiar la lista después de comprar.
  Future<void> deleteCheckedItems(String userId);

  /// Calcula el precio total estimado de la lista.
  ///
  /// **Retorna:** Suma de todos los precios de los items.
  Future<double> getTotalPrice();

  /// Marca/desmarca todos los items.
  ///
  /// **Parámetro:**
  /// - [checked]: `true` para marcar todos, `false` para desmarcar todos
  ///
  /// Útil para "seleccionar todo" o "deseleccionar todo".
  Future<void> setAllChecked(bool checked);

  /// Limpia la caché local de shopping items.
  ///
  /// Fuerza a recargar datos desde Firestore en la próxima petición.
  Future<void> clearLocalCache();
}
