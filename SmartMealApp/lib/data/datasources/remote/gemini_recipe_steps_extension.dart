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
    final prompt =
        '''
Eres un chef experto. Para la siguiente receta, genera pasos de preparación DETALLADOS, ESPECÍFICOS y PROFESIONALES.

RECETA:
- Nombre: $recipeName
- Descripción: $description
- Ingredientes: ${ingredients.join(', ')}

INSTRUCCIONES PARA PASOS DETALLADOS:
1. Incluye TÉCNICAS culinarias específicas (saltear, hornear, pochar, emulsionar, etc.)
2. Especifica TEMPERATURAS exactas (cuando sea relevante)
3. Incluye TIEMPOS aproximados pero realistas
4. Detalla PUNTOS CRÍTICOS (cuándo está "listo", señales visuales, textura esperada)
5. Añade TIPS profesionales para mejorar el resultado
6. Cada paso debe ser ACCIONABLE y CLARO

ESTRUCTURA DE CADA PASO:
- Acción principal + cómo hacerlo + qué esperar + señal de finalización

EJEMPLOS:
✓ "Precalentar horno a 200°C durante 10 minutos. Debe estar bien caliente para sellar la carne."
✓ "Saltear la cebolla en aceite a fuego medio-alto hasta que esté dorada y fragante (5-7 minutos). Debe estar transparente pero con bordes ligeramente caramelizados."
✓ "Mezclar ingredientes secos con movimientos envolventes hasta que la harina se distribuya uniformemente. No sobremezcles o la masa quedará dura."

FORMATO DE SALIDA:
Responde ÚNICAMENTE con un JSON array de strings, sin markdown:

["Paso 1 detallado...", "Paso 2 detallado...", ...]

- 6-8 pasos totales
- Máximo 2 líneas por paso (manteniendo detalle)
- Sin numeración (la app los enumera)
- Solo JSON puro
''';

    const maxRetries = 2;
    const workerUrl = 'https://groq-worker.smartmealgroq.workers.dev/gemini';

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(workerUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'prompt': prompt}),
        );

        if (response.statusCode != 200) {
          if (kDebugMode) {
            debugPrint(
              '[GeminiSteps] Error ${response.statusCode}: ${response.body}',
            );
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
        if (content.endsWith('```')) {
          content = content.substring(0, content.length - 3);
        }
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
