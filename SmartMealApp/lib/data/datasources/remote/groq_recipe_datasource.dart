import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqRecipeDataSource {
  final String _apiKey;
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  GroqRecipeDataSource({required String apiKey}) : _apiKey = apiKey;

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
    "steps": ["Paso 1", "Paso 2", "Paso 3"],
    "calories": 400,
    "protein": 25,
    "carbs": 45,
    "fats": 12,
    "prepTimeMinutes": 20,
    "tags": []
  }
]

Genera las $count recetas ahora:
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': 'Eres un nutricionista profesional que crea recetas saludables. Siempre respondes con JSON válido.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.7,
          'max_tokens': 4000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        
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
      // Puedes lanzar la excepción para manejarla en la UI si lo deseas
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