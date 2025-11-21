class AppConstants {
  // Goals
  static const List<String> goals = [
    'Perder peso',
    'Mantener peso',
    'Ganar masa muscular',
    'Alimentación saludable',
  ];

  // Validation
  static const int minPasswordLength = 6;
  static const int minHeightCm = 50;
  static const int maxHeightCm = 300;
  static const double minWeightKg = 20;
  static const double maxWeightKg = 500;

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const int splashDuration = 1; // segundos
  
  // Collections Firestore
  static const String usersCollection = 'users';
  
  // Error Messages
  static const String errorNoAuth = 'Usuario no autenticado';
  static const String errorProfileNotFound = 'Perfil no encontrado';
  static const String errorGeneric = 'Ha ocurrido un error';
}