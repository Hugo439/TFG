class SupportCategory {
  final String value;

  static const List<String> validCategories = [
    'Dudas',
    'Errores',
    'Sugerencias',
    'Cuenta',
    'Menús',
    'Otro',
  ];

  SupportCategory(String? input) : value = input ?? '' {
    if (value.isEmpty) {
      throw ArgumentError('Debe seleccionar una categoría');
    }
    if (!validCategories.contains(value)) {
      throw ArgumentError('Categoría no válida');
    }
  }

  @override
  String toString() => value;
}