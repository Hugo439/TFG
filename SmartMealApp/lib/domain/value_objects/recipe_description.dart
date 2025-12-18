class RecipeDescription {
  final String value;

  RecipeDescription(String input) : value = _validate(input);

  static String _validate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('La descripción de la receta no puede estar vacía');
    }
    if (trimmed.length > 500) {
      throw ArgumentError('La descripción no puede exceder 500 caracteres');
    }
    return trimmed;
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeDescription &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
