import 'package:smartmeal/core/errors/failures.dart';
import 'package:smartmeal/domain/entities/missing_price_entry.dart';
import 'package:smartmeal/domain/repositories/missing_price_repository.dart';
import 'package:smartmeal/data/datasources/remote/missing_price_firestore_datasource.dart';
import 'package:smartmeal/data/models/missing_price_entry_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class MissingPriceRepositoryImpl implements MissingPriceRepository {
  final MissingPriceFirestoreDatasource _datasource;

  MissingPriceRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, void>> trackMissingPrice(MissingPriceEntry entry) async {
    try {
      final model = MissingPriceEntryModel.fromEntity(entry);
      await _datasource.trackMissingPrice(model);
      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MissingPriceRepository] Error: $e');
      }
      return Left(ServerFailure('Error tracking precio: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MissingPriceEntry>>> getTopMissingPrices({
    int limit = 20,
  }) async {
    try {
      final models = await _datasource.getTopMissingPrices(limit: limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MissingPriceRepository] Error: $e');
      }
      return Left(ServerFailure('Error obteniendo top missing: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MissingPriceEntry>>> getAllMissingPrices() async {
    try {
      final models = await _datasource.getAllMissingPrices();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MissingPriceRepository] Error: $e');
      }
      return Left(ServerFailure('Error obteniendo missing prices: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeMissingPrice(String normalizedName) async {
    try {
      await _datasource.removeMissingPrice(normalizedName);
      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MissingPriceRepository] Error: $e');
      }
      return Left(ServerFailure('Error eliminando missing price: $e'));
    }
  }
}
