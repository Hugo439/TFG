import 'package:smartmeal/core/errors/failures.dart';
import 'package:smartmeal/domain/entities/user_price_override.dart';
import 'package:smartmeal/domain/repositories/user_price_repository.dart';
import 'package:smartmeal/data/datasources/remote/user_price_firestore_datasource.dart';
import 'package:smartmeal/data/models/user_price_override_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class UserPriceRepositoryImpl implements UserPriceRepository {
  final UserPriceFirestoreDatasource _datasource;

  UserPriceRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, UserPriceOverride?>> getUserPriceOverride({
    required String userId,
    required String ingredientId,
  }) async {
    try {
      final model = await _datasource.getUserPriceOverride(
        userId: userId,
        ingredientId: ingredientId,
      );
      return Right(model?.toEntity());
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UserPriceRepository] Error: $e');
      }
      return Left(ServerFailure('Error obteniendo override: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserPriceOverride>>> getAllUserOverrides(
    String userId,
  ) async {
    try {
      final models = await _datasource.getAllUserOverrides(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UserPriceRepository] Error: $e');
      }
      return Left(ServerFailure('Error obteniendo overrides: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserPriceOverride(
    UserPriceOverride override,
  ) async {
    try {
      final model = UserPriceOverrideModel.fromEntity(override);
      await _datasource.saveUserPriceOverride(model);
      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UserPriceRepository] Error: $e');
      }
      return Left(ServerFailure('Error guardando override: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserPriceOverride({
    required String userId,
    required String ingredientId,
  }) async {
    try {
      await _datasource.deleteUserPriceOverride(
        userId: userId,
        ingredientId: ingredientId,
      );
      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UserPriceRepository] Error: $e');
      }
      return Left(ServerFailure('Error eliminando override: $e'));
    }
  }
}
