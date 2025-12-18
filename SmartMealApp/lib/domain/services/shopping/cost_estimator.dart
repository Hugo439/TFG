import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_aggregator.dart';
import 'package:smartmeal/domain/services/shopping/ingredient_parser.dart';
import 'package:smartmeal/domain/services/shopping/smart_category_helper.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';

/// Servicio reutilizable para estimar costes a partir de menús o listas
/// agregadas de ingredientes. Encapsula la lógica de preload de categorías,
/// normalización, agregación y aplicación de precios personalizados por usuario.
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

  /// Estima el coste total de un [WeeklyMenu].
  /// - Agrega ingredientes por nombre normalizado y unidad base
  /// - Precarga precios por categoría
  /// - Aplica overrides de usuario si hay sesión
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

  /// Precarga precios por categoría para una lista agregada de ingredientes.
  /// Útil para listas de la compra ya agregadas para minimizar lecturas.
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
