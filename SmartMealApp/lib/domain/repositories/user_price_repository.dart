import 'package:smartmeal/core/errors/failures.dart';
import 'package:smartmeal/domain/entities/user_price_override.dart';
import 'package:dartz/dartz.dart';

/// Repositorio para precios personalizados del usuario
abstract class UserPriceRepository {
  /// Obtiene el override de precio del usuario para un ingrediente
  Future<Either<Failure, UserPriceOverride?>> getUserPriceOverride({
    required String userId,
    required String ingredientId,
  });

  /// Obtiene todos los overrides de un usuario
  Future<Either<Failure, List<UserPriceOverride>>> getAllUserOverrides(String userId);

  /// Guarda o actualiza un override de precio
  Future<Either<Failure, void>> saveUserPriceOverride(UserPriceOverride override);

  /// Elimina un override de precio
  Future<Either<Failure, void>> deleteUserPriceOverride({
    required String userId,
    required String ingredientId,
  });
}
