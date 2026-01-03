import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/day_menu.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/presentation/features/menu/widgets/recipe_list_tile.dart';
import 'package:smartmeal/presentation/features/menu/utils/day_of_week_utils.dart';

class DayMenuCard extends StatefulWidget {
  final DayMenu day;
  final void Function(String recipeId)? onRecipeTap;

  const DayMenuCard({super.key, required this.day, this.onRecipeTap});

  @override
  State<DayMenuCard> createState() => _DayMenuCardState();
}

class _DayMenuCardState extends State<DayMenuCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header del día
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Icono del día con inicial
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _getDayInitial(widget.day.day),
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Información del día
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayOfWeekToString(widget.day.day),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.day.totalCalories} kcal',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.restaurant,
                                size: 16,
                                color: colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.day.recipes.length} comidas',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Icono de expandir/colapsar
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lista de recetas (solo visible cuando está expandido)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: widget.day.recipes.map((recipe) {
                  return RecipeListTile(
                    recipe: recipe,
                    onTap: widget.onRecipeTap != null
                        ? () => widget.onRecipeTap!(recipe.id)
                        : null,
                  );
                }).toList(),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  String _getDayInitial(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday: return 'L'; // Lunes
      case DayOfWeek.tuesday: return 'M'; // Martes
      case DayOfWeek.wednesday: return 'X'; // Miércoles
      case DayOfWeek.thursday: return 'J'; // Jueves
      case DayOfWeek.friday: return 'V'; // Viernes
      case DayOfWeek.saturday: return 'S'; // Sábado
      case DayOfWeek.sunday: return 'D'; // Domingo
      default: return '?';
    }
  }
}
