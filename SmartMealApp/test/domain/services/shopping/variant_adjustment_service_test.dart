import 'package:flutter_test/flutter_test.dart';
import 'package:smartmeal/domain/services/shopping/variant_adjustment_service.dart';

void main() {
  group('VariantAdjustmentService', () {
    group('getVariantMultiplier()', () {
      test('detecta productos bio/ecológicos: +20%', () {
        expect(
          VariantAdjustmentService.getVariantMultiplier('leche bio'),
          equals(1.20),
        );
        expect(
          VariantAdjustmentService.getVariantMultiplier('arroz ecológico'),
          equals(1.20),
        );
        expect(
          VariantAdjustmentService.getVariantMultiplier('huevos orgánicos'),
          equals(1.20),
        );
      });

      test('detecta productos congelados: -10%', () {
        expect(
          VariantAdjustmentService.getVariantMultiplier('pollo congelado'),
          equals(0.90),
        );
        expect(
          VariantAdjustmentService.getVariantMultiplier('fresas frozen'),
          equals(0.90),
        );
      });

      test('detecta productos frescos: +5%', () {
        expect(
          VariantAdjustmentService.getVariantMultiplier('tomate fresco'),
          equals(1.05),
        );
        expect(
          VariantAdjustmentService.getVariantMultiplier('leche fresh'),
          equals(1.05),
        );
      });

      test('detecta productos sin alérgenos: +15%', () {
        expect(
          VariantAdjustmentService.getVariantMultiplier('pan sin gluten'),
          equals(1.15),
        );
        expect(
          VariantAdjustmentService.getVariantMultiplier('leche sin lactosa'),
          equals(1.15),
        );
      });

      test('detecta productos light: -5%', () {
        expect(
          VariantAdjustmentService.getVariantMultiplier('queso light'),
          equals(0.95),
        );
        expect(
          VariantAdjustmentService.getVariantMultiplier('yogur desnatado'),
          equals(0.95),
        );
      });

      test('detecta productos premium: +30%', () {
        expect(
          VariantAdjustmentService.getVariantMultiplier('jamón ibérico'),
          equals(1.30),
        );
        expect(
          VariantAdjustmentService.getVariantMultiplier('aceite gourmet'),
          equals(1.30),
        );
        expect(
          VariantAdjustmentService.getVariantMultiplier('huevos de corral'),
          equals(1.30),
        );
      });

      test('sin variante especial: 1.0 (sin cambio)', () {
        expect(
          VariantAdjustmentService.getVariantMultiplier('arroz blanco'),
          equals(1.0),
        );
        expect(
          VariantAdjustmentService.getVariantMultiplier('patata'),
          equals(1.0),
        );
      });

      test('case-insensitive', () {
        expect(
          VariantAdjustmentService.getVariantMultiplier('LECHE BIO'),
          equals(1.20),
        );
        expect(
          VariantAdjustmentService.getVariantMultiplier('Pollo CONGELADO'),
          equals(0.90),
        );
      });

      test('detecta primer match (no múltiples)', () {
        // Solo cuenta el primer match encontrado
        final multiplier = VariantAdjustmentService.getVariantMultiplier(
          'aceite de oliva virgen extra premium bio',
        );
        // "bio" viene primero en la lógica
        expect(multiplier, equals(1.20));
      });
    });

    group('detectVariants()', () {
      test('lista variantes detectadas en orden', () {
        final variants = VariantAdjustmentService.detectVariants('leche bio');
        expect(variants, contains('Ecológico (+20%)'));
      });

      test('múltiples variantes (si hay)', () {
        final variants = VariantAdjustmentService.detectVariants(
          'pollo fresco ecológico',
        );
        expect(variants.length, greaterThan(0));
        expect(variants, contains('Ecológico (+20%)'));
        expect(variants, contains('Fresco (+5%)'));
      });

      test('lista vacía si sin variantes', () {
        final variants = VariantAdjustmentService.detectVariants('patata');
        expect(variants, isEmpty);
      });

      test('formatea correctamente los textos', () {
        final variants = VariantAdjustmentService.detectVariants(
          'jamón ibérico',
        );
        expect(variants, contains('Premium (+30%)'));
      });

      test('congelado está en la lista correctamente', () {
        final variants = VariantAdjustmentService.detectVariants(
          'fresas congeladas',
        );
        expect(variants, contains('Congelado (-10%)'));
      });

      test('case-insensitive', () {
        final variants = VariantAdjustmentService.detectVariants(
          'ACEITE BIO',
        );
        expect(variants, isNotEmpty);
      });
    });

    group('aplicación en cálculos', () {
      test('multiplier bio en precio', () {
        final basePrice = 5.0;
        final multiplier = VariantAdjustmentService.getVariantMultiplier(
          'manzana bio',
        );
        final finalPrice = basePrice * multiplier;
        expect(finalPrice, equals(6.0)); // 5.0 * 1.20
      });

      test('multiplier congelado en precio', () {
        final basePrice = 10.0;
        final multiplier = VariantAdjustmentService.getVariantMultiplier(
          'salmon congelado',
        );
        final finalPrice = basePrice * multiplier;
        expect(finalPrice, equals(9.0)); // 10.0 * 0.90
      });

      test('sin variante no cambia precio', () {
        final basePrice = 8.0;
        final multiplier = VariantAdjustmentService.getVariantMultiplier(
          'pollo',
        );
        final finalPrice = basePrice * multiplier;
        expect(finalPrice, equals(8.0)); // 8.0 * 1.0
      });
    });

    group('edge cases', () {
      test('maneja string vacío', () {
        expect(
          VariantAdjustmentService.getVariantMultiplier(''),
          equals(1.0),
        );
      });

      test('maneja strings con solo espacios', () {
        expect(
          VariantAdjustmentService.getVariantMultiplier('   '),
          equals(1.0),
        );
      });

      test('detectVariants con string vacío', () {
        expect(
          VariantAdjustmentService.detectVariants(''),
          isEmpty,
        );
      });

      test('nombres largos sin variantes', () {
        final multiplier = VariantAdjustmentService.getVariantMultiplier(
          'tomate cherry de invernadero español',
        );
        expect(multiplier, equals(1.0));
      });
    });
  });
}
