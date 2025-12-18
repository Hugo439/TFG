import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/models/ai_menu_response_model.dart';
import 'package:smartmeal/core/utils/calorie_distribution_utils.dart';

class GroqMenuDatasource {
  static const String _backendUrl =
      'https://groq-worker.smartmealgroq.workers.dev/gemini';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  GroqMenuDatasource();

  /// Genera recetas + menú semanal completo
  Future<AiMenuResponseModel> generateWeeklyMenu({
    required int targetCaloriesPerMeal,
    required List<String> excludedTags,
    required String userGoal,
    int recipesCount = 28,
  }) async {
    final allergiesText = excludedTags.isEmpty
        ? 'Sin restricciones'
        : 'EVITAR: ${excludedTags.join(', ')}';

    // Calcular distribución realista de calorías por tipo de comida
    final dailyCalories = targetCaloriesPerMeal * 4;
    final distribution = MealCalorieDistribution.fromDailyTarget(dailyCalories);

    final prompt =
        '''
Eres un nutricionista experto. Debes generar un menú semanal COMPLETO y VÁLIDO para un usuario.

DATOS DEL USUARIO:
- Objetivo: $userGoal
- Calorías objetivo diarias: $dailyCalories kcal
- Restricciones alimentarias: $allergiesText

OBJETIVO DE CALORÍAS POR TIPO DE COMIDA:
- Breakfast (Desayuno): aproximadamente ${(distribution.breakfast.min + distribution.breakfast.max) ~/ 2} kcal (rango aceptable: ${distribution.breakfast.min}-${distribution.breakfast.max} kcal)
- Lunch (Comida): aproximadamente ${(distribution.lunch.min + distribution.lunch.max) ~/ 2} kcal (rango aceptable: ${distribution.lunch.min}-${distribution.lunch.max} kcal)
- Snack (Merienda): aproximadamente ${(distribution.snack.min + distribution.snack.max) ~/ 2} kcal (rango aceptable: ${distribution.snack.min}-${distribution.snack.max} kcal)
- Dinner (Cena): aproximadamente ${(distribution.dinner.min + distribution.dinner.max) ~/ 2} kcal (rango aceptable: ${distribution.dinner.min}-${distribution.dinner.max} kcal)

INSTRUCCIONES PARA CREAR RECETAS CON CALORÍAS REALISTAS:

1. PRIMERO: Piensa en un plato saludable y realista para ese tipo de comida
2. SEGUNDO: Lista los ingredientes específicos CON CANTIDADES (ej: "200g pechuga de pollo", "100g arroz integral cocido", "150g brócoli")
3. TERCERO: Calcula las calorías REALES basándote en los valores nutricionales de esos ingredientes y cantidades
4. CUARTO: Ajusta las cantidades si es necesario para que las calorías totales estén dentro del rango objetivo

Ejemplo de razonamiento correcto(NO USES ESTE EJEMPLO EN LA RESPUESTA):
- Plato: Tostadas con aguacate y huevo
- Ingredientes con cantidades: "2 rebanadas pan integral (160 kcal)", "1/2 aguacate (120 kcal)", "2 huevos (140 kcal)", "tomate cherry (20 kcal)"
- Calorías calculadas: 160 + 120 + 140 + 20 = 440 kcal (dentro del rango breakfast)

IMPORTANTE SOBRE LAS RECETAS:
- Debes crear 28 recetas DIFERENTES, ORIGINALES y VARIADAS
- Incluye diferentes tipos de proteínas (pollo, pescado, huevos, legumbres, carne...)
- Varía los métodos de cocción (al horno, a la plancha, hervido, salteado, crudo...)
- Usa ingredientes mediterráneos y de temporada
- INCLUYE CANTIDADES en los ingredientes cuando sea relevante para las calorías
- Las calorías deben ser REALISTAS según los ingredientes, no números aleatorios
- Respeta las restricciones alimentarias del usuario

INSTRUCCIÓN CRÍTICA: ESTRUCTURA DE ÍNDICES POR TIPO DE COMIDA

Debes generar exactamente 28 recetas organizadas así:
- Índices 0-6 (7 recetas): TODAS con "mealType": "breakfast"
- Índices 7-13 (7 recetas): TODAS con "mealType": "lunch"
- Índices 14-20 (7 recetas): TODAS con "mealType": "snack"
- Índices 21-27 (7 recetas): TODAS con "mealType": "dinner"

NO PUEDES asignar un índice a un mealType diferente.

REGLAS DEL MENÚ SEMANAL

Para cada día de la semana, asigna EXACTAMENTE cuatro índices distintos:
- "breakfast": un índice del rango 0-6
- "lunch": un índice del rango 7-13
- "snack": un índice del rango 14-20
- "dinner": un índice del rango 21-27

Los cuatro índices dentro del mismo día DEBEN ser diferentes entre sí.

ESTRUCTURA JSON REQUERIDA

Devuelve ÚNICAMENTE JSON válido sin comentarios. Las calorías deben reflejar el contenido real del plato:

{
  "recipes": [
    {"name": "Nombre descriptivo del plato", "description": "Breve descripción del plato", "ingredients": ["cantidad + ingrediente1", "cantidad + ingrediente2", "cantidad + ingrediente3"], "calories": CALORÍAS_REALES_DEL_PLATO, "mealType": "breakfast"},
    (repetir para las 28 recetas...)
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

EJEMPLOS DE PLATOS CON CALORÍAS REALISTAS:

BREAKFAST (~${(distribution.breakfast.min + distribution.breakfast.max) ~/ 2} kcal):
- Tostadas integrales con aguacate y huevo: pan (160) + aguacate (120) + huevo (140) = 420 kcal
- Yogur griego con frutos rojos y granola: yogur (150) + fresas (30) + granola (200) = 380 kcal
- Avena con plátano y frutos secos: avena (150) + leche (80) + plátano (90) + nueces (100) = 420 kcal
- Tortilla de 3 huevos con verduras: huevos (210) + espinacas (20) + queso (80) + aceite (90) = 400 kcal

LUNCH (~${(distribution.lunch.min + distribution.lunch.max) ~/ 2} kcal):
- Pechuga de pollo a la plancha con arroz: pollo 150g (180) + arroz 100g (130) + verduras (60) + aceite (90) = 460 kcal
- Salmón al horno con quinoa: salmón 150g (280) + quinoa 80g (120) + espárragos (40) + aceite (90) = 530 kcal
- Pasta integral con salsa de tomate y atún: pasta 80g (280) + atún (150) + tomate (40) + aceite (90) = 560 kcal
- Lentejas con verduras: lentejas (230) + arroz (100) + verduras (60) + aceite (90) = 480 kcal

SNACK (~${(distribution.snack.min + distribution.snack.max) ~/ 2} kcal):
- Manzana con almendras: manzana (80) + almendras 25g (140) = 220 kcal
- Yogur natural con nueces: yogur (100) + nueces 20g (130) = 230 kcal
- Hummus con palitos de zanahoria: hummus 50g (150) + zanahoria (30) = 180 kcal
- Batido de proteína con plátano: proteína (120) + plátano (90) + leche (60) = 270 kcal

DINNER (~${(distribution.dinner.min + distribution.dinner.max) ~/ 2} kcal):
- Merluza al horno con patata: merluza 150g (120) + patata 150g (120) + verduras (60) + aceite (90) = 390 kcal
- Pechuga de pavo con boniato: pavo 150g (160) + boniato 150g (130) + ensalada (40) + aceite (90) = 420 kcal
- Sopa de verduras con pollo: pollo 100g (120) + verduras (80) + fideos (100) + aceite (90) = 390 kcal
- Tortilla de 2 huevos con ensalada: huevos (140) + patata 100g (80) + ensalada (40) + aceite (90) = 350 kcal

VALIDACIÓN FINAL

Antes de devolver el JSON, verifica:
- recipes tiene exactamente 28 elementos ÚNICOS Y ORIGINALES
- recipes[0-6] todos tienen mealType="breakfast" con calories REALISTAS dentro del rango ${distribution.breakfast.min}-${distribution.breakfast.max}
- recipes[7-13] todos tienen mealType="lunch" con calories REALISTAS dentro del rango ${distribution.lunch.min}-${distribution.lunch.max}
- recipes[14-20] todos tienen mealType="snack" con calories REALISTAS dentro del rango ${distribution.snack.min}-${distribution.snack.max}
- recipes[21-27] todos tienen mealType="dinner" con calories REALISTAS dentro del rango ${distribution.dinner.min}-${distribution.dinner.max}
- Los ingredientes incluyen CANTIDADES cuando sea relevante
- Las calorías son COHERENTES con los ingredientes listados
- Cada día en weeklyMenu tiene 4 índices distintos correctamente asignados
- El JSON es válido y NO contiene comentarios

Genera el menú semanal ahora:
''';

    Exception? lastError;

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        if (kDebugMode && attempt > 0) {
          debugPrint('[GroqMenu] Reintento #$attempt de generación...');
        }

        final response = await http.post(
          Uri.parse(_backendUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'prompt': prompt}),
        );

        if (response.statusCode != 200) {
          throw Exception("Error del servidor: ${response.statusCode}");
        }

        final data = json.decode(response.body);

        // NUEVO: Verificar si hay error en la respuesta del worker
        if (data.containsKey('error')) {
          final errorMsg = data['error'];
          if (kDebugMode) {
            debugPrint('[GroqMenu] ERROR del worker: $errorMsg');
            debugPrint('[GroqMenu] Respuesta completa: ${response.body}');
          }
          throw Exception("Error del worker de Cloudflare: $errorMsg");
        }

        final content =
            data['choices']?[0]?['message']?['content'] ??
            data['content'] ??
            response.body;

        String clean = content.trim();
        final start = clean.indexOf('{');
        final end = clean.lastIndexOf('}') + 1;

        if (start == -1 || end <= start) {
          throw Exception(
            "Respuesta inválida del modelo - no se encontró JSON válido",
          );
        }

        final jsonStr = clean.substring(start, end);
        final decoded = json.decode(jsonStr);

        if (decoded is! Map) {
          throw Exception("El JSON decodificado no es un Map");
        }

        final result = Map<String, dynamic>.from(decoded);

        // Validación con logging detallado
        if (!result.containsKey('recipes')) {
          if (kDebugMode) {
            debugPrint('[GroqMenu] ERROR: Respuesta no contiene "recipes"');
            debugPrint(
              '[GroqMenu] Claves encontradas: ${result.keys.join(', ')}',
            );
          }
          throw Exception("El JSON no contiene 'recipes'");
        }

        if (!result.containsKey('weeklyMenu')) {
          if (kDebugMode) {
            debugPrint('[GroqMenu] ERROR: Respuesta no contiene "weeklyMenu"');
            debugPrint(
              '[GroqMenu] Claves encontradas: ${result.keys.join(', ')}',
            );
          }
          throw Exception("El JSON no contiene 'weeklyMenu'");
        }

        // Validación adicional de estructura
        if (result['recipes'] is! List) {
          throw Exception("'recipes' no es una lista");
        }

        if (result['weeklyMenu'] is! Map) {
          throw Exception("'weeklyMenu' no es un mapa");
        }

        // Si llegamos aquí, la respuesta es válida
        if (kDebugMode && attempt > 0) {
          debugPrint('[GroqMenu] ✓ Generación exitosa en intento #$attempt');
        }

        return AiMenuResponseModel.fromJson(result);
      } catch (e) {
        lastError = Exception('Error en intento #$attempt: $e');

        if (kDebugMode) {
          debugPrint('[GroqMenu] ${lastError.toString()}');
        }

        // Si no es el último intento, esperamos antes de reintentar
        if (attempt < _maxRetries - 1) {
          await Future.delayed(_retryDelay);
        }
      }
    }

    // Si agotamos todos los reintentos, lanzamos el último error
    throw lastError ?? Exception('Error desconocido generando menú con Groq');
  }
}
//TODO: no se usa