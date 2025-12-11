import 'package:flutter_test/flutter_test.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';

void main() {
  group('SmartIngredientNormalizer', () {
    late SmartIngredientNormalizer normalizer;

    setUp(() {
      normalizer = SmartIngredientNormalizer();
    });

    group('normalize()', () {
      test('convierte a minúsculas', () {
        expect(normalizer.normalize('HUEVO'), equals('huevo'));
        expect(normalizer.normalize('LeChE'), equals('leche'));
      });

      test('remueve espacios extras', () {
        expect(normalizer.normalize('  huevo  '), equals('huevo'));
        expect(normalizer.normalize('pollo  pechuga'), equals('pollo pechuga'));
      });

      test('convierte plurales a singulares', () {
        expect(normalizer.normalize('huevos'), equals('huevo'));
        expect(normalizer.normalize('tomates'), equals('tomate'));
        expect(normalizer.normalize('patatas'), equals('patata'));
        expect(normalizer.normalize('cebollas'), equals('cebolla'));
        expect(normalizer.normalize('pimientos'), equals('pimiento'));
        expect(normalizer.normalize('zanahorias'), equals('zanahoria'));
      });

      test('reemplaza sinónimos', () {
        expect(normalizer.normalize('frijoles'), equals('alubia'));
        expect(normalizer.normalize('porotos'), equals('alubia'));
        expect(normalizer.normalize('judias'), equals('alubia'));
        expect(normalizer.normalize('papas'), equals('patata'));
      });

      test('remueve acentos', () {
        expect(normalizer.normalize('manzáña'), equals('manzana'));
        expect(normalizer.normalize('bérenjena'), equals('berenjena'));
        expect(normalizer.normalize('café'), equals('cafe'));
        expect(normalizer.normalize('yogúr'), equals('yogur'));
      });

      test('remueve palabras de ruido', () {
        expect(normalizer.normalize('huevo fresco'), equals('huevo'));
        expect(normalizer.normalize('aceite virgen extra'), equals('aceite'));
        expect(normalizer.normalize('leche sin lactosa'), equals('leche'));
        expect(normalizer.normalize('pollo bio'), equals('pollo'));
      });

      test('combina múltiples normalizaciones', () {
        // "HUEVOS FRESCOS" → minúsculas → quitar ruido → plural → "huevo"
        expect(normalizer.normalize('HUEVOS FRESCOS'), equals('huevo'));
        
        // "Tomates Ecológicos" → minúsculas → quitar ruido → plural → "tomate"
        expect(normalizer.normalize('Tomates Ecológicos'), equals('tomate'));
      });

      test('maneja vacíos correctamente', () {
        expect(normalizer.normalize(''), equals(''));
        expect(normalizer.normalize('   '), equals(''));
      });
    });

    group('similarity()', () {
      test('detecta palabras idénticas', () {
        expect(SmartIngredientNormalizer.similarity('huevo', 'huevo'), equals(100));
        expect(SmartIngredientNormalizer.similarity('leche', 'leche'), equals(100));
      });

      test('detecta similitudes altas', () {
        final score = SmartIngredientNormalizer.similarity('huevo', 'huevos');
        expect(score, greaterThan(80));
      });

      test('detecta diferencias', () {
        final score = SmartIngredientNormalizer.similarity('huevo', 'patata');
        expect(score, lessThan(50));
      });
    });

    group('findBestMatch()', () {
      test('encuentra coincidencia exacta', () {
        final candidates = ['huevo', 'leche', 'queso'];
        final match = SmartIngredientNormalizer.findBestMatch('huevo', candidates);
        expect(match, equals('huevo'));
      });

      test('encuentra coincidencia fuzzy', () {
        final candidates = ['huevo', 'leche', 'queso'];
        final match = SmartIngredientNormalizer.findBestMatch('huevos', candidates);
        expect(match, equals('huevo'));
      });

      test('respeta minScore', () {
        final candidates = ['huevo', 'leche'];
        final match = SmartIngredientNormalizer.findBestMatch(
          'patata',
          candidates,
          minScore: 85,
        );
        expect(match, isNull);
      });

      test('selecciona mejor coincidencia', () {
        final candidates = ['queso', 'quesadilla', 'queso fresco'];
        final match = SmartIngredientNormalizer.findBestMatch('queso', candidates);
        expect(match, isNotNull);
      });

      test('devuelve null si no hay coincidencia suficiente', () {
        final candidates = ['huevo', 'leche'];
        final match = SmartIngredientNormalizer.findBestMatch(
          'xyz',
          candidates,
          minScore: 80,
        );
        expect(match, isNull);
      });
    });

    group('edge cases', () {
      test('maneja ingredientes con números', () {
        final normalized = normalizer.normalize('leche 100% natural');
        expect(normalized, isNotEmpty);
      });

      test('maneja ingredientes con caracteres especiales', () {
        final normalized = normalizer.normalize('pan de molde (integral)');
        expect(normalized, isNotEmpty);
      });

      test('preserva nombres simples', () {
        expect(normalizer.normalize('agua'), equals('agua'));
        expect(normalizer.normalize('sal'), equals('sal'));
      });
    });
  });
}
