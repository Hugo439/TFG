import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/models/groq_menu_response_model.dart';
import 'package:smartmeal/core/utils/calorie_distribution_utils.dart';

class GeminiMenuDatasource {
  static const String _workerUrl = 'https://groq-worker.smartmealgroq.workers.dev'; // ← Tu URL del worker
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  GeminiMenuDatasource();

  Future<GroqMenuResponseModel> generateWeeklyMenu({
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

    final prompt = '''
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

INSTRUCCIONES:
1. Crea 28 recetas DIFERENTES y REALISTAS
2. Calcula calorías reales según ingredientes y cantidades
3. Incluye cantidades en ingredientes (ej: "200g pollo", "100g arroz")
4. Varía proteínas, métodos de cocción, ingredientes mediterráneos

ESTRUCTURA DE ÍNDICES (CRÍTICO):
- Índices 0-6: "mealType": "breakfast"
- Índices 7-13: "mealType": "lunch"
- Índices 14-20: "mealType": "snack"
- Índices 21-27: "mealType": "dinner"

MENÚ SEMANAL:
Asigna 4 índices diferentes por día:
- breakfast: índice 0-6
- lunch: índice 7-13
- snack: índice 14-20
- dinner: índice 21-27

Responde ÚNICAMENTE con este JSON (sin markdown, sin comentarios):

{
  "recipes": [
    {"name": "...", "description": "...", "ingredients": ["cantidad + ingrediente", ...], "calories": numero, "mealType": "breakfast"},
    ... (28 recetas totales)
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
            debugPrint('[GeminiWorker] Error ${response.statusCode}: ${response.body}');
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
            debugPrint('[GeminiWorker] Claves encontradas: ${result.keys.join(', ')}');
          }
          throw Exception("Falta 'recipes' en el JSON");
        }

        if (!result.containsKey('weeklyMenu')) {
          if (kDebugMode) {
            debugPrint('[GeminiWorker] Claves encontradas: ${result.keys.join(', ')}');
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

        return GroqMenuResponseModel.fromJson(result);

      } catch (e) {
        lastError = Exception('Intento #$attempt falló: $e');
        
        if (kDebugMode) {
          debugPrint('[GeminiWorker] $lastError');
        }

        if (attempt < _maxRetries - 1) {
          await Future.delayed(_retryDelay);
        }
      }
    }

    throw lastError ?? Exception('Error desconocido generando menú');
  }
}