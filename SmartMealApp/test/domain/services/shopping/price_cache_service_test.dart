import 'package:flutter_test/flutter_test.dart';
import 'package:smartmeal/domain/services/shopping/price_cache_service.dart';

void main() {
  group('PriceCacheService', () {
    late PriceCacheService cache;

    setUp(() {
      cache = PriceCacheService();
    });

    tearDown(() {
      cache.clear();
    });

    group('set() y get()', () {
      test('guarda y recupera un precio', () {
        cache.set('test_key', 5.0);
        expect(cache.get('test_key'), equals(5.0));
      });

      test('devuelve null para clave no existente', () {
        expect(cache.get('no_existe'), isNull);
      });

      test('guarda múltiples precios', () {
        cache.set('aceite', 8.0);
        cache.set('leche', 1.2);
        cache.set('huevo', 0.25);

        expect(cache.get('aceite'), equals(8.0));
        expect(cache.get('leche'), equals(1.2));
        expect(cache.get('huevo'), equals(0.25));
      });

      test('sobrescribe valor anterior', () {
        cache.set('precio', 5.0);
        expect(cache.get('precio'), equals(5.0));

        cache.set('precio', 6.0);
        expect(cache.get('precio'), equals(6.0));
      });

      test('acepta decimales', () {
        cache.set('key', 3.14159);
        expect(cache.get('key'), equals(3.14159));
      });

      test('acepta valores pequeños y grandes', () {
        cache.set('tiny', 0.01);
        cache.set('huge', 9999.99);

        expect(cache.get('tiny'), equals(0.01));
        expect(cache.get('huge'), equals(9999.99));
      });
    });

    group('TTL (Time To Live)', () {
      test('expira después del TTL por defecto', () async {
        cache.set('key', 5.0, ttl: Duration(milliseconds: 100));

        // Inmediatamente disponible
        expect(cache.get('key'), equals(5.0));

        // Después del TTL, expirado
        await Future.delayed(Duration(milliseconds: 150));
        expect(cache.get('key'), isNull);
      });

      test('usa TTL personalizado', () async {
        cache.set('key', 5.0, ttl: Duration(milliseconds: 50));

        expect(cache.get('key'), equals(5.0));

        await Future.delayed(Duration(milliseconds: 75));
        expect(cache.get('key'), isNull);
      });

      test('refresca TTL en nueva entrada', () async {
        cache.set('key', 5.0, ttl: Duration(milliseconds: 150));

        await Future.delayed(Duration(milliseconds: 50));

        // Establecer nueva entrada (refresca TTL)
        cache.set('key', 6.0, ttl: Duration(milliseconds: 150));

        // Después de otros 100ms, total 150ms, pero TTL refrescado en 50+100=150ms
        await Future.delayed(Duration(milliseconds: 100));
        expect(cache.get('key'), equals(6.0));
      });
    });

    group('generateKey()', () {
      test('genera clave consistente', () {
        final key1 = PriceCacheService.generateKey(
          ingredientName: 'leche',
          category: 'lacteos',
          quantityBase: 1000.0,
          unitKind: 'volume',
        );

        final key2 = PriceCacheService.generateKey(
          ingredientName: 'leche',
          category: 'lacteos',
          quantityBase: 1000.0,
          unitKind: 'volume',
        );

        expect(key1, equals(key2));
      });

      test('diferencia parámetros', () {
        final key1 = PriceCacheService.generateKey(
          ingredientName: 'leche',
          category: 'lacteos',
          quantityBase: 1000.0,
          unitKind: 'volume',
        );

        final key2 = PriceCacheService.generateKey(
          ingredientName: 'agua',
          category: 'bebidas',
          quantityBase: 1000.0,
          unitKind: 'volume',
        );

        expect(key1, isNot(equals(key2)));
      });

      test('normaliza nombre del ingrediente', () {
        final key1 = PriceCacheService.generateKey(
          ingredientName: 'LECHE',
          category: 'lacteos',
          quantityBase: 1000.0,
          unitKind: 'volume',
        );

        final key2 = PriceCacheService.generateKey(
          ingredientName: 'leche',
          category: 'lacteos',
          quantityBase: 1000.0,
          unitKind: 'volume',
        );

        expect(key1, equals(key2));
      });
    });

    group('LRU eviction', () {
      test('evicta entradas antiguas cuando está lleno', () {
        // Llenar caché hasta maxCacheSize (500)
        for (int i = 0; i < PriceCacheService.maxCacheSize; i++) {
          cache.set('key_$i', (i * 1.0));
        }

        expect(cache.getStats()['total_entries'], equals(500));

        // Agregar una más, debe haber eviction
        cache.set('key_new', 999.0);

        // Total debe seguir siendo cerca de 500 (se removieron ~20% más antiguas)
        final stats = cache.getStats();
        expect(stats['total_entries'], lessThan(520));
      });

      test('mantiene entradas más recientes', () async {
        // Agregar 505 entradas
        for (int i = 0; i < 505; i++) {
          cache.set('key_$i', (i * 1.0));
          if (i % 50 == 0) {
            await Future.delayed(Duration(milliseconds: 5));
          }
        }

        // Las entradas antiguas (0-99) deberían estar evicted
        expect(cache.get('key_0'), isNull);
        expect(cache.get('key_10'), isNull);

        // Las más recientes deberían estar presentes
        expect(cache.get('key_500'), isNotNull);
        expect(cache.get('key_504'), isNotNull);
      });
    });

    group('cleanExpired()', () {
      test('remueve entradas expiradas', () async {
        cache.set('key1', 5.0, ttl: Duration(milliseconds: 50));
        cache.set('key2', 6.0, ttl: Duration(hours: 1)); // No expira pronto

        await Future.delayed(Duration(milliseconds: 100));

        // key1 está expirada, key2 no
        cache.cleanExpired();

        expect(cache.get('key1'), isNull);
        expect(cache.get('key2'), equals(6.0));
      });

      test('no afecta entradas válidas', () {
        cache.set('key1', 5.0);
        cache.set('key2', 6.0);

        cache.cleanExpired();

        expect(cache.get('key1'), equals(5.0));
        expect(cache.get('key2'), equals(6.0));
      });
    });

    group('getStats()', () {
      test('reporta estadísticas correctas', () {
        cache.set('key1', 5.0);
        cache.set('key2', 6.0);

        final stats = cache.getStats();

        expect(stats['total_entries'], equals(2));
        expect(stats['valid_entries'], equals(2));
        expect(stats['expired_entries'], equals(0));
      });

      test('cuenta entradas expiradas', () async {
        cache.set('key1', 5.0, ttl: Duration(milliseconds: 50));
        cache.set('key2', 6.0, ttl: Duration(hours: 1));

        await Future.delayed(Duration(milliseconds: 100));

        final stats = cache.getStats();

        expect(stats['total_entries'], equals(2));
        expect(stats['expired_entries'], equals(1));
        expect(stats['valid_entries'], equals(1));
      });

      test('reporta fuentes de precios', () {
        cache.set('key1', 5.0, source: 'firestore');
        cache.set('key2', 6.0, source: 'fallback');
        cache.set('key3', 7.0, source: 'fallback');

        final stats = cache.getStats();
        final sources = stats['sources'] as Map<String, int>;

        expect(sources['firestore'], equals(1));
        expect(sources['fallback'], equals(2));
      });

      test('reporta edad de entrada más antigua', () async {
        cache.set('key1', 5.0);

        await Future.delayed(Duration(milliseconds: 100));

        final stats = cache.getStats();
        final oldestAge = stats['oldest_entry'] as Duration?;

        expect(oldestAge, isNotNull);
        expect(oldestAge!.inMilliseconds, greaterThanOrEqualTo(100));
      });
    });

    group('clear()', () {
      test('limpia toda la caché', () {
        cache.set('key1', 5.0);
        cache.set('key2', 6.0);
        cache.set('key3', 7.0);

        expect(cache.getStats()['total_entries'], equals(3));

        cache.clear();

        expect(cache.getStats()['total_entries'], equals(0));
        expect(cache.get('key1'), isNull);
      });

      test('permite agregar nuevas entradas después de limpiar', () {
        cache.set('key1', 5.0);
        cache.clear();

        cache.set('key2', 6.0);
        expect(cache.get('key2'), equals(6.0));
      });
    });

    group('PriceCacheEntry', () {
      test('detecta expiración correcta', () {
        final now = DateTime.now();
        final future = now.add(Duration(hours: 1));
        final past = now.subtract(Duration(hours: 1));

        final futureEntry = PriceCacheEntry(
          price: 5.0,
          fetchedAt: now,
          expiresAt: future,
          source: 'test',
        );

        final pastEntry = PriceCacheEntry(
          price: 5.0,
          fetchedAt: now,
          expiresAt: past,
          source: 'test',
        );

        expect(futureEntry.isExpired, isFalse);
        expect(pastEntry.isExpired, isTrue);
      });

      test('calcula edad correcta', () async {
        final now = DateTime.now();
        final entry = PriceCacheEntry(
          price: 5.0,
          fetchedAt: now,
          expiresAt: now.add(Duration(hours: 1)),
          source: 'test',
        );

        await Future.delayed(Duration(milliseconds: 100));

        final age = entry.age;
        expect(age.inMilliseconds, greaterThanOrEqualTo(100));
      });

      test('serialización toMap/fromMap', () {
        final now = DateTime.now();
        final entry = PriceCacheEntry(
          price: 5.5,
          fetchedAt: now,
          expiresAt: now.add(Duration(hours: 1)),
          source: 'firestore',
        );

        final map = entry.toMap();
        final reconstructed = PriceCacheEntry.fromMap(map);

        expect(reconstructed.price, equals(entry.price));
        expect(reconstructed.source, equals(entry.source));
        expect(
          reconstructed.fetchedAt.millisecondsSinceEpoch,
          equals(entry.fetchedAt.millisecondsSinceEpoch),
        );
      });
    });

    group('integración', () {
      test('flujo completo: set → wait → expired → get', () async {
        cache.set('test', 5.0, ttl: Duration(milliseconds: 50));

        expect(cache.get('test'), equals(5.0));

        await Future.delayed(Duration(milliseconds: 75));

        expect(cache.get('test'), isNull);
      });

      test('múltiples claves con diferentes TTLs', () async {
        cache.set('fast', 1.0, ttl: Duration(milliseconds: 50));
        cache.set('slow', 2.0, ttl: Duration(seconds: 5));

        await Future.delayed(Duration(milliseconds: 100));

        expect(cache.get('fast'), isNull);
        expect(cache.get('slow'), equals(2.0));
      });

      test('manejo de caché lleno + TTL expiration', () async {
        // Llenar caché
        for (int i = 0; i < PriceCacheService.maxCacheSize; i++) {
          cache.set('key_$i', (i * 1.0));
        }

        // Agregar una entrada que expira rápido
        cache.set('expiring', 999.0, ttl: Duration(milliseconds: 50));

        await Future.delayed(Duration(milliseconds: 100));

        // La entrada expirada debería estar gone
        expect(cache.get('expiring'), isNull);

        // Las demás deberían seguir siendo muchas
        expect(cache.getStats()['total_entries'], greaterThan(100));
      });
    });
  });
}
