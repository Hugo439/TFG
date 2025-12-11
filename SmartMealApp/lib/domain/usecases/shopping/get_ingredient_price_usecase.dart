import 'package:smartmeal/core/errors/failures.dart';
import 'package:smartmeal/domain/repositories/price_catalog_repository.dart';
import 'package:smartmeal/domain/repositories/user_price_repository.dart';
import 'package:smartmeal/domain/repositories/missing_price_repository.dart';
import 'package:smartmeal/domain/entities/missing_price_entry.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';
import 'package:smartmeal/domain/services/shopping/seasonal_pricing_service.dart';
import 'package:smartmeal/domain/services/shopping/variant_adjustment_service.dart';
import 'package:smartmeal/domain/services/shopping/price_database.dart';
import 'package:smartmeal/domain/value_objects/unit_kind.dart';
import 'package:dartz/dartz.dart';

class GetIngredientPriceParams {
  final String ingredientName;
  final String category;
  final double quantityBase;
  final UnitKind unitKind;
  final String? userId;

  const GetIngredientPriceParams({
    required this.ingredientName,
    required this.category,
    required this.quantityBase,
    required this.unitKind,
    this.userId,
  });
}

class PriceResult {
  final double price;
  final String source; // 'user_override', 'catalog', 'fallback'
  final bool hasVariantAdjustment;
  final bool hasSeasonalAdjustment;
  final List<String> appliedAdjustments;

  const PriceResult({
    required this.price,
    required this.source,
    this.hasVariantAdjustment = false,
    this.hasSeasonalAdjustment = false,
    this.appliedAdjustments = const [],
  });
}

/// Caso de uso principal para obtener precio de un ingrediente
class GetIngredientPriceUseCase {
  final PriceCatalogRepository _catalogRepository;
  final UserPriceRepository _userPriceRepository;
  final MissingPriceRepository _missingPriceRepository;

  GetIngredientPriceUseCase(
    this._catalogRepository,
    this._userPriceRepository,
    this._missingPriceRepository,
  );

  Future<Either<Failure, PriceResult>> call(GetIngredientPriceParams params) async {
    try {
      final normalizedName = SmartIngredientNormalizer().normalize(params.ingredientName);
      final appliedAdjustments = <String>[];

      // PASO 1: Intentar obtener override del usuario
      if (params.userId != null) {
        final userOverrideResult = await _userPriceRepository.getUserPriceOverride(
          userId: params.userId!,
          ingredientId: normalizedName,
        );

        if (userOverrideResult.isRight()) {
          final override = userOverrideResult.getOrElse(() => null);
          if (override != null) {
            final finalPrice = _calculateTotalPrice(
              override.customPrice,
              params.quantityBase,
              params.unitKind,
            );

            return Right(PriceResult(
              price: finalPrice,
              source: 'user_override',
              appliedAdjustments: ['Precio personalizado: €${override.customPrice}'],
            ));
          }
        }
      }

      // PASO 2: Buscar en catálogo Firestore
      final catalogResult = await _catalogRepository.getPriceEntry(normalizedName);
      
      if (catalogResult.isRight()) {
        final entry = catalogResult.getOrElse(() => null);
        
        if (entry != null) {
          double basePrice = entry.priceRef;
          appliedAdjustments.add('Precio base: €$basePrice/${entry.unitKind.largeUnit}');

          // Aplicar ajustes de variantes
          final variantMultiplier = VariantAdjustmentService.getVariantMultiplier(
            params.ingredientName,
          );
          bool hasVariant = false;
          if (variantMultiplier != 1.0) {
            basePrice *= variantMultiplier;
            hasVariant = true;
            appliedAdjustments.add(
              'Ajuste variante: ${(variantMultiplier * 100).toStringAsFixed(0)}%',
            );
          }

          // Aplicar ajuste estacional
          final seasonalMultiplier = SeasonalPricingService.getSeasonalMultiplier(
            normalizedName,
          );
          bool hasSeasonal = false;
          if (seasonalMultiplier != 1.0) {
            basePrice *= seasonalMultiplier;
            hasSeasonal = true;
            appliedAdjustments.add(
              'Ajuste estacional: ${(seasonalMultiplier * 100).toStringAsFixed(0)}%',
            );
          }

          final finalPrice = _calculateTotalPrice(
            basePrice,
            params.quantityBase,
            params.unitKind,
          );

          final clampedPrice = _clampPrice(finalPrice, params.unitKind);

          return Right(PriceResult(
            price: clampedPrice,
            source: 'catalog',
            hasVariantAdjustment: hasVariant,
            hasSeasonalAdjustment: hasSeasonal,
            appliedAdjustments: appliedAdjustments,
          ));
        }
      }

      // PASO 3: Fallback a PriceDatabase hardcoded
      final fallbackPrice = PriceDatabase.getEstimatedPrice(
        ingredientName: params.ingredientName,
        category: params.category,
        quantityBase: params.quantityBase,
        unitKind: params.unitKind.toFirestore(),
      );

      // PASO 4: Registrar como precio faltante
      await _missingPriceRepository.trackMissingPrice(
        MissingPriceEntry(
          ingredientName: params.ingredientName,
          normalizedName: normalizedName,
          category: params.category,
          unitKind: params.unitKind,
          requestCount: 1,
          firstRequested: DateTime.now(),
          lastRequested: DateTime.now(),
        ),
      );

      return Right(PriceResult(
        price: fallbackPrice,
        source: 'fallback',
        appliedAdjustments: ['Precio estimado (fallback)'],
      ));
    } catch (e) {
      return Left(UnknownFailure('Error obteniendo precio: $e'));
    }
  }

  double _calculateTotalPrice(double pricePerUnit, double quantityBase, UnitKind unitKind) {
    if (unitKind == UnitKind.weight) {
      final kg = quantityBase / 1000.0;
      return pricePerUnit * kg;
    }
    if (unitKind == UnitKind.volume) {
      final liters = quantityBase / 1000.0;
      return pricePerUnit * liters;
    }
    return pricePerUnit * quantityBase;
  }

  double _clampPrice(double price, UnitKind unitKind) {
    switch (unitKind) {
      case UnitKind.unit:
        return price.clamp(0.10, 5.0);
      case UnitKind.weight:
        return price.clamp(0.10, 30.0);
      case UnitKind.volume:
        return price.clamp(0.10, 10.0);
    }
  }
}
