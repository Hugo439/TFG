import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_aggregator.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_parser.dart';
import 'package:smartmeal/domain/services/shopping/smart_category_helper.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';

/// Servicio para estimar costes totales de menús y listas de compra.
///
/// Responsabilidades:
/// - Estimar coste total de un WeeklyMenu completo
/// - Agregar ingredientes de múltiples recetas
/// - Precargar categorías de precios para optimización
/// - Aplicar precios personalizados por usuario
///
/// Proceso de estimación:
/// 1. **Parsear ingredientes**: Usa IngredientParser para extraer cantidades
/// 2. **Normalizar nombres**: Usa SmartIngredientNormalizer
/// 3. **Agregar por nombre**: Suma cantidades de ingredientes similares
/// 4. **Categorizar**: Usa SmartCategoryHelper para determinar categorías
/// 5. **Precargar precios**: Carga precios de todas las categorías en paralelo
/// 6. **Estimar precio**: Usa PriceEstimator con overrides de usuario
/// 7. **Sumar total**: Redondea a 2 decimales
///
/// Optimizaciones:
/// - Precarga de categorías reduce llamadas a Firestore
/// - Procesamiento concurrente de múltiples categorías (maxConcurrent: 6)
/// - Reutiliza instancia de PriceEstimator para aprovechar caché
///
/// Ejemplo de uso:
/// ```dart
/// final estimator = CostEstimator(
///   priceEstimator,
///   categoryHelper,
///   normalizer,
///   parser,
/// );
///
/// final totalCost = await estimator.estimateMenuCost(
///   menu,
///   userId: "user123",
/// );
/// print("Coste total: €$totalCost");
/// ```
class CostEstimator {
  final PriceEstimator _priceEstimator;
  final SmartCategoryHelper _categoryHelper;
  final SmartIngredientNormalizer _normalizer;
  final IngredientParser _parser;

  CostEstimator(
    this._priceEstimator,
    this._categoryHelper,
    this._normalizer,
    this._parser,
  );

  /// Estima coste total de un menú semanal.
  ///
  /// [menu] - Menú semanal con 7 días de recetas.
  /// [userId] - ID del usuario para aplicar precios personalizados (opcional).
  ///
  /// Returns: Coste total estimado en euros (2 decimales).
  ///
  /// Proceso:
  /// 1. Agregar todos los ingredientes de las 28 recetas
  /// 2. Identificar categorías únicas
  /// 3. Precargar precios de todas las categorías
  /// 4. Estimar precio de cada ingrediente agregado
  /// 5. Sumar y redondear total
  ///
  /// Nota: Si userId es null, usa usuario actual de FirebaseAuth o
  /// estima sin overrides personalizados.
  Future<double> estimateMenuCost(WeeklyMenu menu, {String? userId}) async {
    double totalCost = 0;

    // 1) Agregar ingredientes de toda la semana
    final aggregator = IngredientAggregator();
    for (final day in menu.days) {
      for (final r in day.recipes) {
        for (final ingRaw in r.ingredients) {
          final portion = _parser.parse(ingRaw);
          final normalizedName = _normalizer.normalize(portion.name);
          if (normalizedName.isEmpty) continue;
          final normalizedPortion = portion.copyWith(name: normalizedName);
          aggregator.addPortion(normalizedPortion, menu.name);
        }
      }
    }

    final aggregated = aggregator.toList();

    // 2) Precargar categorías necesarias
    final Set<String> categories = {};
    for (final item in aggregated) {
      final cat = _categoryHelper.guessCategory(item.name);
      categories.add(cat.firestoreKey);
    }
    for (final catKey in categories) {
      await _priceEstimator.preloadCategoryPrices(catKey);
    }

    // 3) Construir estimador con usuario (si se pasa null, no aplica overrides)
    final effectiveUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;
    final userAwareEstimator = PriceEstimator(
      getIngredientPriceUseCase: _priceEstimator.getIngredientPriceUseCase,
      getPricesByCategoryUseCase: _priceEstimator.getPricesByCategoryUseCase,
      userId: effectiveUserId,
    );

    // 4) Estimar coste de cada agregado
    for (final item in aggregated) {
      final cat = _categoryHelper.guessCategory(item.name);
      final price = await userAwareEstimator.estimatePrice(
        ingredientName: item.name,
        category: cat.firestoreKey,
        kind: item.unitKind,
        base: item.totalBase,
      );
      totalCost += price;
    }

    return double.parse(totalCost.toStringAsFixed(2));
  }

  /// Precarga precios de categorías para lista agregada.
  ///
  /// [aggregated] - Lista de ingredientes ya agregados.
  /// [maxConcurrent] - Máximo de precargas concurrentes (default: 6).
  ///
  /// Utilidad:
  /// - Optimiza estimación de listas grandes
  /// - Reduce latencia al cargar categorías en paralelo
  /// - Útil antes de estimar precios de múltiples ingredientes
  ///
  /// Procesa categorías en chunks para controlar concurrencia.
  Future<void> preloadCategoriesForAggregated(
    List<AggregatedIngredient> aggregated, {
    int maxConcurrent = 6,
  }) async {
    final categories = <String>{};
    for (final item in aggregated) {
      final cat = _categoryHelper.guessCategory(item.name);
      categories.add(cat.firestoreKey);
    }

    final catList = categories.toList();
    for (int i = 0; i < catList.length; i += maxConcurrent) {
      final chunk = catList.sublist(
        i,
        i + maxConcurrent > catList.length ? catList.length : i + maxConcurrent,
      );
      await Future.wait(chunk.map(_priceEstimator.preloadCategoryPrices));
    }
  }
}
