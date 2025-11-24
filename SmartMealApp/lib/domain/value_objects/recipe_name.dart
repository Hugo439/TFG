class RecipeName {
  final String value;

  RecipeName(String input) : value = _validate(input);

  static String _validate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('El nombre de la receta no puede estar vacío');
    }
    if (trimmed.length < 3) {
      throw ArgumentError('El nombre de la receta debe tener al menos 3 caracteres');
    }
    if (trimmed.length > 100) {
      throw ArgumentError('El nombre de la receta no puede exceder 100 caracteres');
    }
    return trimmed;
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeName && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}