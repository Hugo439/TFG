import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/presentation/features/menu/widgets/meal_type_icon.dart';

class RecipeListTile extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeListTile({Key? key, required this.recipe, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(recipe.mealType.icon, color: colorScheme.primary),
      title: Text(recipe.name.value, style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${recipe.calories} kcal', style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6))),
          if (recipe.description.value.isNotEmpty)
            Text(recipe.description.value, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.7))),
          if (recipe.ingredients.isNotEmpty)
            Text('Ingredientes: ${recipe.ingredients.join(', ')}', style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.7))),
        ],
      ),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.4)),
      onTap: onTap,
    );
  }
}