import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/shopping_repository.dart';

/// UseCase para calcular precio total de la lista de compra.
///
/// Responsabilidad:
/// - Sumar precios de todos los items en lista de compra
/// - Incluir solo items no marcados como comprados (isChecked=false)
///
/// Entrada:
/// - NoParams (usa usuario autenticado)
///
/// Salida:
/// - double con precio total en euros
///
/// Uso típico:
/// ```dart
/// final total = await getTotalPriceUseCase(NoParams());
/// print('Total estimado: €${total.toStringAsFixed(2)}');
/// ```
///
/// Cálculo:
/// - Obtiene todos los ShoppingItem del usuario
/// - Filtra items con isChecked=false (pendientes)
/// - Suma item.price.value de cada uno
///
/// Nota: Solo cuenta items pendientes de comprar.
class GetTotalPriceUseCase implements UseCase<double, NoParams> {
  final ShoppingRepository repository;

  GetTotalPriceUseCase(this.repository);

  @override
  Future<double> call(NoParams params) async {
    return await repository.getTotalPrice();
  }
}
