import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/presentation/features/menu/widgets/day_menu_card.dart';

class WeeklyMenuCalendar extends StatelessWidget {
  final WeeklyMenu menu;
  final void Function(String recipeId)? onRecipeTap;

  const WeeklyMenuCalendar({super.key, required this.menu, this.onRecipeTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tu menú semanal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...menu.days.map((day) => DayMenuCard(day: day, onRecipeTap: onRecipeTap)).toList(),
      ],
    );
  }
}