import 'package:smartmeal/domain/entities/price_entry.dart';
import 'package:smartmeal/domain/value_objects/unit_kind.dart';

/// Modelo de datos para entrada de precio en el catálogo global.
///
/// Responsabilidad:
/// - Persistir precios de referencia del catálogo en Firestore
/// - Convertir entre modelo y entidad del dominio
///
/// Usado por:
/// - PriceDatabaseService para lookups de precios
/// - SeasonalPricingService para ajustes estacionales
///
/// Campos:
/// - **id**: ingrediente normalizado ("pollo", "arroz", "leche")
/// - **displayName**: nombre para mostrar ("Pollo")
/// - **category**: categoría ("carnesYPescados", "lacteos", etc.)
/// - **unitKind**: tipo de unidad ("weight", "volume", "unit")
/// - **priceRef**: precio de referencia en €/kg o €/L o €/ud
/// - **brand**: marca opcional ("Hacendado", "Carrefour")
/// - **lastUpdated**: timestamp última actualización ISO 8601
///
/// Ruta Firestore:
/// ```
/// price_catalog/{ingredientId}
/// ```
///
/// Ejemplo:
/// ```json
/// {
///   "displayName": "Pollo",
///   "category": "carnesYPescados",
///   "unitKind": "weight",
///   "priceRef": 8.0,
///   "brand": "Mercadona",
///   "lastUpdated": "2024-01-15T10:00:00.000Z"
/// }
/// ```
class PriceEntryModel {
  final String id;
  final String displayName;
  final String category;
  final String unitKind;
  final double priceRef;
  final String? brand;
  final String lastUpdated;

  const PriceEntryModel({
    required this.id,
    required this.displayName,
    required this.category,
    required this.unitKind,
    required this.priceRef,
    this.brand,
    required this.lastUpdated,
  });

  /// Crea modelo desde Map de Firestore.
  ///
  /// id viene como parámetro separado (document ID).
  /// Maneja campos faltantes con valores por defecto.
  factory PriceEntryModel.fromFirestore(Map<String, dynamic> map, String id) {
    return PriceEntryModel(
      id: id,
      displayName: map['displayName'] as String? ?? id,
      category: map['category'] as String,
      unitKind: map['unitKind'] as String? ?? 'weight',
      priceRef: (map['priceRef'] as num).toDouble(),
      brand: map['brand'] as String?,
      lastUpdated:
          map['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  /// Convierte a Map para persistencia en Firestore.
  ///
  /// No incluye 'id' (está en document path).
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'category': category,
      'unitKind': unitKind,
      'priceRef': priceRef,
      if (brand != null) 'brand': brand,
      'lastUpdated': lastUpdated,
    };
  }

  /// Convierte modelo a entidad del dominio.
  ///
  /// Parsea:
  /// - unitKind string → UnitKind enum
  /// - lastUpdated string → DateTime
  PriceEntry toEntity() {
    return PriceEntry(
      id: id,
      displayName: displayName,
      category: category,
      unitKind: UnitKindExtension.fromFirestore(unitKind),
      priceRef: priceRef,
      brand: brand,
      lastUpdated: DateTime.parse(lastUpdated),
    );
  }

  /// Crea modelo desde entidad del dominio.
  ///
  /// Convierte:
  /// - UnitKind enum → unitKind string
  /// - DateTime → lastUpdated ISO 8601
  factory PriceEntryModel.fromEntity(PriceEntry entity) {
    return PriceEntryModel(
      id: entity.id,
      displayName: entity.displayName,
      category: entity.category,
      unitKind: entity.unitKind.toFirestore(),
      priceRef: entity.priceRef,
      brand: entity.brand,
      lastUpdated: entity.lastUpdated.toIso8601String(),
    );
  }
}
