import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';

/// Representa una entrada de precio en caché con metadatos de expiración.
///
/// Propiedades:
/// - **price**: precio calculado
/// - **fetchedAt**: timestamp de cuando se calculó
/// - **expiresAt**: timestamp de expiración
/// - **source**: origen del precio ('firestore', 'fallback', 'api')
///
/// Métodos útiles:
/// - **isExpired**: verifica si ha expirado
/// - **age**: duración desde que se calculó
class PriceCacheEntry {
  final double price;
  final DateTime fetchedAt;
  final DateTime expiresAt;
  final String source; // 'firestore', 'fallback', 'api'

  PriceCacheEntry({
    required this.price,
    required this.fetchedAt,
    required this.expiresAt,
    required this.source,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get age => DateTime.now().difference(fetchedAt);

  factory PriceCacheEntry.fromMap(Map<String, dynamic> map) {
    return PriceCacheEntry(
      price: (map['price'] as num).toDouble(),
      fetchedAt: DateTime.parse(map['fetchedAt'] as String),
      expiresAt: DateTime.parse(map['expiresAt'] as String),
      source: map['source'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'fetchedAt': fetchedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'source': source,
    };
  }
}

/// Servicio de caché en memoria para precios de ingredientes.
///
/// Responsabilidades:
/// - Cachear precios calculados en memoria (RAM)
/// - Gestionar expiración automática (TTL configurable)
/// - Limitar tamaño máximo de caché
/// - Proveer estadísticas de uso
///
/// Configuración:
/// - **defaultTtl**: 24 horas
/// - **maxCacheSize**: 500 entradas
///
/// Estrategia de limpieza:
/// - Cuando se alcanza maxCacheSize, elimina 20% de entradas más antiguas
/// - Limpieza automática de entradas expiradas al consultar
///
/// Generación de claves:
/// - Formato: "nombreNormalizado:categoría:cantidad:unidad"
/// - Ejemplo: "pollo:carnesYPescados:500:weight"
///
/// Beneficios:
/// - Reduce cálculos repetidos de precios
/// - Mejora rendimiento en listas de compra grandes
/// - Evita llamadas redundantes a servicios externos
///
/// Uso típico:
/// ```dart
/// final cache = PriceCacheService();
/// final key = PriceCacheService.generateKey(
///   ingredientName: "pollo",
///   category: "carnesYPescados",
///   quantityBase: 500,
///   unitKind: "weight",
/// );
///
/// // Intentar obtener desde caché
/// var price = cache.get(key);
/// if (price == null) {
///   // Calcular y cachear
///   price = calculatePrice();
///   cache.set(key, price, source: 'calculated');
/// }
/// ```
class PriceCacheService {
  final Map<String, PriceCacheEntry> _memoryCache = {};

  // Configuración
  static const Duration defaultTtl = Duration(hours: 24);
  static const int maxCacheSize = 500;

  /// Obtiene precio desde caché si no ha expirado.
  ///
  /// [cacheKey] - Clave generada con generateKey().
  ///
  /// Returns: Precio cacheado o null si no existe o expiró.
  ///
  /// Comportamiento:
  /// - Si expirado: remueve de caché y retorna null
  /// - Si válido: retorna precio
  double? get(String cacheKey) {
    final entry = _memoryCache[cacheKey];

    if (entry == null) return null;

    if (entry.isExpired) {
      _memoryCache.remove(cacheKey);
      return null;
    }

    return entry.price;
  }

  /// Guarda precio en caché con expiración.
  ///
  /// [cacheKey] - Clave de caché.
  /// [price] - Precio a cachear.
  /// [ttl] - Tiempo de vida (default: 24h).
  /// [source] - Origen del precio para estadísticas.
  ///
  /// Comportamiento:
  /// - Si caché llena (>= maxCacheSize): limpia 20% más antiguas antes
  void set(
    String cacheKey,
    double price, {
    Duration? ttl,
    String source = 'unknown',
  }) {
    // Limpiar caché si está llena
    if (_memoryCache.length >= maxCacheSize) {
      _cleanOldestEntries();
    }

    final now = DateTime.now();
    final entry = PriceCacheEntry(
      price: price,
      fetchedAt: now,
      expiresAt: now.add(ttl ?? defaultTtl),
      source: source,
    );

    _memoryCache[cacheKey] = entry;
  }

  /// Genera clave de caché consistente.
  ///
  /// Normaliza ingredientName antes de generar clave.
  ///
  /// Returns: String con formato "nombre:categoría:cantidad:unidad".
  static String generateKey({
    required String ingredientName,
    required String category,
    required double quantityBase,
    required String unitKind,
  }) {
    final normalized = SmartIngredientNormalizer().normalize(ingredientName);
    return '$normalized:$category:$quantityBase:$unitKind';
  }

  /// Limpia entradas expiradas
  void cleanExpired() {
    _memoryCache.removeWhere((key, entry) => entry.isExpired);
  }

  /// Limpia las entradas más antiguas
  void _cleanOldestEntries() {
    if (_memoryCache.isEmpty) return;

    final sortedEntries = _memoryCache.entries.toList()
      ..sort((a, b) => a.value.fetchedAt.compareTo(b.value.fetchedAt));

    // Eliminar 20% más antiguas
    final removeCount = (maxCacheSize * 0.2).ceil();
    for (var i = 0; i < removeCount && i < sortedEntries.length; i++) {
      _memoryCache.remove(sortedEntries[i].key);
    }
  }

  /// Limpia toda la caché
  void clear() {
    _memoryCache.clear();
  }

  /// Estadísticas de caché
  Map<String, dynamic> getStats() {
    final total = _memoryCache.length;
    final expired = _memoryCache.values.where((e) => e.isExpired).length;
    final valid = total - expired;

    return {
      'total_entries': total,
      'valid_entries': valid,
      'expired_entries': expired,
      'sources': _getSourceBreakdown(),
      'oldest_entry': _getOldestEntryAge(),
    };
  }

  Map<String, int> _getSourceBreakdown() {
    final breakdown = <String, int>{};
    for (final entry in _memoryCache.values) {
      breakdown[entry.source] = (breakdown[entry.source] ?? 0) + 1;
    }
    return breakdown;
  }

  Duration? _getOldestEntryAge() {
    if (_memoryCache.isEmpty) return null;

    final oldest = _memoryCache.values.reduce(
      (a, b) => a.fetchedAt.isBefore(b.fetchedAt) ? a : b,
    );

    return oldest.age;
  }
}
