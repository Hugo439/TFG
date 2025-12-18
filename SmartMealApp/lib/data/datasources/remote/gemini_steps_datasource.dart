import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GeminiStepsDatasource {
  static const String _workerUrl =
      'https://groq-worker.smartmealgroq.workers.dev/gemini';

  Future<List<String>> generateRecipeSteps({
    required String recipeName,
    required List<String> ingredients,
    required String description,
  }) async {
    final prompt =
        '''
Eres un chef experto. Genera los pasos de preparación para esta receta:

NOMBRE: $recipeName
DESCRIPCIÓN: $description
INGREDIENTES: ${ingredients.join(', ')}

INSTRUCCIONES:
- Genera entre 5 y 8 pasos claros y concisos
- Cada paso debe ser específico y accionable
- Numera cada paso (1., 2., etc.)
- Usa lenguaje directo e imperativo

Responde ÚNICAMENTE con un JSON en este formato (sin markdown):
{
  "steps": [
    "Paso 1 aquí",
    "Paso 2 aquí",
    ...
  ]
}
''';

    try {
      final response = await http.post(
        Uri.parse(_workerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': prompt}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error del servidor: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      if (data.containsKey('error')) {
        throw Exception('Error del worker: ${data['error']}');
      }

      final content = data['content'];
      if (content == null) {
        throw Exception('Respuesta vacía del worker');
      }

      // Limpiar markdown
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

      // Extraer JSON
      final start = cleanText.indexOf('{');
      final end = cleanText.lastIndexOf('}') + 1;

      if (start == -1 || end <= start) {
        throw Exception('No se encontró JSON válido en la respuesta');
      }

      final jsonStr = cleanText.substring(start, end);
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;

      if (!decoded.containsKey('steps')) {
        throw Exception("Falta 'steps' en el JSON");
      }

      return List<String>.from(decoded['steps'] as List);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GeminiSteps] Error: $e');
      }
      throw Exception('Error generando pasos: $e');
    }
  }
}
