import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItemModel {
  final String id;
  final String name;
  final String quantity;
  final double price;
  final String category;
  final List<String> usedInMenus;
  final bool isChecked;
  final DateTime createdAt;

  ShoppingItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    required this.usedInMenus,
    required this.isChecked,
    required this.createdAt,
  });

  /// Crear desde Firestore DocumentSnapshot
  factory ShoppingItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? 'Supermercado',
      usedInMenus: List<String>.from(data['usedInMenus'] ?? []),
      isChecked: data['isChecked'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convertir a Map para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category,
      'usedInMenus': usedInMenus,
      'isChecked': isChecked,
      'createdAt': createdAt,
    };
  }

  /// Convertir a Map para crear documento (con serverTimestamp)
  Map<String, dynamic> toFirestoreCreate() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category,
      'usedInMenus': usedInMenus,
      'isChecked': isChecked,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// CopyWith para actualizaciones
  ShoppingItemModel copyWith({
    String? id,
    String? name,
    String? quantity,
    double? price,
    String? category,
    List<String>? usedInMenus,
    bool? isChecked,
    DateTime? createdAt,
  }) {
    return ShoppingItemModel(
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

  @override
  String toString() {
    return 'ShoppingItemModel(id: $id, name: $name, quantity: $quantity, price: $price, isChecked: $isChecked)';
  }
}
