/// Constantes centralizadas de la aplicación SmartMeal.
///
/// Esta clase actúa como una única fuente de verdad para todas las constantes
/// utilizadas en la aplicación, facilitando el mantenimiento y evitando
/// valores mágicos dispersos por el código.
///
/// Siguiendo la guía de estilo de Dart: constantes en lowerCamelCase.
class AppConstants {
  /// Constructor privado para prevenir instanciación de esta clase de utilidad.
  AppConstants._();

  // ============================================================================
  // FIRESTORE COLLECTIONS
  // ============================================================================

  /// Nombre de la colección de usuarios en Firestore.
  static const String collectionUsers = 'users';

  /// Nombre de la colección de menús semanales en Firestore.
  static const String collectionWeeklyMenus = 'weekly_menus';

  /// Nombre de la colección de recetas en Firestore.
  static const String collectionRecipes = 'recipes';

  /// Nombre de la colección de items de la lista de compra.
  static const String collectionShoppingItems = 'shoppingItems';

  /// Nombre de la colección del catálogo de precios global.
  static const String collectionPriceCatalog = 'priceCatalog';

  /// Nombre de la colección de precios personalizados por usuario.
  static const String collectionUserPriceOverrides = 'userPriceOverrides';

  /// Nombre de la colección de productos con precios faltantes.
  static const String collectionMissingPrices = 'missingPrices';

  /// Nombre de la colección de mensajes de soporte.
  static const String collectionSupportMessages = 'supportMessages';

  /// Nombre de la colección de preguntas frecuentes (FAQs).
  static const String collectionFaqs = 'faqs';

  /// Nombre de la colección de estadísticas de usuario.
  static const String collectionStatistics = 'statistics';

  // ============================================================================
  // FIRESTORE FIELDS - Nombres de campos comunes en documentos de Firestore
  // ============================================================================

  /// Campo timestamp de creación del documento.
  static const String fieldCreatedAt = 'createdAt';

  /// Campo timestamp de última actualización del documento.
  static const String fieldUpdatedAt = 'updatedAt';

  /// Campo con el ID del usuario propietario.
  static const String fieldUserId = 'userId';

  /// Campo con el token FCM para notificaciones push.
  static const String fieldFcmToken = 'fcmToken';

  /// Campo booleano que indica si un item está marcado/completado.
  static const String fieldIsChecked = 'isChecked';

  /// Campo con array de días del menú semanal.
  static const String fieldDays = 'days';

  /// Campo con array de recetas.
  static const String fieldRecipes = 'recipes';

  /// Campo con referencia al menú semanal.
  static const String fieldWeeklyMenu = 'weeklyMenu';

  /// Campo con el tipo de comida (desayuno, comida, cena, snack).
  static const String fieldMealType = 'mealType';

  /// Campo con la fecha de inicio de la semana del menú.
  static const String fieldWeekStartDate = 'weekStart';

  /// Campo con el nombre del producto/receta/item.
  static const String fieldName = 'name';

  /// Campo con el precio del producto.
  static const String fieldPrice = 'price';

  /// Campo con la cantidad/cantidad del producto.
  static const String fieldAmount = 'amount';

  /// Campo con la unidad de medida (kg, g, L, unidades, etc).
  static const String fieldUnit = 'unit';

  /// Campo con el día de la semana.
  static const String fieldDay = 'day';

  // ============================================================================
  // GOALS - Objetivos nutricionales del usuario
  // ============================================================================

  /// Lista de objetivos nutricionales disponibles en la aplicación.
  /// Estos determinan el ajuste calórico en el plan de comidas.
  static const List<String> goals = [
    'Perder peso',
    'Mantener peso',
    'Ganar masa muscular',
    'Alimentación saludable',
  ];

  // ============================================================================
  // VALIDATION CONSTRAINTS - Límites de validación para datos de usuario
  // ============================================================================

  /// Longitud mínima para contraseñas (seguridad básica).
  static const int minPasswordLength = 6;

  /// Altura mínima aceptada en centímetros.
  static const int minHeightCm = 50;

  /// Altura máxima aceptada en centímetros.
  static const int maxHeightCm = 300;

  /// Peso mínimo aceptado en kilogramos.
  static const double minWeightKg = 20;

  /// Peso máximo aceptado en kilogramos.
  static const double maxWeightKg = 500;

  /// Edad mínima de usuario (13 años por restricciones legales).
  static const int minAge = 13;

  /// Edad máxima de usuario.
  static const int maxAge = 120;

  // ============================================================================
  // UI CONSTANTS - Constantes de interfaz de usuario
  // ============================================================================

  /// Padding por defecto usado en la aplicación.
  static const double defaultPadding = 16.0;

  /// Radio de borde por defecto para componentes redondeados.
  static const double defaultBorderRadius = 12.0;

  /// Duración de la pantalla splash en segundos.
  static const int splashDurationSeconds = 1;

  /// Número máximo de reintentos para operaciones de red.
  static const int maxRetries = 3;

  /// Tiempo de espera en segundos entre reintentos.
  static const int retryDelaySeconds = 2;

  // ============================================================================
  // ERROR MESSAGES - Mensajes de error predefinidos
  // ============================================================================

  /// Mensaje cuando el usuario no está autenticado.
  static const String errorNoAuth = 'Usuario no autenticado';

  /// Mensaje cuando no se encuentra el perfil del usuario.
  static const String errorProfileNotFound = 'Perfil no encontrado';

  /// Mensaje genérico para errores no específicos.
  static const String errorGeneric = 'Ha ocurrido un error';

  /// Mensaje cuando no se encuentra el menú solicitado.
  static const String errorMenuNotFound = 'Menú no encontrado';

  /// Mensaje cuando no se encuentra la receta solicitada.
  static const String errorRecipeNotFound = 'Receta no encontrada';

  // ============================================================================
  // API URLS - URLs de servicios externos
  // ============================================================================

  /// URL base del worker de Groq (Cloudflare Workers).
  static const String groqWorkerUrl =
      'https://groq-worker.smartmealgroq.workers.dev';

  /// URL del endpoint de Gemini en el worker.
  static const String groqWorkerGeminiUrl =
      'https://groq-worker.smartmealgroq.workers.dev/gemini';

  // ============================================================================
  // HTTP STATUS CODES - Códigos de estado HTTP comunes
  // ============================================================================

  /// Código HTTP 200 - Petición exitosa.
  static const int httpOk = 200;

  /// Código HTTP 201 - Recurso creado exitosamente.
  static const int httpCreated = 201;

  /// Código HTTP 400 - Petición mal formada.
  static const int httpBadRequest = 400;

  /// Código HTTP 401 - No autorizado.
  static const int httpUnauthorized = 401;

  /// Código HTTP 404 - Recurso no encontrado.
  static const int httpNotFound = 404;

  /// Código HTTP 500 - Error interno del servidor.
  static const int httpServerError = 500;

  // ============================================================================
  // ASSET PATHS - Rutas a recursos estáticos
  // ============================================================================

  /// Ruta al logo de la aplicación.
  static const String assetLogo = 'assets/branding/logo.png';

  /// Ruta a la carpeta de recursos de branding.
  static const String assetBrandingFolder = 'assets/branding';

  // ============================================================================
  // MEAL TYPES - Constantes relacionadas con tipos de comidas
  // ============================================================================

  /// Número de comidas por día (desayuno, comida, cena, snack).
  static const int mealsPerDay = 4;

  /// Número de días en una semana.
  static const int daysPerWeek = 7;

  /// Total de recetas en un menú semanal completo (4 comidas × 7 días).
  static const int totalRecipesPerWeek = 28;

  // ============================================================================
  // CACHE KEYS - Claves para caché local
  // ============================================================================

  /// Clave de caché para el último menú semanal.
  static const String cacheKeyWeeklyMenu = 'latest_weekly_menu_cache';

  /// Clave de caché para estadísticas del usuario.
  static const String cacheKeyStatistics = 'statistics_cache';

  /// Clave de caché para items de la lista de compras.
  static const String cacheKeyShoppingItems = 'shopping_items_cache';

  // ============================================================================
  // SHARED PREFERENCES KEYS - Claves para preferencias compartidas
  // ============================================================================

  /// Clave que indica si es la primera vez que se abre la app.
  static const String prefKeyFirstTime = 'first_time';

  /// Clave para el modo de tema (claro/oscuro).
  static const String prefKeyThemeMode = 'theme_mode';

  /// Clave para el idioma seleccionado.
  static const String prefKeyLanguage = 'language';

  // ============================================================================
  // NOTIFICATIONS - Configuración de notificaciones
  // ============================================================================

  /// Duración en segundos para mostrar notificaciones en pantalla.
  static const int notificationDurationSeconds = 4;

  /// Título por defecto para notificaciones.
  static const String notificationDefaultTitle = 'SmartMeal';

  /// Cuerpo por defecto para notificaciones.
  static const String notificationDefaultBody = 'Tienes una nueva notificación';

  // ============================================================================
  // JSON KEYS - Claves JSON para respuestas de API
  // ============================================================================

  /// Clave JSON para array de recetas.
  static const String jsonKeyRecipes = 'recipes';

  /// Clave JSON para objeto de menú semanal.
  static const String jsonKeyWeeklyMenu = 'weeklyMenu';

  /// Clave JSON para pasos de receta.
  static const String jsonKeySteps = 'steps';

  /// Clave JSON para contenido de la respuesta.
  static const String jsonKeyContent = 'content';

  /// Clave JSON para mensajes de error.
  static const String jsonKeyError = 'error';

  /// Clave JSON para opciones/choices de IA.
  static const String jsonKeyChoices = 'choices';

  /// Clave JSON para mensajes.
  static const String jsonKeyMessage = 'message';

  /// Clave JSON para prompts enviados a IA.
  static const String jsonKeyPrompt = 'prompt';

  // ============================================================================
  // HTTP HEADERS - Cabeceras HTTP comunes
  // ============================================================================

  /// Cabecera HTTP para especificar tipo de contenido.
  static const String headerContentType = 'Content-Type';

  /// Tipo de contenido JSON para peticiones HTTP.
  static const String contentTypeJson = 'application/json';
}
