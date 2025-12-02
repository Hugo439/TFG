import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/usecases/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/get_current_user_usecase.dart';
import 'package:smartmeal/domain/usecases/save_menu_recipes_usecase.dart';
import 'package:smartmeal/presentation/features/menu/viewmodel/generate_menu_view_model.dart';
import 'package:smartmeal/presentation/features/menu/widgets/weekly_menu_calendar.dart';
import 'package:smartmeal/domain/repositories/weekly_menu_repository.dart';

class GenerateMenuView extends StatelessWidget {
  const GenerateMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GenerateMenuViewModel(
        sl<GetUserProfileUseCase>(),
        sl<GetCurrentUserUseCase>(),
        sl<WeeklyMenuRepository>(),
        sl<SaveMenuRecipesUseCase>(),
      ),
      child: const _GenerateMenuContent(),
    );
  }
}

class _GenerateMenuContent extends StatelessWidget {
  const _GenerateMenuContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GenerateMenuViewModel>();
    final state = vm.state;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Generar Menú Semanal',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: state.status == GenerateMenuStatus.success && state.generatedMenu != null
          ? _buildSuccessView(context, vm)
          : _buildMainView(context, vm),
    );
  }

  Widget _buildMainView(BuildContext context, GenerateMenuViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = vm.state;
    final isLoading = state.status == GenerateMenuStatus.loading;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono grande
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 80,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),

            // Título
            Text(
              'Generación Inteligente de Menús',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Descripción
            Text(
              'Crea un menú semanal personalizado basado en tu perfil, objetivos y restricciones alimentarias',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Beneficios
            _buildFeatureItem(
              context,
              Icons.restaurant_menu,
              '28 recetas únicas',
              'Desayuno, comida, cena y snack para cada día',
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              context,
              Icons.psychology,
              'Personalizado con IA',
              'Adaptado a tus objetivos nutricionales',
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              context,
              Icons.health_and_safety,
              'Respeta tus alergias',
              'Sin ingredientes que no puedas consumir',
            ),
            const SizedBox(height: 48),

            // Error message
            if (state.error != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Botón grande para generar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : vm.generateMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 2,
                  shadowColor: colorScheme.primary.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Generando menú...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Generar Mi Menú Semanal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Texto informativo
            if (isLoading)
              Text(
                'Esto puede tardar unos segundos...',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              )
            else
              Text(
                'El menú se generará automáticamente según tu perfil',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, GenerateMenuViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    final menu = vm.state.generatedMenu!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.1),
                        colorScheme.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Menú generado con éxito!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              menu.name,
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Estadísticas
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Calorías totales',
                        '${menu.totalWeeklyCalories} kcal',
                        Icons.local_fire_department,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Promedio diario',
                        '${menu.avgDailyCalories.toInt()} kcal',
                        Icons.trending_up,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Calendario semanal
                WeeklyMenuCalendar(menu: menu),
              ],
            ),
          ),
        ),

        // Botones de acción
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: colorScheme.primary),
                    ),
                    child: const Text('Descartar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Guardar el menú en Firestore antes de cerrar
                      try {
                        await vm.saveGeneratedMenu();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✓ Menú guardado correctamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop(true);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al guardar: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Guardar Menú'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}