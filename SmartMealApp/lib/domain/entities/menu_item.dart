import 'package:smartmeal/domain/value_objects/menu_item_name.dart';
import 'package:smartmeal/domain/value_objects/menu_item_description.dart';

class MenuItem {
  final String id;
  final MenuItemName name;
  final MenuItemDescription description;
  final String? imageUrl;
  final List<String> ingredients;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.ingredients,
    required this.createdAt,
    this.updatedAt,
  });

  // Helper getters
  String get nameValue => name.value;
  String get descriptionValue => description.value;
  
  MenuItem copyWith({
    String? id,
    MenuItemName? name,
    MenuItemDescription? description,
    String? imageUrl,
    List<String>? ingredients,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}