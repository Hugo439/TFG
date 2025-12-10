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
}