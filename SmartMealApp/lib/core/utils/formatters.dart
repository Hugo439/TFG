class Formatters {
  static String formatWeight(double kg) {
    return '${kg.toStringAsFixed(1)} kg';
  }

  static String formatHeight(int cm) {
    return '$cm cm';
  }

  static String formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'No especificado';
    return phone;
  }

  static String formatAllergies(String? allergies) {
    if (allergies == null || allergies.isEmpty) {
      return 'Sin alergias registradas';
    }
    return allergies;
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

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
