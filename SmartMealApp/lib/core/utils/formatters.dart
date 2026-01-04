/// Utilidades para formatear datos y presentarlos de forma amigable al usuario.
///
/// Esta clase contiene métodos estáticos para convertir datos crudos en strings
/// formateados y legibles, especialmente útil para mostrar información en la UI.
class Formatters {
  /// Formatea un peso en kilogramos a string con una decimal.
  ///
  /// **Ejemplo:** `formatWeight(75.5)` retorna `"75.5 kg"`
  static String formatWeight(double kg) {
    return '${kg.toStringAsFixed(1)} kg';
  }

  /// Formatea una altura en centímetros a string.
  ///
  /// **Ejemplo:** `formatHeight(175)` retorna `"175 cm"`
  static String formatHeight(int cm) {
    return '$cm cm';
  }

  /// Formatea un número de teléfono o retorna mensaje si está vacío.
  ///
  /// **Parámetro:**
  /// - [phone]: Número de teléfono o null
  ///
  /// **Retorna:** El teléfono formateado o "No especificado"
  static String formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'No especificado';
    return phone;
  }

  /// Formatea alergias o retorna mensaje si no hay ninguna.
  ///
  /// **Parámetro:**
  /// - [allergies]: String con alergias separadas por comas o null
  ///
  /// **Retorna:** Las alergias o "Sin alergias registradas"
  static String formatAllergies(String? allergies) {
    if (allergies == null || allergies.isEmpty) {
      return 'Sin alergias registradas';
    }
    return allergies;
  }

  /// Capitaliza la primera letra de un texto.
  ///
  /// **Ejemplo:** `capitalize("hola")` retorna `"Hola"`
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Formatea una fecha a formato corto en español (día + mes abreviado).
  ///
  /// **Ejemplo:** `formatShortDate(DateTime(2024, 3, 15))` retorna `"15 Mar"`
  static String formatShortDate(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
