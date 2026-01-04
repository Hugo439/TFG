import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/presentation/features/menu/widgets/day_menu_card.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Widget que muestra el calendario semanal de menús.
///
/// Responsabilidades:
/// - Mostrar 7 días de menús en formato calendario
/// - Header decorativo con gradiente
/// - DayMenuCard por cada día de la semana
/// - Navegación a detalle de recetas
///
/// Estructura visual:
/// 1. **Header decorativo**:
///    - Gradiente: primaryContainer → secondaryContainer
///    - Icono restaurant_menu en contenedor circular
///    - Título: "Menú Semanal"
///    - Subtítulo: "7 días de comidas planificadas"
///    - Sombra suave para profundidad
///
/// 2. **Lista de días**:
///    - 7 DayMenuCard (lunes a domingo)
///    - Espaciado 16px entre cards
///    - Cada card muestra:
///      * Nombre del día
///      * 4 comidas (breakfast, lunch, snack, dinner)
///      * Tap en receta → callback onRecipeTap
///
/// Interacción:
/// - onRecipeTap(recipeId) al tocar cualquier receta
/// - Normalmente navega a RecipeDetailView
/// - DayMenuCard maneja el layout de cada día
///
/// Localización:
/// - Títulos y subtítulos traducidos
/// - Nombres de días en DayMenuCard localizados
///
/// Parámetros:
/// [menu] - WeeklyMenu con 7 días de recetas
/// [onRecipeTap] - Callback al tocar una receta (opcional)
///
/// Uso:
/// ```dart
/// WeeklyMenuCalendar(
///   menu: weeklyMenu,
///   onRecipeTap: (recipeId) {
///     Navigator.push(
///       context,
///       MaterialPageRoute(
///         builder: (_) => RecipeDetailView(recipeId: recipeId),
///       ),
///     );
///   },
/// )
/// ```
class WeeklyMenuCalendar extends StatelessWidget {
  final WeeklyMenu menu;
  final void Function(String recipeId)? onRecipeTap;

  const WeeklyMenuCalendar({super.key, required this.menu, this.onRecipeTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header atractivo para el calendario semanal
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.menuWeeklyTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.menuWeeklySubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Estadísticas rápidas
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${menu.totalWeeklyCalories} kcal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.menuTotalWeek,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Lista de días
        ...menu.days.map(
          (day) => DayMenuCard(day: day, onRecipeTap: onRecipeTap),
        ),
      ],
    );
  }
}
