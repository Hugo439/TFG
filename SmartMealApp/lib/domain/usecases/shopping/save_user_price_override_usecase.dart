import 'package:smartmeal/core/errors/failures.dart';
import 'package:smartmeal/domain/entities/user_price_override.dart';
import 'package:smartmeal/domain/repositories/user_price_repository.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';
import 'package:dartz/dartz.dart';

/// Parámetros para guardar precio personalizado de usuario.
class SaveUserPriceOverrideParams {
  final String userId;
  final String ingredientName;
  final double customPrice;
  final String? reason;

  const SaveUserPriceOverrideParams({
    required this.userId,
    required this.ingredientName,
    required this.customPrice,
    this.reason,
  });
}

/// UseCase para guardar precio personalizado de un ingrediente.
///
/// Responsabilidad:
/// - Validar precio > 0
/// - Normalizar nombre de ingrediente
/// - Crear UserPriceOverride y persistir en Firestore
///
/// Entrada:
/// - SaveUserPriceOverrideParams:
///   - userId: ID del usuario
///   - ingredientName: nombre del ingrediente (será normalizado)
///   - customPrice: precio personalizado en euros
///   - reason: motivo opcional (ej: "precio de mi supermercado")
///
/// Salida:
/// - Either<Failure, void>:
///   - Right(void): éxito
///   - Left(ValidationFailure): precio <= 0
///   - Left(UnknownFailure): error al guardar
///
/// Uso típico:
/// ```dart
/// final result = await saveOverrideUseCase(SaveUserPriceOverrideParams(
///   userId: 'user123',
///   ingredientName: 'Pechuga de pollo',
///   customPrice: 6.50, // €6.50/kg en mi supermercado
///   reason: 'Precio Mercadona',
/// ));
///
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (_) => print('Precio guardado'),
/// );
/// ```
///
/// Nota: El nombre se normaliza automáticamente, así
/// "Pechuga de pollo" → "pollo" para coincidir con agregación.
class SaveUserPriceOverrideUseCase {
  final UserPriceRepository _repository;

  SaveUserPriceOverrideUseCase(this._repository);

  Future<Either<Failure, void>> call(SaveUserPriceOverrideParams params) async {
    try {
      if (params.customPrice <= 0) {
        return const Left(ValidationFailure('El precio debe ser mayor a 0'));
      }

      final normalizedName = SmartIngredientNormalizer().normalize(
        params.ingredientName,
      );

      final override = UserPriceOverride(
        userId: params.userId,
        ingredientId: normalizedName,
        customPrice: params.customPrice,
        reason: params.reason,
        createdAt: DateTime.now(),
      );

      return await _repository.saveUserPriceOverride(override);
    } catch (e) {
      return Left(UnknownFailure('Error guardando precio: $e'));
    }
  }
}
