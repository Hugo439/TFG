/// Excepción lanzada cuando se intenta generar una lista de compra con un menú
/// que ya ha sido añadido a la lista actual
class MenuAlreadyGeneratedException implements Exception {
  final String message;

  MenuAlreadyGeneratedException({
    this.message = 'Los ingredientes de este menú ya se habían añadido a la lista de compra',
  });

  @override
  String toString() => message;
}
//TODO: Usar l10n