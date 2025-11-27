import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqMenuDatasource {
  static const String _backendUrl = 'https://groq-worker.smartmealgroq.workers.dev';

  GroqMenuDatasource();

  /// Genera recetas + menú semanal completo (JSON con:
  /// { "recipes": [...], "weeklyMenu": {...} })
  Future<Map<String, dynamic>> generateWeeklyMenu({
    required int targetCaloriesPerMeal,
    required List<String> excludedTags,
    required String userGoal,
    int recipesCount = 28, // 7 días × 4 comidas
  }) async {
    final allergiesText = excludedTags.isEmpty
        ? 'Sin restricciones'
        : 'EVITAR: ${excludedTags.join(', ')}';

    final prompt = '''
Eres un nutricionista experto. Debes generar un menú semanal COMPLETO para un usuario.

DATOS DEL USUARIO:
- Objetivo: $userGoal
- Calorías por comida: aproximadamente $targetCaloriesPerMeal kcal
- Restricciones alimentarias: $allergiesText

REGLAS IMPORTANTES:
1. Debes generar exactamente $recipesCount recetas diferentes.
2. Todas las recetas deben ser saludables y sin ingredientes restringidos.
3. Cada receta debe tener: name, description, ingredients[], calories, mealType.
4. Debes generar un menú semanal donde cada día tenga:
   - breakfast
   - lunch
   - snack
   - dinner
5. El menú semanal NO debe repetir recetas dentro del mismo día.
6. En el menú semanal, cada comida debe ser un ÍNDICE NUMÉRICO que apunte a la receta correspondiente en el array recipes[].

DEVUELVE SOLO UN JSON VÁLIDO con esta estructura exacta:

{
  "recipes": [
    {
      "name": "string",
      "description": "string",
      "ingredients": ["string", "string"],
      "calories": 450,
      "mealType": "breakfast"
    }
  ],
  "weeklyMenu": {
    "lunes": {
      "breakfast": 0,
      "lunch": 3,
      "snack": 5,
      "dinner": 6
    }
  }
}

Genera ahora "recipes" y "weeklyMenu":
''';

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': prompt}),
      );

      if (response.statusCode != 200) {
        throw Exception("Error del servidor: ${response.statusCode}");
      }

      final data = json.decode(response.body);

      final content = data['choices']?[0]?['message']?['content']
          ?? data['content']
          ?? response.body;

      String clean = content.trim();
      final start = clean.indexOf('{');
      final end = clean.lastIndexOf('}') + 1;

      if (start == -1 || end <= start) {
          throw Exception("Respuesta inválida del modelo.");
      }

      final jsonStr = clean.substring(start, end);
      final decoded = json.decode(jsonStr);

      if (decoded is! Map) {
        throw Exception("El JSON decodificado no es un Map.");
      }

      final result = Map<String, dynamic>.from(decoded);

      if (!result.containsKey('recipes') || !result.containsKey('weeklyMenu')) {
        throw Exception("El JSON no contiene recipes + weeklyMenu.");
      }

      return result;

    } catch (e) {
      throw Exception('Error generando menú semanal con Groq: $e');
    }
  }
}
