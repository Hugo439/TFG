import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/models/ai_menu_response_model.dart';
import 'package:smartmeal/core/utils/calorie_distribution_utils.dart';

class GeminiMenuDatasource {
  static const String _workerUrl =
      'https://groq-worker.smartmealgroq.workers.dev/gemini';
  static const int _maxRetries = 5;
  static const Duration _initialRetryDelay = Duration(seconds: 3);

  GeminiMenuDatasource();

  Future<AiMenuResponseModel> generateWeeklyMenu({
    required int targetCaloriesPerMeal,
    required List<String> excludedTags,
    required String userGoal,
    int recipesCount = 28,
  }) async {
    final allergiesText = excludedTags.isEmpty
        ? 'Sin restricciones'
        : 'EVITAR: ${excludedTags.join(', ')}';

    final dailyCalories = targetCaloriesPerMeal * 4;
    final distribution = MealCalorieDistribution.fromDailyTarget(dailyCalories);

    final prompt =
        '''
Eres un nutricionista experto. Genera un menú semanal COMPLETO en formato JSON.

DATOS DEL USUARIO:
- Objetivo: $userGoal
- Calorías diarias: $dailyCalories kcal
- Restricciones: $allergiesText

CALORÍAS POR TIPO DE COMIDA:
- Breakfast: ${distribution.breakfast.min}-${distribution.breakfast.max} kcal
- Lunch: ${distribution.lunch.min}-${distribution.lunch.max} kcal
- Snack: ${distribution.snack.min}-${distribution.snack.max} kcal
- Dinner: ${distribution.dinner.min}-${distribution.dinner.max} kcal

REQUISITOS:
1. $recipesCount recetas diferentes
2. Calorías reales según ingredientes
3. Variedad de proteínas y técnicas culinarias

FORMATO INGREDIENTES:
"[cantidad] [unidad] [nombre]"
- Unidades: g, kg, ml, l, ud
- Solo nombre base (sin adjetivos, colores, estados)
- NO usar paréntesis ni comentarios. Evita cualquier "(...)".
- Ejemplos: "200 g pollo pechuga", "40 ml aceite oliva", "2 ud huevo"

ÍNDICES:
- 0-6: breakfast
- 7-13: lunch
- 14-20: snack
- 21-27: dinner

PASOS:
4-6 pasos por receta, claros y concisos, sin números

JSON (sin markdown):
{
  "recipes": [
    {"name": "...", "description": "...", "ingredients": ["200 g pollo pechuga", ...], "calories": numero, "mealType": "breakfast", "steps": ["Paso 1", ...]},
    ... (28 recetas)
  ],
  "weeklyMenu": {
    "lunes": {"breakfast": 0, "lunch": 7, "snack": 14, "dinner": 21},
    "martes": {"breakfast": 1, "lunch": 8, "snack": 15, "dinner": 22},
    "miércoles": {"breakfast": 2, "lunch": 9, "snack": 16, "dinner": 23},
    "jueves": {"breakfast": 3, "lunch": 10, "snack": 17, "dinner": 24},
    "viernes": {"breakfast": 4, "lunch": 11, "snack": 18, "dinner": 25},
    "sábado": {"breakfast": 5, "lunch": 12, "snack": 19, "dinner": 26},
    "domingo": {"breakfast": 6, "lunch": 13, "snack": 20, "dinner": 27}
  }
}
''';

    Exception? lastError;

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        if (kDebugMode && attempt > 0) {
          debugPrint('[GeminiWorker] Reintento #$attempt...');
        }

        final response = await http.post(
          Uri.parse(_workerUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'prompt': prompt}),
        );

        if (response.statusCode != 200) {
          if (kDebugMode) {
            debugPrint(
              '[GeminiWorker] Error ${response.statusCode}: ${response.body}',
            );
          }
          throw Exception('Error del servidor: ${response.statusCode}');
        }

        final data = json.decode(response.body);

        // Verificar si hay error del worker
        if (data.containsKey('error')) {
          final errorMsg = data['error'];
          if (kDebugMode) {
            debugPrint('[GeminiWorker] ERROR: $errorMsg');
          }
          throw Exception('Error del worker: $errorMsg');
        }

        // Extraer contenido
        final content = data['content'];

        if (content == null) {
          throw Exception('Respuesta vacía del worker');
        }

        // Limpiar markdown si existe
        String cleanText = content.trim();
        if (cleanText.startsWith('```json')) {
          cleanText = cleanText.substring(7);
        }
        if (cleanText.startsWith('```')) {
          cleanText = cleanText.substring(3);
        }
        if (cleanText.endsWith('```')) {
          cleanText = cleanText.substring(0, cleanText.length - 3);
        }
        cleanText = cleanText.trim();

        // Buscar JSON
        final start = cleanText.indexOf('{');
        final end = cleanText.lastIndexOf('}') + 1;

        if (start == -1 || end <= start) {
          throw Exception('No se encontró JSON válido en la respuesta');
        }

        final jsonStr = cleanText.substring(start, end);
        final decoded = json.decode(jsonStr);

        if (decoded is! Map) {
          throw Exception('El JSON no es un objeto');
        }

        final result = Map<String, dynamic>.from(decoded);

        // Validación
        if (!result.containsKey('recipes')) {
          if (kDebugMode) {
            debugPrint(
              '[GeminiWorker] Claves encontradas: ${result.keys.join(', ')}',
            );
          }
          throw Exception("Falta 'recipes' en el JSON");
        }

        if (!result.containsKey('weeklyMenu')) {
          if (kDebugMode) {
            debugPrint(
              '[GeminiWorker] Claves encontradas: ${result.keys.join(', ')}',
            );
          }
          throw Exception("Falta 'weeklyMenu' en el JSON");
        }

        if (result['recipes'] is! List) {
          throw Exception("'recipes' debe ser una lista");
        }

        if (result['weeklyMenu'] is! Map) {
          throw Exception("'weeklyMenu' debe ser un objeto");
        }

        if (kDebugMode && attempt > 0) {
          debugPrint('[GeminiWorker] ✓ Éxito en intento #$attempt');
        }

        return AiMenuResponseModel.fromJson(result);
      } catch (e) {
        lastError = Exception('Intento #$attempt falló: $e');

        if (kDebugMode) {
          debugPrint('[GeminiWorker] $lastError');
        }

        if (attempt < _maxRetries - 1) {
          // Exponential backoff: 3s, 6s, 12s, 24s
          final delaySeconds = _initialRetryDelay.inSeconds * (1 << attempt);
          final delay = Duration(seconds: delaySeconds);
          if (kDebugMode) {
            debugPrint(
              '[GeminiWorker] Esperando ${delay.inSeconds}s antes del siguiente intento...',
            );
          }
          await Future.delayed(delay);
        }
      }
    }

    throw lastError ?? Exception('Error desconocido generando menú');
  }
}
