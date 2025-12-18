import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/day_menu.dart';
import 'package:smartmeal/presentation/features/menu/widgets/recipe_list_tile.dart';
import 'package:smartmeal/presentation/features/menu/utils/day_of_week_utils.dart';

class DayMenuCard extends StatelessWidget {
  final DayMenu day;
  final void Function(String recipeId)? onRecipeTap;

  const DayMenuCard({super.key, required this.day, this.onRecipeTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          dayOfWeekToString(day.day),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${day.totalCalories} kcal',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        children: day.recipes.map((recipe) {
          return RecipeListTile(
            recipe: recipe,
            onTap: onRecipeTap != null ? () => onRecipeTap!(recipe.id) : null,
          );
        }).toList(),
      ),
    );
  }
}
