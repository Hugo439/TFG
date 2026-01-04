import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para ShoppingItem compatible con Firestore.
///
/// Responsabilidades:
/// - Serialización/deserialización desde/hacia Firestore
/// - Almacenar datos primitivos de items de compra
/// - Proveer métodos de conversión y actualización
///
/// Campos:
/// - **id**: ID único del item
/// - **name**: nombre del ingrediente
/// - **quantity**: cantidad con unidad (ej: "500 g", "2 ud")
/// - **price**: precio estimado en euros
/// - **category**: categoría (lacteos, carnesYPescados, etc.)
/// - **usedInMenus**: lista de IDs de menús donde se usa
/// - **isChecked**: true si ya comprado, false si pendiente
/// - **createdAt**: timestamp de creación
///
/// Métodos:
/// - **fromFirestore**: DocumentSnapshot → ShoppingItemModel
/// - **toFirestore**: ShoppingItemModel → Map para update
/// - **toFirestoreCreate**: ShoppingItemModel → Map para create (con serverTimestamp)
/// - **copyWith**: crear copia con campos modificados
///
/// Ejemplo Firestore:
/// ```json
/// {
///   "name": "Pollo",
///   "quantity": "500 g",
///   "price": 4.0,
///   "category": "carnesYPescados",
///   "usedInMenus": ["menu_123", "menu_456"],
///   "isChecked": false,
///   "createdAt": "2024-01-01T10:00:00.000Z"
/// }
/// ```
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

  /// Crea modelo desde DocumentSnapshot de Firestore.
  ///
  /// Maneja campos faltantes con valores por defecto.
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

  /// Convierte a Map para actualización en Firestore.
  ///
  /// Incluye todos los campos incluido 'id'.
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

  /// Convierte a Map para creación en Firestore.
  ///
  /// Usa FieldValue.serverTimestamp() para createdAt.
  /// No incluye 'id' porque Firestore lo genera.
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

  /// Crea copia del modelo con campos opcionales modificados.
  ///
  /// Útil para actualizaciones parciales.
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
