import 'package:smartmeal/domain/entities/menu_item.dart';
import 'package:smartmeal/domain/value_objects/menu_item_name.dart';
import 'package:smartmeal/domain/value_objects/menu_item_description.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemMapper {
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

  static Map<String, dynamic> toFirestore(MenuItem menuItem) {
    return {
      'name': menuItem.name.value,
      'description': menuItem.description.value,
      'imageUrl': menuItem.imageUrl,
      'ingredients': menuItem.ingredients,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> toFirestoreCreate(MenuItem menuItem) {
    return {
      ...toFirestore(menuItem),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}