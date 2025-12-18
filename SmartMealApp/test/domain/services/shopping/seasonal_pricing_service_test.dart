import 'package:flutter_test/flutter_test.dart';
import 'package:smartmeal/domain/services/shopping/seasonal_pricing_service.dart';

void main() {
  group('SeasonalPricingService', () {
    group('getCurrentSeason()', () {
      test('marzo = primavera', () {
        final date = DateTime(2025, 3, 15);
        expect(
          SeasonalPricingService.getCurrentSeason(date),
          equals(Season.spring),
        );
      });

      test('abril = primavera', () {
        final date = DateTime(2025, 4, 15);
        expect(
          SeasonalPricingService.getCurrentSeason(date),
          equals(Season.spring),
        );
      });

      test('mayo = primavera', () {
        final date = DateTime(2025, 5, 15);
        expect(
          SeasonalPricingService.getCurrentSeason(date),
          equals(Season.spring),
        );
      });

      test('junio = verano', () {
        final date = DateTime(2025, 6, 15);
        expect(
          SeasonalPricingService.getCurrentSeason(date),
          equals(Season.summer),
        );
      });

      test('julio = verano', () {
        final date = DateTime(2025, 7, 15);
        expect(
          SeasonalPricingService.getCurrentSeason(date),
          equals(Season.summer),
        );
      });

      test('agosto = verano', () {
        final date = DateTime(2025, 8, 15);
        expect(
          SeasonalPricingService.getCurrentSeason(date),
          equals(Season.summer),
        );
      });

      test('septiembre = otoño', () {
        final date = DateTime(2025, 9, 15);
        expect(
          SeasonalPricingService.getCurrentSeason(date),
          equals(Season.autumn),
        );
      });

      test('octubre = otoño', () {
        final date = DateTime(2025, 10, 15);
        expect(
          SeasonalPricingService.getCurrentSeason(date),
          equals(Season.autumn),
        );
      });

      test('noviembre = otoño', () {
        final date = DateTime(2025, 11, 15);
        expect(
          SeasonalPricingService.getCurrentSeason(date),
          equals(Season.autumn),
        );
      });

      test('diciembre = invierno', () {
        final date = DateTime(2025, 12, 15);
        expect(
          SeasonalPricingService.getCurrentSeason(date),
          equals(Season.winter),
        );
      });

      test('enero = invierno', () {
        final date = DateTime(2025, 1, 15);
        expect(
          SeasonalPricingService.getCurrentSeason(date),
          equals(Season.winter),
        );
      });

      test('febrero = invierno', () {
        final date = DateTime(2025, 2, 15);
        expect(
          SeasonalPricingService.getCurrentSeason(date),
          equals(Season.winter),
        );
      });

      test('sin fecha usa hoy', () {
        final season = SeasonalPricingService.getCurrentSeason();
        expect(season, isNotNull);
        expect([
          Season.spring,
          Season.summer,
          Season.autumn,
          Season.winter,
        ], contains(season));
      });
    });

    group('getSeasonalMultiplier()', () {
      test('fresas en invierno están caras: ×1.5', () {
        final multiplier = SeasonalPricingService.getSeasonalMultiplier(
          'fresas',
          DateTime(2025, 12, 15),
        );
        expect(multiplier, equals(1.5));
      });

      test('fresas en verano están baratas: ×0.8', () {
        final multiplier = SeasonalPricingService.getSeasonalMultiplier(
          'fresas',
          DateTime(2025, 7, 15),
        );
        expect(multiplier, equals(0.8));
      });

      test('tomate en verano barato: ×0.7', () {
        final multiplier = SeasonalPricingService.getSeasonalMultiplier(
          'tomate',
          DateTime(2025, 7, 15),
        );
        expect(multiplier, equals(0.7));
      });

      test('tomate en invierno caro: ×1.3', () {
        final multiplier = SeasonalPricingService.getSeasonalMultiplier(
          'tomate',
          DateTime(2025, 12, 15),
        );
        expect(multiplier, equals(1.3));
      });

      test('sandía en verano barata: ×0.6', () {
        final multiplier = SeasonalPricingService.getSeasonalMultiplier(
          'sandía',
          DateTime(2025, 7, 15),
        );
        expect(multiplier, equals(0.6));
      });

      test('sandía en invierno cara: ×2.0', () {
        final multiplier = SeasonalPricingService.getSeasonalMultiplier(
          'sandia',
          DateTime(2025, 12, 15),
        );
        expect(multiplier, equals(2.0));
      });

      test('naranja en invierno barata: ×0.7', () {
        final multiplier = SeasonalPricingService.getSeasonalMultiplier(
          'naranja',
          DateTime(2025, 12, 15),
        );
        expect(multiplier, equals(0.7));
      });

      test('melocoton en verano barato: ×0.7', () {
        final multiplier = SeasonalPricingService.getSeasonalMultiplier(
          'melocoton',
          DateTime(2025, 7, 15),
        );
        expect(multiplier, equals(0.7));
      });

      test('espárrago en primavera barato: ×0.7', () {
        final multiplier = SeasonalPricingService.getSeasonalMultiplier(
          'esparrago',
          DateTime(2025, 3, 15),
        );
        expect(multiplier, equals(0.7));
      });

      test('sin datos estacionales: ×1.0', () {
        final multiplier = SeasonalPricingService.getSeasonalMultiplier(
          'huevo',
          DateTime(2025, 7, 15),
        );
        expect(multiplier, equals(1.0));
      });

      test('case-insensitive', () {
        final m1 = SeasonalPricingService.getSeasonalMultiplier(
          'FRESAS',
          DateTime(2025, 12, 15),
        );
        final m2 = SeasonalPricingService.getSeasonalMultiplier(
          'fresas',
          DateTime(2025, 12, 15),
        );
        expect(m1, equals(m2));
      });

      test('fuzzy match: "fresa" encuentra "fresas"', () {
        final multiplier = SeasonalPricingService.getSeasonalMultiplier(
          'fresa',
          DateTime(2025, 12, 15),
        );
        expect(multiplier, isNotNull);
        expect(multiplier, isNot(1.0));
      });
    });

    group('applySeasonalAdjustment()', () {
      test('aplica multiplicador correcto', () {
        // Fresas en invierno: €5 × 1.5 = €7.5
        final adjusted = SeasonalPricingService.applySeasonalAdjustment(
          5.0,
          'fresas',
          DateTime(2025, 12, 15),
        );
        expect(adjusted, equals(7.5));
      });

      test('tomate en verano más barato', () {
        // €3 × 0.7 = €2.1
        final adjusted = SeasonalPricingService.applySeasonalAdjustment(
          3.0,
          'tomate',
          DateTime(2025, 7, 15),
        );
        expect(
          adjusted,
          closeTo(2.1, 0.001),
        ); // Use closeTo for float comparison
      });

      test('sin ajuste estacional para huevo', () {
        // €0.25 × 1.0 = €0.25
        final adjusted = SeasonalPricingService.applySeasonalAdjustment(
          0.25,
          'huevo',
          DateTime(2025, 7, 15),
        );
        expect(adjusted, equals(0.25));
      });

      test('usa fecha actual si no se proporciona', () {
        final adjusted = SeasonalPricingService.applySeasonalAdjustment(
          5.0,
          'fresas',
        );
        expect(adjusted, isNotNull);
        expect(adjusted, isPositive); // A double should be positive
      });

      test('multiplica correctamente con decimales', () {
        // €1.5 × 1.5 = €2.25
        final adjusted = SeasonalPricingService.applySeasonalAdjustment(
          1.5,
          'fresas',
          DateTime(2025, 12, 15),
        );
        expect(adjusted, closeTo(2.25, 0.01));
      });
    });

    group('multiplicadores por ingrediente', () {
      test('12 ingredientes tienen datos estacionales', () {
        final ingredients = [
          'fresa',
          'sandia',
          'naranja',
          'melocoton',
          'uva',
          'melon',
          'tomate',
          'calabaza',
          'esparrago',
          'alcachofa',
          'berenjena',
          'calabacin',
        ];

        for (final ingredient in ingredients) {
          final multiplier = SeasonalPricingService.getSeasonalMultiplier(
            ingredient,
            DateTime(2025, 6, 15),
          );
          expect(
            multiplier,
            isNot(1.0),
            reason: '$ingredient debe tener multiplicador',
          );
        }
      });
    });

    group('edge cases', () {
      test('maneja string vacío', () {
        final multiplier = SeasonalPricingService.getSeasonalMultiplier('');
        expect(multiplier, equals(1.0));
      });

      test('precio negativo (edge case)', () {
        final adjusted = SeasonalPricingService.applySeasonalAdjustment(
          -5.0,
          'fresas',
          DateTime(2025, 12, 15),
        );
        // Debería aplicar el multiplicador aunque sea negativo
        expect(adjusted, equals(-7.5));
      });

      test('precio cero', () {
        final adjusted = SeasonalPricingService.applySeasonalAdjustment(
          0.0,
          'fresas',
          DateTime(2025, 12, 15),
        );
        expect(adjusted, equals(0.0));
      });

      test('múltiples temporadas en año', () {
        final primavera = SeasonalPricingService.getSeasonalMultiplier(
          'espárrago',
          DateTime(2025, 4, 15),
        );
        final verano = SeasonalPricingService.getSeasonalMultiplier(
          'espárrago',
          DateTime(2025, 7, 15),
        );
        expect(primavera, isNot(equals(verano)));
      });
    });
  });
}
