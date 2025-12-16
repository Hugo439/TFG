import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/domain/entities/recipe.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';
import 'package:smartmeal/presentation/features/menu/widgets/meal_type_icon.dart';
import 'package:smartmeal/presentation/features/menu/widgets/meal_type_text.dart';
import 'package:smartmeal/presentation/features/menu/viewmodel/recipe_detail_view_model.dart';

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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.12),
                colorScheme.primary.withOpacity(0.06),
              ],
            ),
            border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  recipe.mealType.icon,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.mealType.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
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
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restaurant_menu, color: colorScheme.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${recipe.ingredients.length} ${l10n.recipeIngredients}',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.recipeDescription,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            recipe.description.value,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: colorScheme.onSurface.withOpacity(0.85),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.recipeIngredients,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...recipe.ingredients.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildStepsSection(context, colorScheme),
      ],
    );
  }

  Widget _buildStepsSection(BuildContext context, ColorScheme colorScheme) {
    final vm = context.watch<RecipeDetailViewModel>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pasos de preparación',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.primary,
              ),
            ),
            const Spacer(),
            if (recipe.steps.isEmpty && !vm.isGeneratingSteps)
              TextButton.icon(
                onPressed: vm.generateSteps,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Generar'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (vm.isGeneratingSteps)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Generando pasos con IA...',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          )
        else if (recipe.steps.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary.withOpacity(0.6)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pulsa "Generar" para crear los pasos de preparación con IA',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...recipe.steps.map(
            (step) {
              final index = recipe.steps.indexOf(step);
              final cleanStep = step.replaceAll(RegExp(r'^\d+\.\s*'), '');
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.08)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: colorScheme.primary.withOpacity(0.15),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cleanStep,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: colorScheme.onSurface.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        if (vm.stepsError != null)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Error: ${vm.stepsError}',
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
