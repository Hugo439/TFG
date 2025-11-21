import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/usecases/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/update_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/sign_out_usecase.dart';
import 'package:smartmeal/domain/usecases/delete_account_usecase.dart';
import 'package:smartmeal/presentation/features/profile/viewmodel/profile_view_model.dart';
import 'package:smartmeal/presentation/features/profile/widgets/profile_header.dart';
import 'package:smartmeal/presentation/features/profile/widgets/personal_info_section.dart';
import 'package:smartmeal/presentation/features/profile/widgets/goals_section.dart';
import 'package:smartmeal/presentation/features/profile/widgets/account_actions_section.dart';
import 'package:smartmeal/presentation/routes/routes.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(
        sl<GetUserProfileUseCase>(),
        sl<UpdateUserProfileUseCase>(),
        sl<SignOutUseCase>(),
        sl<DeleteAccountUseCase>(),
      )..loadProfile(),
      child: const _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final state = vm.state;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Mi Perfil',
          style: TextStyle(
            color: colorScheme.onSurface, 
            fontSize: 20, 
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colorScheme.onSurface),
            onPressed: state.profile != null
                ? () async {
                    final result = await Navigator.of(context).pushNamed(
                      Routes.editProfile,
                      arguments: state.profile,
                    );
                    if (result == true && context.mounted) {
                      context.read<ProfileViewModel>().loadProfile();
                    }
                  }
                : null,
          ),
        ],
      ),
      body: state.status == ProfileStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : state.status == ProfileStatus.error
              ? Center(
                  child: Text(
                    'Error: ${state.error}',
                    style: TextStyle(color: colorScheme.error),
                  ),
                )
              : state.profile == null
                  ? const Center(child: Text('Sin datos'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ProfileHeader(profile: state.profile!),
                          const SizedBox(height: 24),
                          PersonalInfoSection(profile: state.profile!),
                          const SizedBox(height: 16),
                          GoalsSection(profile: state.profile!),
                          const SizedBox(height: 16),
                          AccountActionsSection(
                            onChangePassword: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cambio de contraseña próximamente'),
                                ),
                              );
                            },
                            onSignOut: () async {
                              final ok = await vm.signOut();
                              if (ok && context.mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  Routes.login,
                                  (route) => false,
                                );
                              }
                            },
                            onDeleteAccount: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Eliminar Cuenta'),
                                  content: const Text(
                                    '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: colorScheme.error,
                                      ),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
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
                    ),
    );
  }
}