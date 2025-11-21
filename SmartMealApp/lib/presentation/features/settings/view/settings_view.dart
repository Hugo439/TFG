import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/usecases/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/sign_out_usecase.dart';
import 'package:smartmeal/domain/usecases/delete_account_usecase.dart';
import 'package:smartmeal/presentation/features/settings/viewmodel/settings_view_model.dart';
import 'package:smartmeal/presentation/features/settings/widgets/settings_section.dart';
import 'package:smartmeal/presentation/features/settings/widgets/settings_tile.dart';
import 'package:smartmeal/presentation/features/settings/widgets/account_info_card.dart';
import 'package:smartmeal/presentation/theme/theme_provider.dart';
import 'package:smartmeal/presentation/routes/routes.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(
        sl<GetUserProfileUseCase>(),
        sl<SignOutUseCase>(),
        sl<DeleteAccountUseCase>(),
      )..loadProfile(),
      child: const _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final state = vm.state;
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Configuración',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: state.status == SettingsStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.profile != null)
                    AccountInfoCard(profile: state.profile!),
                  const SizedBox(height: 24),

                  SettingsSection(
                    title: 'Perfil',
                    children: [
                      SettingsTile(
                        icon: Icons.person_outline,
                        title: 'Mi Perfil',
                        subtitle: 'Ver y editar información personal',
                        onTap: () {
                          Navigator.of(context).pushNamed(Routes.profile);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SettingsSection(
                    title: 'Preferencias',
                    children: [
                      SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notificaciones',
                        subtitle: 'Activar/desactivar notificaciones',
                        trailing: Switch(
                          value: state.notificationsEnabled,
                          onChanged: vm.toggleNotifications,
                          activeColor: colorScheme.primary,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Modo Oscuro',
                        subtitle: 'Cambiar tema de la aplicación',
                        trailing: Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value);
                          },
                          activeColor: colorScheme.primary,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.language_outlined,
                        title: 'Idioma',
                        subtitle: 'Español',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onTap: () {
                          _showLanguageDialog(context, vm);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SettingsSection(
                    title: 'Ayuda y Soporte',
                    children: [
                      SettingsTile(
                        icon: Icons.help_outline,
                        title: 'Centro de Ayuda',
                        subtitle: 'Preguntas frecuentes y tutoriales',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Centro de Ayuda próximamente'),
                            ),
                          );
                        },
                      ),
                      SettingsTile(
                        icon: Icons.contact_support_outlined,
                        title: 'Contactar Soporte',
                        subtitle: 'Obtener ayuda del equipo',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Soporte próximamente'),
                            ),
                          );
                        },
                      ),
                      SettingsTile(
                        icon: Icons.info_outline,
                        title: 'Acerca de',
                        subtitle: 'Versión 1.0.0',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SettingsSection(
                    title: 'Legal',
                    children: [
                      SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Política de Privacidad',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Política de Privacidad próximamente'),
                            ),
                          );
                        },
                      ),
                      SettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Términos y Condiciones',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Términos y Condiciones próximamente'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SettingsSection(
                    title: 'Cuenta',
                    children: [
                      SettingsTile(
                        icon: Icons.logout,
                        title: 'Cerrar Sesión',
                        titleColor: colorScheme.primary,
                        onTap: () async {
                          final confirm = await _showConfirmDialog(
                            context,
                            title: 'Cerrar Sesión',
                            message: '¿Estás seguro de que quieres cerrar sesión?',
                          );
                          if (confirm == true) {
                            final ok = await vm.signOut();
                            if (ok && context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                Routes.login,
                                (route) => false,
                              );
                            }
                          }
                        },
                      ),
                      SettingsTile(
                        icon: Icons.delete_forever,
                        title: 'Eliminar Cuenta',
                        titleColor: colorScheme.error,
                        onTap: () async {
                          final confirm = await _showConfirmDialog(
                            context,
                            title: 'Eliminar Cuenta',
                            message:
                                '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer y perderás todos tus datos.',
                            confirmText: 'Eliminar',
                            isDestructive: true,
                          );
                          if (confirm == true) {
                            final ok = await vm.deleteAccount();
                            if (ok && context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                Routes.login,
                                (route) => false,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Aceptar',
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? colorScheme.error : colorScheme.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'es',
              groupValue: vm.state.language,
              onChanged: (value) {
                if (value != null) {
                  vm.changeLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: vm.state.language,
              onChanged: (value) {
                if (value != null) {
                  vm.changeLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showAboutDialog(
      context: context,
      applicationName: 'SmartMeal',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.restaurant_menu, size: 48, color: colorScheme.primary),
      children: [
        const Text(
          'SmartMeal es tu asistente personal de nutrición y planificación de comidas.',
        ),
        const SizedBox(height: 16),
        const Text('© 2025 SmartMeal. Todos los derechos reservados.'),
      ],
    );
  }
}