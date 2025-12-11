import 'package:smartmeal/core/errors/failures.dart';
import 'package:smartmeal/domain/entities/price_entry.dart';
import 'package:smartmeal/domain/repositories/price_catalog_repository.dart';
import 'package:smartmeal/data/datasources/remote/price_catalog_firestore_datasource.dart';
import 'package:smartmeal/data/models/price_entry_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class PriceCatalogRepositoryImpl implements PriceCatalogRepository {
  final PriceCatalogFirestoreDatasource _datasource;

  PriceCatalogRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, PriceEntry?>> getPriceEntry(String normalizedName) async {
    try {
      final model = await _datasource.getPriceEntry(normalizedName);
      return Right(model?.toEntity());
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PriceCatalogRepository] Error: $e');
      }
      return Left(ServerFailure('Error obteniendo precio: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PriceEntry>>> getPricesByCategory(String category) async {
    try {
      final models = await _datasource.getPricesByCategory(category);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PriceCatalogRepository] Error: $e');
      }
      return Left(ServerFailure('Error obteniendo categoría: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PriceEntry>>> searchPrices(String searchTerm) async {
    try {
      final models = await _datasource.searchPrices(searchTerm);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PriceCatalogRepository] Error: $e');
      }
      return Left(ServerFailure('Error buscando precios: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> savePriceEntry(PriceEntry entry) async {
    try {
      final model = PriceEntryModel.fromEntity(entry);
      await _datasource.savePriceEntry(model);
      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PriceCatalogRepository] Error: $e');
      }
      return Left(ServerFailure('Error guardando precio: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePriceEntry(String normalizedName) async {
    try {
      await _datasource.deletePriceEntry(normalizedName);
      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PriceCatalogRepository] Error: $e');
      }
      return Left(ServerFailure('Error eliminando precio: $e'));
    }
  }
}
