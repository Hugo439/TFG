import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/usecases/profile/update_user_profile_usecase.dart';
import 'package:smartmeal/presentation/features/profile/viewmodel/edit_profile_view_model.dart';
import 'package:smartmeal/presentation/widgets/inputs/filled_text_field.dart';
import 'package:smartmeal/presentation/widgets/buttons/primary_button.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';
import 'package:smartmeal/presentation/widgets/inputs/age_field.dart';
import 'package:smartmeal/presentation/widgets/inputs/gender_dropdown.dart';

class EditProfileView extends StatelessWidget {
  final UserProfile profile;

  const EditProfileView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileViewModel(
        sl<UpdateUserProfileUseCase>(),
        profile,
      ),
      child: const _EditProfileContent(),
    );
  }
}

class _EditProfileContent extends StatelessWidget {
  const _EditProfileContent();

  String _getErrorMessage(BuildContext context, EditProfileState state) {
    final l10n = context.l10n;
    
    if (state.errorCode != null) {
      switch (state.errorCode!) {
        case EditProfileErrorCode.nameRequired:
          return l10n.editProfileErrorNameRequired;
        case EditProfileErrorCode.heightInvalid:
          return l10n.editProfileErrorHeightInvalid;
        case EditProfileErrorCode.weightInvalid:
          return l10n.editProfileErrorWeightInvalid;
        case EditProfileErrorCode.ageInvalid:
          return l10n.editProfileErrorAgeInvalid;
        case EditProfileErrorCode.validationError:
          return state.errorMessage ?? l10n.editProfileErrorGeneric;
        case EditProfileErrorCode.generic:
          return l10n.editProfileErrorGeneric;
      }
    }
    
    return state.errorMessage ?? l10n.editProfileErrorGeneric;
  }
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditProfileViewModel>();
    final state = vm.state;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

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
          l10n.editProfileTitle,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      vm.displayName.isNotEmpty
                          ? vm.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 40,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.surface, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Información Personal
            _SectionTitle(title: l10n.editProfilePersonalInfo),
            const SizedBox(height: 12),
            FilledTextField(
              label: l10n.editProfileNameLabel,
              initialValue: vm.displayName,
              onChanged: vm.setDisplayName,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            FilledTextField(
              label: l10n.editProfileEmailLabel,
              initialValue: vm.initialProfile.email.value,
              enabled: false,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 12),
            FilledTextField(
              label: l10n.editProfilePhoneLabel,
              initialValue: vm.phone,
              onChanged: vm.setPhone,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AgeField(
                    initialValue: vm.age,
                    onChanged: vm.setAge,
                    isOptional: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GenderDropdown(
                    value: vm.gender,
                    onChanged: vm.setGender,
                    isOptional: true,
                    showLabel: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Datos Físicos
            _SectionTitle(title: l10n.editProfilePhysicalData),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledTextField(
                    label: l10n.editProfileHeightLabel,
                    initialValue: vm.heightCm,
                    onChanged: vm.setHeightCm,
                    prefixIcon: Icons.height,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledTextField(
                    label: l10n.editProfileWeightLabel,
                    initialValue: vm.weightKg,
                    onChanged: vm.setWeightKg,
                    prefixIcon: Icons.monitor_weight_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Objetivos y Preferencias
            _SectionTitle(title: l10n.editProfileGoalsPreferences),
            const SizedBox(height: 12),
            _GoalDropdown(
              value: vm.goal,
              onChanged: vm.setGoal,
            ),
            const SizedBox(height: 12),
            FilledTextField(
              label: l10n.editProfileAllergiesLabel,
              initialValue: vm.allergies,
              onChanged: vm.setAllergies,
              prefixIcon: Icons.warning_amber_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Error message
            if (state.errorCode != null || state.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getErrorMessage(context, state),
                  style: TextStyle(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Save button
            PrimaryButton(
              text: l10n.editProfileSaveButton,
              isLoading: state.status == EditProfileStatus.loading,
              onPressed: () async {
                final success = await vm.saveChanges();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.editProfileSaveSuccess),
                      backgroundColor: colorScheme.primary,
                    ),
                  );
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Text(
      title,
      style: TextStyle(
        color: colorScheme.primary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _GoalDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _GoalDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          dropdownColor: colorScheme.surfaceContainerHighest,
          items: [
            DropdownMenuItem(
              value: 'Perder peso',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.registerGoalLoseWeight, style: TextStyle(color: colorScheme.onSurface)),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Ganar masa muscular',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.registerGoalGainMuscle, style: TextStyle(color: colorScheme.onSurface)),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Mantener peso',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.registerGoalMaintainWeight, style: TextStyle(color: colorScheme.onSurface)),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Alimentación saludable',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.registerGoalHealthyEating, style: TextStyle(color: colorScheme.onSurface)),
                ],
              ),
            ),
          ],
          onChanged: (v) => onChanged(v ?? value),
        ),
      ),
    );
  }
}