import 'package:smartmeal/domain/entities/menu_item.dart';
import 'package:smartmeal/domain/value_objects/menu_item_name.dart';
import 'package:smartmeal/domain/value_objects/menu_item_description.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Mapper para convertir entre MenuItem (dominio) y datos de Firestore.
///
/// Responsabilidades:
/// - **fromFirestore**: Map de Firestore → MenuItem con Value Objects
/// - **toFirestore**: MenuItem → Map para actualización
/// - **toFirestoreCreate**: MenuItem → Map para creación inicial
///
/// Value Objects:
/// - MenuItemName: validación de longitud
/// - MenuItemDescription: validación de contenido
///
/// Manejo de timestamps:
/// - createdAt: FieldValue.serverTimestamp() solo en create
/// - updatedAt: FieldValue.serverTimestamp() en create y update
///
/// Nota: MenuItem parece ser una entidad legacy o de prueba, las recetas
/// reales usan Recipe entity.
class MenuItemMapper {
  /// Convierte datos de Firestore a MenuItem entity.
  ///
  /// [data] - Mapa desde documento de Firestore.
  ///
  /// Returns: MenuItem con Value Objects validados.
  ///
  /// Defaults:
  /// - id: '' si no está presente
  /// - name, description: '' si no están presentes
  /// - ingredients: [] si no está presente
  /// - createdAt: DateTime.now() si falta
  /// - imageUrl, updatedAt: null permitidos
  static MenuItem fromFirestore(Map<String, dynamic> data) {
    return MenuItem(
      id: data['id'] ?? '',
      name: MenuItemName(data['name'] ?? ''),
      description: MenuItemDescription(data['description'] ?? ''),
      imageUrl: data['imageUrl'],
      ingredients: List<String>.from(data['ingredients'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convierte MenuItem a Map para actualización en Firestore.
  ///
  /// [menuItem] - Entidad del dominio.
  ///
  /// Returns: Map con updatedAt server timestamp.
  ///
  /// Nota: No incluye 'id' ni 'createdAt' porque son inmutables.
  static Map<String, dynamic> toFirestore(MenuItem menuItem) {
    return {
      'name': menuItem.name.value,
      'description': menuItem.description.value,
      'imageUrl': menuItem.imageUrl,
      'ingredients': menuItem.ingredients,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convierte MenuItem a Map para creación inicial en Firestore.
  ///
  /// [menuItem] - Entidad del dominio.
  ///
  /// Returns: Map con createdAt y updatedAt server timestamps.
  static Map<String, dynamic> toFirestoreCreate(MenuItem menuItem) {
    return {
      ...toFirestore(menuItem),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
