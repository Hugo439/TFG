import 'package:smartmeal/core/errors/failures.dart';
import 'package:smartmeal/domain/entities/user_price_override.dart';
import 'package:smartmeal/domain/repositories/user_price_repository.dart';
import 'package:smartmeal/data/datasources/remote/user_price_override_firestore_datasource.dart';
import 'package:smartmeal/data/models/user_price_override_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

/// Implementación del repositorio de precios personalizados de usuario.
///
/// Responsabilidad:
/// - CRUD de price overrides personalizados
/// - Permite al usuario sobrescribir precios del catálogo global
///
/// Ruta Firestore: users/{userId}/price_overrides/{ingredientId}
///
/// Operaciones:
/// - **getUserPriceOverride**: obtiene override específico
/// - **getAllUserOverrides**: obtiene todos los overrides del usuario
/// - **saveUserPriceOverride**: guarda/actualiza override
/// - **deleteUserPriceOverride**: elimina override (vuelve a precio catálogo)
///
/// Flujo típico:
/// 1. Usuario ve precio estimado de "pollo" (8.0€/kg catálogo)
/// 2. Usuario edita precio a 5.50€/kg (su supermercado)
/// 3. saveUserPriceOverride() guarda en Firestore
/// 4. PriceDatabaseService usa override en lugar del catálogo
/// 5. Estimaciones futuras usan 5.50€/kg para este usuario
///
/// Prioridad en PriceDatabaseService:
/// 1. UserPriceOverride (personalizado)
/// 2. PriceEntry (catálogo global)
/// 3. Fallback por categoría
///
/// Manejo de errores:
/// - Retorna Either<Failure, Result>
///
/// Uso:
/// ```dart
/// final repo = UserPriceRepositoryImpl(datasource);
///
/// // Guardar precio personalizado
/// await repo.saveUserPriceOverride(UserPriceOverride(
///   userId: 'user123',
///   ingredientId: 'pollo',
///   customPrice: 5.50,
///   reason: 'Mi supermercado',
/// ));
///
/// // Obtener override
/// final result = await repo.getUserPriceOverride(
///   userId: 'user123',
///   ingredientId: 'pollo',
/// );
/// ```
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
