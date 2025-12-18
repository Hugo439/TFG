enum ShoppingItemCategory {
  frutasYVerduras('Frutas y Verduras'),
  carnesYPescados('Carnes y Pescados'),
  lacteos('Lácteos'),
  panaderia('Panadería'),
  bebidas('Bebidas'),
  snacks('Snacks'),
  otros('Otros');

  final String displayName;

  const ShoppingItemCategory(this.displayName);

  /// Convertir a clave de categoría en Firestore
  String get firestoreKey {
    switch (this) {
      case ShoppingItemCategory.frutasYVerduras:
        return 'frutas_y_verduras';
      case ShoppingItemCategory.carnesYPescados:
        return 'carnes_y_pescados';
      case ShoppingItemCategory.lacteos:
        return 'lacteos';
      case ShoppingItemCategory.panaderia:
        return 'panaderia';
      case ShoppingItemCategory.bebidas:
        return 'bebidas';
      case ShoppingItemCategory.snacks:
        return 'snacks';
      case ShoppingItemCategory.otros:
        return 'otros';
    }
  }
}
