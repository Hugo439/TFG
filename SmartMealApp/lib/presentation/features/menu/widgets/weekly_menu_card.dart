import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/weekly_menu.dart';
import 'package:smartmeal/domain/entities/recipe.dart';

class WeeklyMenuCard extends StatelessWidget {
  final WeeklyMenu menu;

  const WeeklyMenuCard({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.surfaceVariant,
      child: ExpansionTile(
        title: Text(
          'Semana: ${menu.weekStartDate.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Calorías totales: ${menu.totalWeeklyCalories}'),
        children: menu.days.map((dayMenu) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ExpansionTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                '${_dayOfWeekToString(dayMenu.day)} - ${dayMenu.totalCalories} kcal',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              children: dayMenu.allRecipes.map((recipe) {
                return ListTile(
                  leading: Icon(_mealTypeIcon(recipe.mealType), color: colorScheme.primary),
                  title: Text(recipe.nameValue),
                  subtitle: Text('${_mealTypeToString(recipe.mealType)} - ${recipe.calories} kcal'),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _dayOfWeekToString(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday: return 'Lunes';
      case DayOfWeek.tuesday: return 'Martes';
      case DayOfWeek.wednesday: return 'Miércoles';
      case DayOfWeek.thursday: return 'Jueves';
      case DayOfWeek.friday: return 'Viernes';
      case DayOfWeek.saturday: return 'Sábado';
      case DayOfWeek.sunday: return 'Domingo';
    }
  }

  String _mealTypeToString(MealType type) {
    switch (type) {
      case MealType.breakfast: return 'Desayuno';
      case MealType.lunch: return 'Comida';
      case MealType.dinner: return 'Cena';
      case MealType.snack: return 'Snack';
      default: return '';
    }
  }

  IconData _mealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast: return Icons.free_breakfast;
      case MealType.lunch: return Icons.lunch_dining;
      case MealType.dinner: return Icons.dinner_dining;
      case MealType.snack: return Icons.fastfood;
      default: return Icons.restaurant;
    }
  }
}