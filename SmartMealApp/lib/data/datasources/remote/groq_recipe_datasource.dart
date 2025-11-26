import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqRecipeDataSource {
  static const String _backendUrl = 'https://groq-worker.smartmealgroq.workers.dev';

  GroqRecipeDataSource();

  Future<List<Map<String, dynamic>>> generateRecipes({
    required String mealType,
    required int targetCaloriesPerMeal,
    required List<String> excludedTags,
    required String userGoal,
    int count = 7,
  }) async {
    final mealTypeSpanish = _getMealTypeInSpanish(mealType);
    final allergiesText = excludedTags.isEmpty
        ? 'Sin restricciones'
        : 'EVITAR: ${excludedTags.join(', ')}';

    final prompt = '''
  Eres un nutricionista experto. Genera $count recetas COMPLETAMENTE DIFERENTES de $mealTypeSpanish para una semana.

  REQUISITOS DEL USUARIO:
  - Objetivo: $userGoal
  - Calorías por comida: aproximadamente $targetCaloriesPerMeal kcal
  - Restricciones alimentarias: $allergiesText

  REGLAS IMPORTANTES:
  1. Cada receta debe ser ÚNICA y DIFERENTE
  2. Usa ingredientes variados
  3. Recetas saludables y equilibradas
  4. Instrucciones claras y simples
  5. NO incluir ingredientes de las restricciones

  Devuelve SOLO un array JSON válido (sin texto adicional, sin markdown):

  [
    {
      "name": "Nombre de la receta",
      "description": "Descripción corta",
      "ingredients": ["ingrediente 1", "ingrediente 2", "ingrediente 3"],
      "calories": 400,
      "mealType": "$mealType"
    }
  ]

  Genera las $count recetas ahora:
  ''';

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'prompt': prompt,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Si tu backend devuelve igual que Groq, extrae el texto generado:
        final content = data['choices']?[0]?['message']?['content'] ?? data['content'] ?? response.body;

        // Limpiar y extraer JSON
        String cleanJson = content.trim();

        // Extraer solo el array JSON
        final jsonStart = cleanJson.indexOf('[');
        final jsonEnd = cleanJson.lastIndexOf(']') + 1;

        if (jsonStart != -1 && jsonEnd > jsonStart) {
          cleanJson = cleanJson.substring(jsonStart, jsonEnd);
        }

        // Parsear JSON
        final dynamic decoded = json.decode(cleanJson);

        if (decoded is List) {
          return List<Map<String, dynamic>>.from(
            decoded.map((item) => Map<String, dynamic>.from(item as Map))
          );
        }
      }

      return [];
    } catch (e) {
      throw Exception('Error generando recetas con Groq: $e');
    }
  }

  String _getMealTypeInSpanish(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'desayuno';
      case 'lunch':
        return 'comida';
      case 'dinner':
        return 'cena';
      case 'snack':
        return 'snack/merienda';
      default:
        return mealType;
    }
  }
}