import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/presentation/routes/navigation_controller.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';
import 'package:smartmeal/presentation/features/statistics/widgets/macros_chart.dart';
import 'package:smartmeal/presentation/features/statistics/widgets/metric_card.dart';
import 'package:smartmeal/presentation/features/statistics/widgets/goal_status_card.dart';
import 'package:smartmeal/presentation/features/statistics/viewmodel/statistics_view_model.dart';
import 'package:smartmeal/presentation/theme/colors.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StatisticsViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final body = vm.loading
      ? const Center(child: CircularProgressIndicator())
      : vm.error != null
        ? Center(child: Text(vm.error!))
        : vm.summary == null
          ? const Center(child: Text('No hay datos de estadísticas'))
          : _buildContent(
            context,
            vm,
            theme,
            subtitle: context.l10n.homeCardStatsSubtitle,
            );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.homeCardStatsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationController.navigateToHome(context),
        ),
      ),
      backgroundColor: colorScheme.surface,
      body: SafeArea(child: body),
    );
  }

  Widget _buildContent(
    BuildContext context,
    StatisticsViewModel vm,
    ThemeData theme, {
    required String subtitle,
  }) {
    final s = vm.summary!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          // Grid de métricas principales
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: MetricCard(
                    icon: Icons.local_fire_department,
                    title: 'Media diaria',
                    value: s.avgDailyCalories.toStringAsFixed(0),
                    unit: 'kcal',
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkStatProtein
                        : AppColors.statProtein,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    icon: Icons.restaurant,
                    title: 'Recetas únicas',
                    value: '${s.uniqueRecipesCount}',
                    unit: 'recetas',
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkStatCarbs
                        : AppColors.statCarbs,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: MetricCard(
                    icon: Icons.calendar_today,
                    title: 'Total semanal',
                    value: '${s.totalWeeklyCalories}',
                    unit: 'kcal',
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkStatFats
                        : AppColors.statFats,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    icon: Icons.euro,
                    title: 'Coste estimado',
                    value: s.estimatedCost.toStringAsFixed(2),
                    unit: '€',
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkStatCost
                        : AppColors.statCost,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Comparación con objetivo calórico
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GoalStatusCard(
              avgDaily: s.avgDailyCalories,
              target: vm.targetCalories,
              percent: vm.compliancePercent,
              status: vm.complianceStatus,
            ),
          ),
          const SizedBox(height: 24),

          // Distribución de macros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Distribución de macros',
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  MacrosChart(
                    proteinG: s.totalProteinG,
                    carbsG: s.totalCarbsG,
                    fatG: s.totalFatG,
                    proteinColor: theme.brightness == Brightness.dark
                        ? AppColors.darkStatProtein
                        : AppColors.statProtein,
                    carbsColor: theme.brightness == Brightness.dark
                        ? AppColors.darkStatCarbs
                        : AppColors.statCarbs,
                    fatColor: theme.brightness == Brightness.dark
                        ? AppColors.darkStatFats
                        : AppColors.statFats,
                    size: 140,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MacroRow(
                          label: 'Proteína',
                          value: '${s.totalProteinG.toStringAsFixed(0)}g',
                          color: theme.brightness == Brightness.dark
                              ? AppColors.darkStatProtein
                              : AppColors.statProtein,
                          avgDaily: s.avgDailyProteinG,
                        ),
                        const SizedBox(height: 12),
                        _MacroRow(
                          label: 'Carbos',
                          value: '${s.totalCarbsG.toStringAsFixed(0)}g',
                          color: theme.brightness == Brightness.dark
                              ? AppColors.darkStatCarbs
                              : AppColors.statCarbs,
                          avgDaily: s.avgDailyCarbsG,
                        ),
                        const SizedBox(height: 12),
                        _MacroRow(
                          label: 'Grasas',
                          value: '${s.totalFatG.toStringAsFixed(0)}g',
                          color: theme.brightness == Brightness.dark
                              ? AppColors.darkStatFats
                              : AppColors.statFats,
                          avgDaily: s.avgDailyFatG,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Top recetas
          if (s.topRecipes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recetas favoritas',
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: s.topRecipes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final recipe = s.topRecipes[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${recipe.count}x',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // Top ingredientes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Ingredientes más usados',
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: s.topIngredients
                  .map(
                    (i) => Chip(
                      avatar: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          '${i.count}',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      label: Text(i.name),
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.08,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double avgDaily;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.color,
    required this.avgDaily,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            '${avgDaily.toStringAsFixed(1)}g/día',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
