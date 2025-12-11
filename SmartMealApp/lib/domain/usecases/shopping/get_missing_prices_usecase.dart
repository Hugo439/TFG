import 'package:smartmeal/core/errors/failures.dart';
import 'package:smartmeal/domain/entities/missing_price_entry.dart';
import 'package:smartmeal/domain/repositories/missing_price_repository.dart';
import 'package:dartz/dartz.dart';

class GetMissingPricesParams {
  final int limit;

  const GetMissingPricesParams({this.limit = 20});
}

class GetMissingPricesUseCase {
  final MissingPriceRepository _repository;

  GetMissingPricesUseCase(this._repository);

  Future<Either<Failure, List<MissingPriceEntry>>> call(GetMissingPricesParams params) async {
    try {
      return await _repository.getTopMissingPrices(limit: params.limit);
    } catch (e) {
      return Left(UnknownFailure('Error obteniendo precios faltantes: $e'));
    }
  }
}
