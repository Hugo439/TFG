import 'package:smartmeal/domain/services/shopping/price_database.dart';
import 'package:smartmeal/domain/value_objects/shopping_item_unit_kind.dart';

/// Calcula el precio total basado en el precio por unidad y la cantidad
double calculatePriceWithQuantity({
  required double pricePerUnit,
  required double quantityBase,
  required UnitKind unitKind,
  required String ingredientName,
}) {
  // Detectar el tipo de unidad del ingrediente en la base de datos
  UnitType unitType = UnitType.weight; // Default

  if (PriceDatabase.specificPrices.containsKey(ingredientName)) {
    unitType = PriceDatabase.specificPrices[ingredientName]!.unitType;
  }

  // Calcular según el tipo de unidad
  if (unitType == UnitType.piece && unitKind == UnitKind.unit) {
    // Precio por unidad: multiplicar directamente
    return (pricePerUnit * quantityBase).clamp(0.1, 100.0);
  }

  if (unitType == UnitType.weight && unitKind == UnitKind.weight) {
    // Precio por kg: convertir gramos a kg
    final kg = quantityBase / 1000.0;
    return (pricePerUnit * kg).clamp(0.1, 200.0);
  }

  if (unitType == UnitType.liter && unitKind == UnitKind.volume) {
    // Precio por litro: convertir ml a L
    final liters = quantityBase / 1000.0;
    return (pricePerUnit * liters).clamp(0.1, 100.0);
  }

  // Fallback: tratar como peso
  final kg = quantityBase / 1000.0;
  return (pricePerUnit * kg).clamp(0.1, 200.0);
}
