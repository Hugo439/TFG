class SupportMessageContent {
  final String value;

  SupportMessageContent(String input) : value = input.trim() {
    if (value.isEmpty) {
      throw ArgumentError('El mensaje no puede estar vacío');
    }
    if (value.length < 10) {
      throw ArgumentError('El mensaje debe tener al menos 10 caracteres');
    }
    if (value.length > 1000) {
      throw ArgumentError('El mensaje no puede superar los 1000 caracteres');
    }
  }

  @override
  String toString() => value;
}
