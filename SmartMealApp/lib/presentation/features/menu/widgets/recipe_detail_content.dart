import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class RecipeDetailContent extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailContent({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_fire_department, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '${recipe.calories} kcal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.recipeDescription,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          recipe.description.value,
          style: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.recipeIngredients,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          recipe.ingredients.join(', '),
          style: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}