// =============================================================================
// PRUEBAS UNITARIAS - VALUE OBJECTS
// =============================================================================
// Verifica validaciones de Value Objects (DisplayName, Height, Weight, etc.)
// Casos: valores válidos, límites superiores/inferiores, inputs inválidos

import 'package:flutter_test/flutter_test.dart';
import 'package:smartmeal/domain/value_objects/display_name.dart';
import 'package:smartmeal/domain/value_objects/height.dart';
import 'package:smartmeal/domain/value_objects/weight.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

void main() {
  group('DisplayName - Validaciones', () {
    test('Nombre válido se crea correctamente', () {
      // Given: Un nombre válido
      const validName = 'Juan Pérez';

      // When: Creamos DisplayName
      final displayName = DisplayName(validName);

      // Then: Debe tener el valor correcto
      expect(displayName.value, equals('Juan Pérez'));
    });

    test('Nombre con espacios extra se normaliza (trim)', () {
      // Given: Nombre con espacios al inicio y final
      const nameWithSpaces = '  María García  ';

      // When: Creamos DisplayName
      final displayName = DisplayName(nameWithSpaces);

      // Then: Debe estar sin espacios extra
      expect(displayName.value, equals('María García'));
    });

    test('firstLetter devuelve la primera letra en mayúscula', () {
      // Given: Nombre con letra inicial minúscula
      final displayName = DisplayName('andrés lópez');

      // When: Obtenemos firstLetter
      final firstLetter = displayName.firstLetter;

      // Then: Debe ser la A mayúscula
      expect(firstLetter, equals('A'));
    });

    test('Nombre vacío lanza ArgumentError', () {
      // Given: Nombre vacío
      const emptyName = '';

      // When/Then: Debe lanzar error
      expect(() => DisplayName(emptyName), throwsA(isA<ArgumentError>()));
    });

    test('Nombre solo con espacios lanza ArgumentError', () {
      // Given: Solo espacios
      const onlySpaces = '    ';

      // When/Then: Debe lanzar error
      expect(() => DisplayName(onlySpaces), throwsA(isA<ArgumentError>()));
    });

    test('Nombre con 1 carácter lanza ArgumentError (mínimo 2)', () {
      // Given: Nombre de 1 carácter
      const tooShort = 'A';

      // When/Then: Debe lanzar error
      expect(() => DisplayName(tooShort), throwsA(isA<ArgumentError>()));
    });

    test('Nombre con 2 caracteres es válido', () {
      // Given: Nombre de exactamente 2 caracteres
      const minLength = 'Lu';

      // When: Creamos DisplayName
      final displayName = DisplayName(minLength);

      // Then: Debe ser válido
      expect(displayName.value, equals('Lu'));
    });

    test('Nombre con 50 caracteres es válido (límite superior)', () {
      // Given: Nombre de 50 caracteres exactos
      final maxLength = 'A' * 50;

      // When: Creamos DisplayName
      final displayName = DisplayName(maxLength);

      // Then: Debe ser válido
      expect(displayName.value.length, equals(50));
    });

    test('Nombre con 51 caracteres lanza ArgumentError', () {
      // Given: Nombre de 51 caracteres
      final tooLong = 'A' * 51;

      // When/Then: Debe lanzar error
      expect(() => DisplayName(tooLong), throwsA(isA<ArgumentError>()));
    });
  });

  group('Height - Validaciones', () {
    test('Altura válida se crea correctamente', () {
      // Given: Altura válida
      const validHeight = 175;

      // When: Creamos Height
      final height = Height(validHeight);

      // Then: Debe tener el valor correcto
      expect(height.value, equals(175));
    });

    test('formatted devuelve altura con unidad', () {
      // Given: Altura de 180 cm
      final height = Height(180);

      // When: Obtenemos formatted
      final formatted = height.formatted;

      // Then: Debe tener formato "180 cm"
      expect(formatted, equals('180 cm'));
    });

    test('meters convierte correctamente a metros', () {
      // Given: Altura de 175 cm
      final height = Height(175);

      // When: Obtenemos en metros
      final meters = height.meters;

      // Then: Debe ser 1.75 metros
      expect(meters, equals(1.75));
    });

    test('fromString parsea string numérico correctamente', () {
      // Given: String con altura
      const heightString = '170';

      // When: Creamos desde string
      final height = Height.fromString(heightString);

      // Then: Debe tener el valor correcto
      expect(height.value, equals(170));
    });

    test('fromString lanza error con string inválido', () {
      // Given: String no numérico
      const invalidString = 'abc';

      // When/Then: Debe lanzar error
      expect(
        () => Height.fromString(invalidString),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Altura mínima permitida (50 cm) es válida', () {
      // Given: Altura mínima según constantes
      final minHeight = AppConstants.minHeightCm;

      // When: Creamos Height
      final height = Height(minHeight);

      // Then: Debe ser válido
      expect(height.value, equals(50));
    });

    test('Altura máxima permitida (300 cm) es válida', () {
      // Given: Altura máxima según constantes
      final maxHeight = AppConstants.maxHeightCm;

      // When: Creamos Height
      final height = Height(maxHeight);

      // Then: Debe ser válido
      expect(height.value, equals(300));
    });

    test('Altura menor al mínimo lanza ArgumentError', () {
      // Given: Altura demasiado baja
      const tooShort = 49;

      // When/Then: Debe lanzar error
      expect(() => Height(tooShort), throwsA(isA<ArgumentError>()));
    });

    test('Altura mayor al máximo lanza ArgumentError', () {
      // Given: Altura demasiado alta
      const tooTall = 301;

      // When/Then: Debe lanzar error
      expect(() => Height(tooTall), throwsA(isA<ArgumentError>()));
    });
  });

  group('Weight - Validaciones', () {
    test('Peso válido se crea correctamente', () {
      // Given: Peso válido
      const validWeight = 70.5;

      // When: Creamos Weight
      final weight = Weight(validWeight);

      // Then: Debe tener el valor correcto
      expect(weight.value, equals(70.5));
    });

    test('formatted devuelve peso con unidad', () {
      // Given: Peso de 75.5 kg
      final weight = Weight(75.5);

      // When: Obtenemos formatted
      final formatted = weight.formatted;

      // Then: Debe tener formato "75.5 kg"
      expect(formatted, equals('75.5 kg'));
    });

    test('fromString parsea string numérico correctamente', () {
      // Given: String con peso
      const weightString = '68.3';

      // When: Creamos desde string
      final weight = Weight.fromString(weightString);

      // Then: Debe tener el valor correcto
      expect(weight.value, equals(68.3));
    });

    test('fromString lanza error con string inválido', () {
      // Given: String no numérico
      const invalidString = 'xyz';

      // When/Then: Debe lanzar error
      expect(
        () => Weight.fromString(invalidString),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('calculateBMI calcula correctamente el índice de masa corporal', () {
      // Given: Peso de 70 kg y altura de 175 cm
      final weight = Weight(70.0);
      final height = Height(175);

      // When: Calculamos BMI
      final bmi = weight.calculateBMI(height);

      // Then: BMI = 70 / (1.75^2) = 22.86
      expect(bmi, closeTo(22.86, 0.01));
    });

    test('calculateBMI con diferentes valores', () {
      // Given: Peso de 85 kg y altura de 180 cm
      final weight = Weight(85.0);
      final height = Height(180);

      // When: Calculamos BMI
      final bmi = weight.calculateBMI(height);

      // Then: BMI = 85 / (1.8^2) = 26.23
      expect(bmi, closeTo(26.23, 0.01));
    });

    test('Peso mínimo permitido (20 kg) es válido', () {
      // Given: Peso mínimo según constantes
      final minWeight = AppConstants.minWeightKg;

      // When: Creamos Weight
      final weight = Weight(minWeight);

      // Then: Debe ser válido
      expect(weight.value, equals(20));
    });

    test('Peso máximo permitido (500 kg) es válido', () {
      // Given: Peso máximo según constantes
      final maxWeight = AppConstants.maxWeightKg;

      // When: Creamos Weight
      final weight = Weight(maxWeight);

      // Then: Debe ser válido
      expect(weight.value, equals(500));
    });

    test('Peso menor al mínimo lanza ArgumentError', () {
      // Given: Peso demasiado bajo
      const tooLight = 19.9;

      // When/Then: Debe lanzar error
      expect(() => Weight(tooLight), throwsA(isA<ArgumentError>()));
    });

    test('Peso mayor al máximo lanza ArgumentError', () {
      // Given: Peso demasiado alto
      const tooHeavy = 500.1;

      // When/Then: Debe lanzar error
      expect(() => Weight(tooHeavy), throwsA(isA<ArgumentError>()));
    });

    test('Peso con decimales es válido', () {
      // Given: Peso con decimales
      const weightWithDecimals = 67.25;

      // When: Creamos Weight
      final weight = Weight(weightWithDecimals);

      // Then: Debe mantener decimales
      expect(weight.value, equals(67.25));
    });
  });

  group('Value Objects - Igualdad', () {
    test('DisplayName con mismo valor son iguales', () {
      // Given: Dos DisplayName con mismo valor
      final name1 = DisplayName('Carlos');
      final name2 = DisplayName('Carlos');

      // When/Then: Deben ser iguales
      expect(name1, equals(name2));
      expect(name1.hashCode, equals(name2.hashCode));
    });

    test('Height con mismo valor son iguales', () {
      // Given: Dos Height con mismo valor
      final height1 = Height(175);
      final height2 = Height(175);

      // When/Then: Deben ser iguales
      expect(height1, equals(height2));
      expect(height1.hashCode, equals(height2.hashCode));
    });

    test('Weight con mismo valor son iguales', () {
      // Given: Dos Weight con mismo valor
      final weight1 = Weight(70.0);
      final weight2 = Weight(70.0);

      // When/Then: Deben ser iguales
      expect(weight1, equals(weight2));
      expect(weight1.hashCode, equals(weight2.hashCode));
    });

    test('Value Objects con valores diferentes no son iguales', () {
      // Given: Value Objects con valores diferentes
      final name1 = DisplayName('Ana');
      final name2 = DisplayName('Luis');

      // When/Then: No deben ser iguales
      expect(name1, isNot(equals(name2)));
    });
  });
}
