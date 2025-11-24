import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/presentation/features/menu/viewmodel/menu_view_model.dart';
import 'package:smartmeal/presentation/features/menu/widgets/weekly_menu_card.dart';
import 'package:smartmeal/core/di/service_locator.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MenuViewModel>(
      create: (_) => sl<MenuViewModel>(),
      child: const _MenuContent(),
    );
  }
}

class _MenuContent extends StatelessWidget {
  const _MenuContent();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MenuViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final user = Provider.of<User?>(context);
    // final userId = user?.uid ?? '';
    // print('UserId en MenuView: $userId');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Menús Semanales'),
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          if (vm.state == MenuState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.state == MenuState.error) {
            return Center(
              child: Text(
                vm.errorMessage ?? 'Error al cargar menús',
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }
          if (vm.menus.isEmpty) {
            return Center(
              child: Text(
                'No tienes menús generados aún.',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vm.menus.length,
            itemBuilder: (context, index) {
              final menu = vm.menus[index];
              return WeeklyMenuCard(menu: menu);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/generate-menu').then((result) {
            if (!context.mounted) return;
            final userId = user?.uid ?? '';
            if (result == true && userId.isNotEmpty) {
              vm.loadWeeklyMenus(userId);
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}