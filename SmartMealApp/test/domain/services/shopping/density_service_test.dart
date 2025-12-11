import 'package:flutter_test/flutter_test.dart';
import 'package:smartmeal/domain/services/shopping/density_service.dart';
import 'package:smartmeal/domain/value_objects/unit_kind.dart';

void main() {
  group('DensityService', () {
    group('getDensity()', () {
      test('obtiene densidad para aceite', () {
        expect(DensityService.getDensity('aceite'), equals(0.92));
        expect(DensityService.getDensity('aceite oliva'), equals(0.92));
        expect(DensityService.getDensity('aceite girasol'), equals(0.92));
      });

      test('obtiene densidad para agua/caldo', () {
        expect(DensityService.getDensity('agua'), equals(1.00));
        expect(DensityService.getDensity('caldo'), equals(1.00));
      });

      test('obtiene densidad para leche', () {
        expect(DensityService.getDensity('leche'), equals(1.03));
      });

      test('obtiene densidad para vinagre', () {
        expect(DensityService.getDensity('vinagre'), equals(1.01));
      });

      test('obtiene densidad para miel', () {
        expect(DensityService.getDensity('miel'), equals(1.42));
      });

      test('obtiene densidad para salsa tomate', () {
        expect(DensityService.getDensity('salsa tomate'), equals(1.10));
      });

      test('devuelve null para ingredientes desconocidos', () {
        expect(DensityService.getDensity('patata'), isNull);
        expect(DensityService.getDensity('huevo'), isNull);
      });

      test('case-insensitive', () {
        expect(DensityService.getDensity('ACEITE'), equals(0.92));
        expect(DensityService.getDensity('LeChE'), equals(1.03));
      });

      test('busca substring', () {
        expect(DensityService.getDensity('zumo natural'), equals(1.04));
        expect(DensityService.getDensity('agua filtrada'), equals(1.00));
      });
    });

    group('volumeToWeight()', () {
      test('convierte volumen a peso correctamente', () {
        // 1000 ml de aceite (0.92 g/ml) = 920 g
        expect(
          DensityService.volumeToWeight(1000, 'aceite'),
          equals(920.0),
        );
      });

      test('convierte leche: 1000 ml → 1030 g', () {
        expect(
          DensityService.volumeToWeight(1000, 'leche'),
          equals(1030.0),
        );
      });

      test('convierte miel: 100 ml → 142 g', () {
        expect(
          DensityService.volumeToWeight(100, 'miel'),
          equals(142.0),
        );
      });

      test('convierte agua: 500 ml → 500 g', () {
        expect(
          DensityService.volumeToWeight(500, 'agua'),
          equals(500.0),
        );
      });

      test('devuelve null si ingrediente desconocido', () {
        expect(
          DensityService.volumeToWeight(1000, 'patata'),
          isNull,
        );
      });

      test('maneja decimales', () {
        final result = DensityService.volumeToWeight(250.5, 'aceite');
        expect(result, closeTo(250.5 * 0.92, 0.01));
      });

      test('maneja volumen cero', () {
        expect(
          DensityService.volumeToWeight(0, 'aceite'),
          equals(0.0),
        );
      });
    });

    group('weightToVolume()', () {
      test('convierte peso a volumen correctamente', () {
        // 920 g de aceite (0.92 g/ml) = 1000 ml
        expect(
          DensityService.weightToVolume(920, 'aceite'),
          closeTo(1000.0, 0.01),
        );
      });

      test('convierte leche: 1030 g → ~1000 ml', () {
        expect(
          DensityService.weightToVolume(1030, 'leche'),
          closeTo(1000.0, 0.01),
        );
      });

      test('convierte miel: 142 g → 100 ml', () {
        expect(
          DensityService.weightToVolume(142, 'miel'),
          closeTo(100.0, 0.01),
        );
      });

      test('convierte agua: 500 g → 500 ml', () {
        expect(
          DensityService.weightToVolume(500, 'agua'),
          equals(500.0),
        );
      });

      test('devuelve null si ingrediente desconocido', () {
        expect(
          DensityService.weightToVolume(500, 'arroz'),
          isNull,
        );
      });

      test('maneja peso cero', () {
        expect(
          DensityService.weightToVolume(0, 'aceite'),
          equals(0.0),
        );
      });
    });

    group('suggestUnitKind()', () {
      test('sugiere volumen para líquidos', () {
        expect(
          DensityService.suggestUnitKind('aceite'),
          equals(UnitKind.volume),
        );
        expect(
          DensityService.suggestUnitKind('leche'),
          equals(UnitKind.volume),
        );
        expect(
          DensityService.suggestUnitKind('vino'),
          equals(UnitKind.volume),
        );
        expect(
          DensityService.suggestUnitKind('zumo'),
          equals(UnitKind.volume),
        );
      });

      test('sugiere unidades para productos contables', () {
        expect(
          DensityService.suggestUnitKind('huevo'),
          equals(UnitKind.unit),
        );
        expect(
          DensityService.suggestUnitKind('aguacate'),
          equals(UnitKind.unit),
        );
        expect(
          DensityService.suggestUnitKind('tortilla'),
          equals(UnitKind.unit),
        );
        expect(
          DensityService.suggestUnitKind('pan'),
          equals(UnitKind.unit),
        );
      });

      test('sugiere peso por defecto', () {
        expect(
          DensityService.suggestUnitKind('patata'),
          equals(UnitKind.weight),
        );
        expect(
          DensityService.suggestUnitKind('tomate'),
          equals(UnitKind.weight),
        );
        expect(
          DensityService.suggestUnitKind('carne'),
          equals(UnitKind.weight),
        );
      });

      test('case-insensitive', () {
        expect(
          DensityService.suggestUnitKind('ACEITE'),
          equals(UnitKind.volume),
        );
        expect(
          DensityService.suggestUnitKind('HUEVO'),
          equals(UnitKind.unit),
        );
      });

      test('busca substring', () {
        expect(
          DensityService.suggestUnitKind('aceite de oliva'),
          equals(UnitKind.volume),
        );
        expect(
          DensityService.suggestUnitKind('agua destilada'),
          equals(UnitKind.volume),
        );
      });
    });

    group('conversión bidireccional', () {
      test('volumeToWeight → weightToVolume es reversible', () {
        const original = 1000.0; // ml de aceite
        final weight = DensityService.volumeToWeight(original, 'aceite');
        expect(weight, isNotNull);
        
        final volumeAgain = DensityService.weightToVolume(weight!, 'aceite');
        expect(volumeAgain, closeTo(original, 0.01));
      });

      test('conversión múltiple aceite', () {
        // 250 ml aceite
        final weight1 = DensityService.volumeToWeight(250, 'aceite');
        expect(weight1, equals(250 * 0.92));
        
        // Convertir de vuelta
        final vol1 = DensityService.weightToVolume(weight1!, 'aceite');
        expect(vol1, closeTo(250.0, 0.01));
      });

      test('conversión múltiple leche', () {
        // 500 ml leche
        final weight = DensityService.volumeToWeight(500, 'leche');
        expect(weight, equals(500 * 1.03));
        
        // Convertir de vuelta
        final vol = DensityService.weightToVolume(weight!, 'leche');
        expect(vol, closeTo(500.0, 0.01));
      });
    });

    group('edge cases', () {
      test('getDensity con string vacío', () {
        expect(DensityService.getDensity(''), isNull);
      });

      test('volumeToWeight con números grandes', () {
        final result = DensityService.volumeToWeight(10000, 'aceite');
        expect(result, equals(9200.0));
      });

      test('weightToVolume con números decimales', () {
        final result = DensityService.weightToVolume(25.5, 'miel');
        expect(result, isNotNull);
        expect(result, closeTo(25.5 / 1.42, 0.01));
      });

      test('suggestUnitKind con ingrediente desconocido', () {
        // Por defecto peso
        expect(
          DensityService.suggestUnitKind('queso'),
          equals(UnitKind.weight),
        );
      });
    });
  });
}
