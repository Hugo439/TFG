import 'package:smartmeal/core/errors/failures.dart';
import 'package:smartmeal/domain/entities/price_entry.dart';
import 'package:dartz/dartz.dart';

/// Repositorio para el catálogo de precios editable
abstract class PriceCatalogRepository {
  /// Obtiene una entrada de precio por nombre normalizado
  Future<Either<Failure, PriceEntry?>> getPriceEntry(String normalizedName);

  /// Obtiene todas las entradas de una categoría
  Future<Either<Failure, List<PriceEntry>>> getPricesByCategory(
    String category,
  );

  /// Busca entradas que coincidan con el término de búsqueda
  Future<Either<Failure, List<PriceEntry>>> searchPrices(String searchTerm);

  /// Guarda o actualiza una entrada de precio (solo admin)
  Future<Either<Failure, void>> savePriceEntry(PriceEntry entry);

  /// Elimina una entrada de precio (solo admin)
  Future<Either<Failure, void>> deletePriceEntry(String normalizedName);
}
