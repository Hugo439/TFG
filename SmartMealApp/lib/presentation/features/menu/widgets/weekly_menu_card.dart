import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/presentation/features/menu/widgets/day_menu_card.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class WeeklyMenuCard extends StatelessWidget {
  final WeeklyMenu menu;
  final void Function(String recipeId)? onRecipeTap;

  const WeeklyMenuCard({super.key, required this.menu, this.onRecipeTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.surfaceContainerHighest,
      child: ExpansionTile(
        title: Text(
          'Semana: ${menu.weekStartDate.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${l10n.recipeTotalCalories}: ${menu.totalWeeklyCalories}',
        ),
        children: menu.days.map((dayMenu) {
          return DayMenuCard(day: dayMenu, onRecipeTap: onRecipeTap);
        }).toList(),
      ),
    );
  }
}
