import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/presentation/features/menu/viewmodel/recipe_detail_view_model.dart';
import 'package:smartmeal/presentation/widgets/layout/smart_meal_app_bar.dart';
import 'package:smartmeal/presentation/features/menu/widgets/recipe_detail_content.dart';

class RecipeDetailView extends StatelessWidget {
  final String recipeId;
  const RecipeDetailView({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<RecipeDetailViewModel>(context);

    if (vm.recipe == null) {
      vm.loadRecipe(recipeId);
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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