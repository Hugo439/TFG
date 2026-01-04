import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/presentation/features/menu/viewmodel/recipe_detail_view_model.dart';
import 'package:smartmeal/presentation/widgets/layout/smart_meal_app_bar.dart';
import 'package:smartmeal/presentation/features/menu/widgets/recipe_detail_content.dart';

/// Pantalla de detalle de una receta del menú.
///
/// Responsabilidades:
/// - Mostrar información completa de la receta
/// - Cargar receta por ID desde Firestore
/// - Indicador de carga mientras obtiene datos
///
/// Información mostrada (RecipeDetailContent):
/// - **Header**: Nombre + tipo de comida (breakfast/lunch/snack/dinner)
/// - **Calorías**: Total de la receta
/// - **Ingredientes**: Lista con cantidades
/// - **Pasos de preparación**: Enumerados
/// - **Macronutrientes** (opcional): Proteínas, carbohidratos, grasas
///
/// Carga de datos:
/// - RecipeDetailViewModel.loadRecipe(recipeId)
/// - Obtiene de Firestore: users/{userId}/recipes/{recipeId}
/// - Muestra CircularProgressIndicator mientras carga
///
/// AppBar personalizado:
/// - SmartMealAppBar con título = nombre receta
/// - Subtítulo = tipo de comida
/// - Botón volver
///
/// Parámetros:
/// [recipeId] - ID de la receta a mostrar
///
/// Navegación:
/// - Llamada desde WeeklyMenuCalendar al tocar una receta
///
/// Uso:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => ChangeNotifierProvider.value(
///       value: sl<RecipeDetailViewModel>(),
///       child: RecipeDetailView(recipeId: 'user123_recipe_0'),
///     ),
///   ),
/// );
/// ```
class RecipeDetailView extends StatelessWidget {
  final String recipeId;
  const RecipeDetailView({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<RecipeDetailViewModel>(context);

    if (vm.recipe == null) {
      vm.loadRecipe(recipeId);
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final recipe = vm.recipe!;

    return Scaffold(
      appBar: SmartMealAppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: recipe.name.value,
        subtitle: recipe.mealType.name,
        centerTitle: false,
        showNotification: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: RecipeDetailContent(recipe: recipe),
        ),
      ),
    );
  }
}
