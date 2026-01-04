import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/repositories/menu_generation_repository.dart';

/// UseCase para generar pasos de preparación de receta usando IA.
///
/// Responsabilidad:
/// - Llamar a Gemini/Groq API para generar pasos detallados
/// - Formatear pasos como lista de strings
///
/// Entrada:
/// - GenerateRecipeStepsParams:
///   - recipeName: nombre de la receta
///   - ingredients: lista de ingredientes
///   - description: descripción breve de la receta
///
/// Salida:
/// - List<String> con pasos de preparación ordenados
///
/// Uso típico:
/// ```dart
/// final steps = await generateStepsUseCase(GenerateRecipeStepsParams(
///   recipeName: 'Pollo al horno con verduras',
///   ingredients: ['500g pollo', '2 pimientos', '1 cebolla', 'aceite'],
///   description: 'Pollo asado con verduras al horno',
/// ));
///
/// for (int i = 0; i < steps.length; i++) {
///   print('${i + 1}. ${steps[i]}');
/// }
/// ```
///
/// Formato de salida (ejemplo):
/// ```
/// [
///   "Precalentar el horno a 200°C",
///   "Cortar el pollo en trozos y sazonar con sal y pimienta",
///   "Picar las verduras en trozos medianos",
///   "Colocar todo en una bandeja con aceite",
///   "Hornear durante 45 minutos hasta que esté dorado",
/// ]
/// ```
///
/// Nota: Usa modelo de IA para generar pasos realistas y coherentes.
class GenerateRecipeStepsUseCase
    implements UseCase<List<String>, GenerateRecipeStepsParams> {
  final MenuGenerationRepository repository;

  GenerateRecipeStepsUseCase(this.repository);

  @override
  Future<List<String>> call(GenerateRecipeStepsParams params) async {
    return await repository.generateRecipeSteps(
      recipeName: params.recipeName,
      ingredients: params.ingredients,
      description: params.description,
    );
  }
}

/// Parámetros para generar pasos de receta con IA.
class GenerateRecipeStepsParams {
  final String recipeName;
  final List<String> ingredients;
  final String description;

  GenerateRecipeStepsParams({
    required this.recipeName,
    required this.ingredients,
    required this.description,
  });
}
