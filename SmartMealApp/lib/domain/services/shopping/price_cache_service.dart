import 'package:smartmeal/domain/services/shopping/smart_ingredient_normalizer.dart';

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

class PriceCacheService {
  final Map<String, PriceCacheEntry> _memoryCache = {};
  
  // Configuración
  static const Duration defaultTtl = Duration(hours: 24);
  static const int maxCacheSize = 500;

  /// Obtiene un precio desde caché (si no ha expirado)
  double? get(String cacheKey) {
    final entry = _memoryCache[cacheKey];
    
    if (entry == null) return null;
    
    if (entry.isExpired) {
      _memoryCache.remove(cacheKey);
      return null;
    }

    return entry.price;
  }

  /// Guarda un precio en caché
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

  /// Genera clave de caché
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
    
    final oldest = _memoryCache.values
        .reduce((a, b) => a.fetchedAt.isBefore(b.fetchedAt) ? a : b);
    
    return oldest.age;
  }
}