import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/presentation/features/auth/viewmodel/register_view_model.dart';
import 'package:smartmeal/presentation/widgets/inputs/filled_text_field.dart';
import 'package:smartmeal/presentation/widgets/buttons/primary_button.dart';
import 'package:smartmeal/presentation/routes/routes.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _allergiesCtrl.dispose();
    super.dispose();
  }

  String? _getErrorText(BuildContext context, RegisterErrorCode? code) {
    if (code == null) return null;
    final l10n = context.l10n;
    switch (code) {
      case RegisterErrorCode.emailInUse:
        return l10n.registerErrorEmailInUse;
      case RegisterErrorCode.invalidEmail:
        return l10n.registerErrorInvalidEmail;
      case RegisterErrorCode.weakPassword:
        return l10n.registerErrorWeakPassword;
      case RegisterErrorCode.generic:
        return l10n.registerErrorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.registerUsernameLabel, 
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FilledTextField(
            hintText: l10n.registerUsernameHint,
            controller: _nameCtrl,
            validator: (v) => (v == null || v.trim().isEmpty) ? l10n.registerFieldRequired : null,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.registerEmailLabel, 
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FilledTextField(
            hintText: l10n.registerEmailHint,
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l10n.registerFieldRequired;
              if (!v.contains('@')) return l10n.registerEmailInvalid;
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            l10n.registerPasswordLabel, 
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FilledTextField(
            hintText: l10n.registerPasswordHint,
            controller: _passCtrl,
            obscureText: vm.obscurePassword,
            suffix: IconButton(
              icon: Icon(
                vm.obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: colorScheme.primary,
              ),
              onPressed: context.read<RegisterViewModel>().togglePasswordVisibility,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.registerFieldRequired;
              if (v.length < 8) return l10n.registerPasswordMinLength;
              if (!RegExp(r'[A-Z]').hasMatch(v)) return l10n.registerPasswordUppercase;
              if (!RegExp(r'[a-z]').hasMatch(v)) return l10n.registerPasswordLowercase;
              if (!RegExp(r'[0-9]').hasMatch(v)) return l10n.registerPasswordNumber;
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            l10n.registerConfirmPasswordLabel, 
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FilledTextField(
            hintText: l10n.registerConfirmPasswordHint,
            controller: _confirmPassCtrl,
            obscureText: vm.obscureConfirmPassword,
            suffix: IconButton(
              icon: Icon(
                vm.obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: colorScheme.primary,
              ),
              onPressed: context.read<RegisterViewModel>().toggleConfirmPasswordVisibility,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.registerFieldRequired;
              if (v != _passCtrl.text) return l10n.registerPasswordMismatch;
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.registerHeightLabel, 
                      style: TextStyle(
                        color: colorScheme.onSurface, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledTextField(
                      hintText: l10n.registerHeightHint,
                      controller: _heightCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.registerFieldRequiredShort;
                        if (int.tryParse(v) == null) return l10n.registerInvalidNumber;
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.registerWeightLabel, 
                      style: TextStyle(
                        color: colorScheme.onSurface, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledTextField(
                      hintText: l10n.registerWeightHint,
                      controller: _weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return l10n.registerFieldRequiredShort;
                        if (double.tryParse(v) == null) return l10n.registerInvalidNumber;
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.registerGoalLabel, 
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildGoalSelector(vm, colorScheme, l10n),
          const SizedBox(height: 16),
          Text(
            l10n.registerAllergiesLabel, 
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FilledTextField(
            hintText: l10n.registerAllergiesHint,
            controller: _allergiesCtrl,
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          if (_getErrorText(context, vm.errorCode) != null) ...[
            Text(
              _getErrorText(context, vm.errorCode)!,
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
            const SizedBox(height: 8),
          ],
          PrimaryButton(
            text: l10n.registerButton,
            isLoading: vm.isLoading,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final success = await vm.signUp(
                  _nameCtrl.text.trim(),
                  _emailCtrl.text.trim(),
                  _passCtrl.text,
                  int.parse(_heightCtrl.text),
                  double.parse(_weightCtrl.text),
                  vm.goal,
                  _allergiesCtrl.text.trim().isEmpty ? null : _allergiesCtrl.text.trim(),
                );
                if (success && mounted) {
                  Navigator.of(context).pushReplacementNamed(
                    Routes.login,
                    arguments: _emailCtrl.text.trim(),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSelector(RegisterViewModel vm, ColorScheme colorScheme, l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: vm.goal,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          dropdownColor: colorScheme.surfaceContainerHighest,
          items: [
            DropdownMenuItem(
              value: 'Perder peso', 
              child: Text(l10n.registerGoalLoseWeight, style: TextStyle(color: colorScheme.onSurface)),
            ),
            DropdownMenuItem(
              value: 'Ganar masa muscular', 
              child: Text(l10n.registerGoalGainMuscle, style: TextStyle(color: colorScheme.onSurface)),
            ),
            DropdownMenuItem(
              value: 'Mantener peso', 
              child: Text(l10n.registerGoalMaintainWeight, style: TextStyle(color: colorScheme.onSurface)),
            ),
            DropdownMenuItem(
              value: 'Alimentación saludable', 
              child: Text(l10n.registerGoalHealthyEating, style: TextStyle(color: colorScheme.onSurface)),
            ),
          ],
          onChanged: (value) {
            if (value != null) context.read<RegisterViewModel>().setGoal(value);
          },
        ),
      ),
    );
  }
}