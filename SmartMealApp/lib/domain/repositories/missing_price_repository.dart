import 'package:smartmeal/core/errors/failures.dart';
import 'package:smartmeal/domain/entities/missing_price_entry.dart';
import 'package:dartz/dartz.dart';

/// Repositorio para tracking de precios faltantes
abstract class MissingPriceRepository {
  /// Registra un ingrediente sin precio (incrementa contador si ya existe)
  Future<Either<Failure, void>> trackMissingPrice(MissingPriceEntry entry);

  /// Obtiene los ingredientes sin precio más solicitados
  Future<Either<Failure, List<MissingPriceEntry>>> getTopMissingPrices({
    int limit = 20,
  });

  /// Obtiene todas las entradas de precios faltantes
  Future<Either<Failure, List<MissingPriceEntry>>> getAllMissingPrices();

  /// Elimina una entrada (cuando se agrega al catálogo)
  Future<Either<Failure, void>> removeMissingPrice(String normalizedName);
}
