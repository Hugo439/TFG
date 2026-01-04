import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/errors/errors.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

/// Datasource para generación de pasos de recetas usando Gemini API.
///
/// Responsabilidad:
/// - Generar pasos detallados de preparación usando IA
/// - Usado cuando AI no genera pasos o son insuficientes
///
/// Flujo:
/// 1. MenuGenerationRepository detecta receta sin pasos
/// 2. Llama a generateRecipeSteps()
/// 3. Envía prompt con nombre, ingredientes, descripción
/// 4. Gemini responde JSON con array de pasos
/// 5. Parsea y valida 5-8 pasos
///
/// Comunicación:
/// - URL: Cloudflare Worker (groq-worker.smartmealgroq.workers.dev/gemini)
/// - Método: POST con JSON {prompt: string}
/// - Respuesta: JSON con {content: string}
///
/// Formato esperado:
/// ```json
/// {
///   "steps": [
///     "Precalentar horno a 200°C",
///     "Mezclar ingredientes secos",
///     ...
///   ]
/// }
/// ```
///
/// Limpieza:
/// - Elimina markers markdown ```json y ```
/// - Extrae JSON entre { }
/// - Valida estructura con campo 'steps'
///
/// Uso:
/// ```dart
/// final ds = GeminiStepsDatasource();
/// final steps = await ds.generateRecipeSteps(
///   recipeName: 'Pollo al horno',
///   ingredients: ['pollo', 'especias', 'aceite'],
///   description: 'Jugoso pollo asado',
/// );
/// ```
class GeminiStepsDatasource {
  static const String _workerUrl = AppConstants.groqWorkerGeminiUrl;

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
        throw ServerFailure('Error del servidor: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      if (data.containsKey('error')) {
        throw ServerFailure('Error del worker: ${data['error']}');
      }

      final content = data['content'];
      if (content == null) {
        throw ServerFailure('Respuesta vacía del worker');
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
        throw ServerFailure('No se encontró JSON válido en la respuesta');
      }

      final jsonStr = cleanText.substring(start, end);
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;

      if (!decoded.containsKey('steps')) {
        throw ServerFailure("Falta 'steps' en el JSON");
      }

      return List<String>.from(decoded['steps'] as List);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GeminiSteps] Error: $e');
      }
      throw ServerFailure('Error generando pasos: $e');
    }
  }
}
