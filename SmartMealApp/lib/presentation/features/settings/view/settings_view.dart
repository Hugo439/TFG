import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/usecases/user/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/sign_out_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/delete_account_usecase.dart';
import 'package:smartmeal/presentation/app/locale_provider.dart';
import 'package:smartmeal/presentation/features/settings/viewmodel/settings_view_model.dart';
import 'package:smartmeal/presentation/features/settings/widgets/settings_section.dart';
import 'package:smartmeal/presentation/features/settings/widgets/settings_tile.dart';
import 'package:smartmeal/presentation/features/settings/widgets/account_info_card.dart';
import 'package:smartmeal/presentation/features/settings/widgets/language_card.dart';
import 'package:smartmeal/presentation/theme/theme_provider.dart';
import 'package:smartmeal/presentation/routes/routes.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          SettingsViewModel(
              sl<GetUserProfileUseCase>(),
              sl<SignOutUseCase>(),
              sl<DeleteAccountUseCase>(),
            )
            ..loadProfile()
            ..loadPreferences(),
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
    final l10n = context.l10n;

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
          l10n.settingsTitle,
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
                    title: l10n.settingsProfileSection,
                    children: [
                      SettingsTile(
                        icon: Icons.person_outline,
                        title: l10n.settingsMyProfile,
                        subtitle: l10n.settingsMyProfileSubtitle,
                        onTap: () {
                          Navigator.of(context).pushNamed(Routes.profile);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SettingsSection(
                    title: l10n.settingsPreferencesSection,
                    children: [
                      SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: l10n.settingsNotifications,
                        subtitle: l10n.settingsNotificationsSubtitle,
                        trailing: Switch(
                          value: state.notificationsEnabled,
                          onChanged: (value) async {
                            await vm.toggleNotifications(value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(value ? context.l10n.notificationsEnabled : context.l10n.notificationsDisabled),
                              ),
                            );
                          },
                          activeThumbColor: colorScheme.primary,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: l10n.settingsDarkMode,
                        subtitle: l10n.settingsDarkModeSubtitle,
                        trailing: Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value);
                          },
                          activeThumbColor: colorScheme.primary,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.language,
                        title: l10n.settingsLanguage,
                        subtitle: l10n.settingsLanguageSubtitle,
                        onTap: () async {
                          final provider = context.read<LocaleProvider>();
                          final selected = await _showLanguageModal(context);
                          if (selected != null) {
                            provider.setLocale(Locale(selected));
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SettingsSection(
                    title: l10n.settingsHelpSection,
                    children: [
                      SettingsTile(
                        icon: Icons.help_outline,
                        title: l10n.settingsHelpCenter,
                        subtitle: l10n.settingsHelpCenterSubtitle,
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed(Routes.support);
                        },
                      ),
                      SettingsTile(
                        icon: Icons.contact_support_outlined,
                        title: l10n.settingsContactSupport,
                        subtitle: l10n.settingsContactSupportSubtitle,
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed(Routes.support);
                        },
                      ),
                      SettingsTile(
                        icon: Icons.info_outline,
                        title: l10n.settingsAbout,
                        subtitle: l10n.settingsAboutSubtitle,
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SettingsSection(
                    title: l10n.settingsLegalSection,
                    children: [
                      SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: l10n.settingsPrivacyPolicy,
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed('/privacy');
                        },
                      ),
                      SettingsTile(
                        icon: Icons.description_outlined,
                        title: l10n.settingsTermsAndConditions,
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed('/terms');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SettingsSection(
                    title: l10n.settingsAccountSection,
                    children: [
                      SettingsTile(
                        icon: Icons.logout,
                        title: l10n.settingsSignOut,
                        titleColor: colorScheme.primary,
                        onTap: () async {
                          final confirm = await _showConfirmDialog(
                            context,
                            title: l10n.settingsSignOutDialogTitle,
                            message: l10n.settingsSignOutDialogMessage,
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
                        title: l10n.settingsDeleteAccount,
                        titleColor: colorScheme.error,
                        onTap: () async {
                          final confirm = await _showConfirmDialog(
                            context,
                            title: l10n.settingsDeleteAccountDialogTitle,
                            message: l10n.settingsDeleteAccountDialogMessage,
                            confirmText: l10n.settingsDeleteAccountConfirm,
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
    String? confirmText,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive
                  ? colorScheme.error
                  : colorScheme.primary,
            ),
            child: Text(confirmText ?? l10n.commonAccept),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    showAboutDialog(
      context: context,
      applicationName: 'SmartMeal',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.restaurant_menu,
        size: 48,
        color: colorScheme.primary,
      ),
      children: [
        Text(l10n.settingsAboutDescription),
        const SizedBox(height: 16),
        Text(l10n.settingsAboutCopyright),
      ],
    );
  }

  Future<String?> _showLanguageModal(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final modalColorScheme = Theme.of(ctx).colorScheme;
        final modalL10n = ctx.l10n;
        final currentLocale = Localizations.localeOf(ctx).languageCode;
        return Container(
          decoration: BoxDecoration(
            color: modalColorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        modalL10n.settingsLanguage,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: modalColorScheme.onSurface,
                        ),
                      ),
                    ),
                    LanguageCard(
                      isSelected: currentLocale == 'es',
                      flag: '🇪🇸',
                      title: modalL10n.settingsLanguageSpanish,
                      description: 'Español',
                      onTap: () => Navigator.pop(ctx, 'es'),
                      colorScheme: modalColorScheme,
                    ),
                    const SizedBox(height: 12),
                    LanguageCard(
                      isSelected: currentLocale == 'en',
                      flag: '🇬🇧',
                      title: modalL10n.settingsLanguageEnglish,
                      description: 'English',
                      onTap: () => Navigator.pop(ctx, 'en'),
                      colorScheme: modalColorScheme,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
