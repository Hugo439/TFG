import 'package:smartmeal/domain/entities/missing_price_entry.dart';
import 'package:smartmeal/domain/value_objects/unit_kind.dart';

/// Modelo de datos para ingrediente sin precio en catálogo.
///
/// Responsabilidad:
/// - Rastrear ingredientes que faltan en price_catalog
/// - Contar cuántas veces se solicita cada ingrediente
/// - Priorizar cuáles añadir al catálogo
///
/// Usado cuando:
/// - PriceDatabaseService no encuentra precio para ingrediente
/// - Se incrementa requestCount cada vez que se solicita
///
/// Campos:
/// - **normalizedName**: ingrediente normalizado ("aguacate", "quinoa")
/// - **ingredientName**: nombre original del ingrediente
/// - **category**: categoría inferida
/// - **unitKind**: tipo de unidad inferida ("weight", "volume", "unit")
/// - **requestCount**: número de veces solicitado
/// - **firstRequested**: timestamp primera solicitud ISO 8601
/// - **lastRequested**: timestamp última solicitud ISO 8601
///
/// Ruta Firestore:
/// ```
/// missing_prices/{normalizedName}
/// ```
///
/// Ejemplo:
/// ```json
/// {
///   "ingredientName": "Aguacate",
///   "category": "frutasYVerduras",
///   "unitKind": "weight",
///   "requestCount": 15,
///   "firstRequested": "2024-01-01T10:00:00.000Z",
///   "lastRequested": "2024-01-15T14:30:00.000Z"
/// }
/// ```
///
/// Workflow:
/// 1. Usuario genera menú con aguacate
/// 2. PriceDatabaseService no encuentra precio
/// 3. Incrementa requestCount en missing_prices/aguacate
/// 4. Admin revisa missing_prices para añadir precios más solicitados
class MissingPriceEntryModel {
  final String normalizedName;
  final String ingredientName;
  final String category;
  final String unitKind;
  final int requestCount;
  final String firstRequested;
  final String lastRequested;

  const MissingPriceEntryModel({
    required this.normalizedName,
    required this.ingredientName,
    required this.category,
    required this.unitKind,
    required this.requestCount,
    required this.firstRequested,
    required this.lastRequested,
  });

  /// Crea modelo desde Map de Firestore.
  ///
  /// id (normalizedName) viene como parámetro separado.
  /// Maneja campos faltantes con valores por defecto.
  factory MissingPriceEntryModel.fromFirestore(
    Map<String, dynamic> map,
    String id,
  ) {
    return MissingPriceEntryModel(
      normalizedName: id,
      ingredientName: map['ingredientName'] as String? ?? id,
      category: map['category'] as String,
      unitKind: map['unitKind'] as String? ?? 'weight',
      requestCount: map['requestCount'] as int? ?? 1,
      firstRequested:
          map['firstRequested'] as String? ?? DateTime.now().toIso8601String(),
      lastRequested:
          map['lastRequested'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  /// Convierte a Map para persistencia en Firestore.
  ///
  /// No incluye normalizedName (está en document path).
  Map<String, dynamic> toFirestore() {
    return {
      'ingredientName': ingredientName,
      'category': category,
      'unitKind': unitKind,
      'requestCount': requestCount,
      'firstRequested': firstRequested,
      'lastRequested': lastRequested,
    };
  }

  /// Convierte modelo a entidad del dominio.
  ///
  /// Parsea:
  /// - unitKind string → UnitKind enum
  /// - firstRequested/lastRequested strings → DateTime
  MissingPriceEntry toEntity() {
    return MissingPriceEntry(
      ingredientName: ingredientName,
      normalizedName: normalizedName,
      category: category,
      unitKind: UnitKindExtension.fromFirestore(unitKind),
      requestCount: requestCount,
      firstRequested: DateTime.parse(firstRequested),
      lastRequested: DateTime.parse(lastRequested),
    );
  }

  /// Crea modelo desde entidad del dominio.
  ///
  /// Convierte:
  /// - UnitKind enum → unitKind string
  /// - DateTime → ISO 8601 strings
  factory MissingPriceEntryModel.fromEntity(MissingPriceEntry entity) {
    return MissingPriceEntryModel(
      normalizedName: entity.normalizedName,
      ingredientName: entity.ingredientName,
      category: entity.category,
      unitKind: entity.unitKind.toFirestore(),
      requestCount: entity.requestCount,
      firstRequested: entity.firstRequested.toIso8601String(),
      lastRequested: entity.lastRequested.toIso8601String(),
    );
  }
}
