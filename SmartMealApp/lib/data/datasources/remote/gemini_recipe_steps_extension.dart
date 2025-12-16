import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:smartmeal/data/datasources/remote/gemini_menu_datasource.dart';

extension GeminiRecipeStepsExtension on GeminiMenuDatasource {
  Future<List<String>> generateRecipeSteps({
    required String recipeName,
    required List<String> ingredients,
    required String description,
  }) async {
    final prompt = '''
Eres un chef profesional. Para la siguiente receta, genera 5-8 pasos claros y concisos de preparación.

RECETA:
- Nombre: $recipeName
- Descripción: $description
- Ingredientes: ${ingredients.join(', ')}

FORMATO DE SALIDA:
Responde ÚNICAMENTE con un JSON array de strings, cada string es un paso numerado:

["1. Precalentar el horno a 180°C", "2. Picar las verduras...", ...]

Reglas:
- Pasos claros y numerados
- Orden lógico de preparación
- Máximo 8 pasos
- Sin markdown, solo JSON puro
''';

    const maxRetries = 2;
    const workerUrl = 'https://groq-worker.smartmealgroq.workers.dev';

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(workerUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'prompt': prompt}),
        );

        if (response.statusCode != 200) {
          if (kDebugMode) {
            debugPrint('[GeminiSteps] Error ${response.statusCode}: ${response.body}');
          }
          throw Exception('Error del servidor: ${response.statusCode}');
        }

        final data = json.decode(response.body);
        if (data.containsKey('error')) {
          throw Exception('Error del worker: ${data['error']}');
        }

        String content = (data['content'] as String? ?? '').trim();
        
        // Limpiar markdown
        if (content.startsWith('```json')) content = content.substring(7);
        if (content.startsWith('```')) content = content.substring(3);
        if (content.endsWith('```')) content = content.substring(0, content.length - 3);
        content = content.trim();

        // Buscar JSON array
        final startIdx = content.indexOf('[');
        final endIdx = content.lastIndexOf(']');
        
        if (startIdx == -1 || endIdx == -1 || endIdx <= startIdx) {
          throw Exception('No se encontró JSON array válido');
        }

        final jsonStr = content.substring(startIdx, endIdx + 1);
        final decoded = json.decode(jsonStr);

        if (decoded is! List) {
          throw Exception('La respuesta no es un array');
        }

        final steps = decoded.map((e) => e.toString()).toList();
        
        if (steps.isEmpty) {
          throw Exception('No se generaron pasos');
        }

        return steps;

      } catch (e) {
        if (kDebugMode) {
          debugPrint('[GeminiSteps] Intento #$attempt falló: $e');
        }
        
        if (attempt >= maxRetries) {
          // Fallback: pasos genéricos
          return [
            '1. Preparar todos los ingredientes necesarios',
            '2. Seguir las instrucciones de preparación básicas',
            '3. Cocinar según el tipo de comida',
            '4. Servir y disfrutar',
          ];
        }
        
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    throw Exception('Error generando pasos de receta');
  }
}
