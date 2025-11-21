// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class AiDataSource {
//   static const String _apiKey = 'TU_API_KEY_AQUI'; // Cambiar por tu API key
//   static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

//   Future<List<Map<String, dynamic>>> generateMenus({
//     required String goal,
//     required List<String> allergies,
//   }) async {
//     final prompt = _buildPrompt(goal, allergies);
    
//     final response = await http.post(
//       Uri.parse(_baseUrl),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $_apiKey',
//       },
//       body: jsonEncode({
//         'model': 'gpt-3.5-turbo',
//         'messages': [
//           {
//             'role': 'system',
//             'content': 'Eres un nutricionista experto que crea menús saludables y personalizados.',
//           },
//           {
//             'role': 'user',
//             'content': prompt,
//           }
//         ],
//         'temperature': 0.7,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final content = data['choices'][0]['message']['content'];
//       return _parseMenusFromResponse(content);
//     } else {
//       throw Exception('Error al generar menús: ${response.statusCode}');
//     }
//   }

//   String _buildPrompt(String goal, List<String> allergies) {
//     final allergiesText = allergies.isEmpty 
//         ? 'sin alergias' 
//         : 'con alergias a: ${allergies.join(", ")}';
    
//     return '''
// Genera 21 menús para una semana completa (7 días):
// - 7 desayunos
// - 7 comidas
// - 7 cenas

// Objetivo del usuario: $goal
// Alergias: $allergiesText

// Para cada menú incluye:
// 1. Nombre del plato
// 2. Descripción breve
// 3. Lista de ingredientes con cantidades

// Formato de respuesta en JSON:
// [
//   {
//     "name": "Nombre del plato",
//     "description": "Descripción",
//     "mealType": "desayuno|comida|cena",
//     "day": 1-7,
//     "ingredients": ["ingrediente 1", "ingrediente 2", ...]
//   }
// ]
// ''';
//   }

//   List<Map<String, dynamic>> _parseMenusFromResponse(String content) {
//     // Intentar extraer JSON del contenido
//     final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(content);
//     if (jsonMatch != null) {
//       final jsonStr = jsonMatch.group(0)!;
//       final List<dynamic> menus = jsonDecode(jsonStr);
//       return menus.cast<Map<String, dynamic>>();
//     }
//     throw Exception('No se pudo parsear la respuesta de la IA');
//   }
// }