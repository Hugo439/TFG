import 'package:smartmeal/core/errors/failures.dart';
import 'package:smartmeal/domain/entities/user_price_override.dart';
import 'package:smartmeal/domain/repositories/user_price_repository.dart';
import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';
import 'package:dartz/dartz.dart';

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
