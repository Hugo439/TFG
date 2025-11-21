import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/presentation/features/auth/viewmodel/register_view_model.dart';
import 'package:smartmeal/presentation/widgets/inputs/filled_text_field.dart';
import 'package:smartmeal/presentation/widgets/buttons/primary_button.dart';
import 'package:smartmeal/presentation/routes/routes.dart';

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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nombre de Usuario', 
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FilledTextField(
            hintText: 'Ingresa tu nombre de usuario',
            controller: _nameCtrl,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
          ),
          const SizedBox(height: 16),
          Text(
            'Correo Electrónico', 
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FilledTextField(
            hintText: 'ejemplo@correo.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
              if (!v.contains('@')) return 'Correo no válido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Contraseña', 
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FilledTextField(
            hintText: 'Mínimo 8 caracteres, mayúscula, minúscula y número',
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
              if (v == null || v.isEmpty) return 'Campo obligatorio';
              if (v.length < 8) return 'Mínimo 8 caracteres';
              if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Debe contener al menos una mayúscula';
              if (!RegExp(r'[a-z]').hasMatch(v)) return 'Debe contener al menos una minúscula';
              if (!RegExp(r'[0-9]').hasMatch(v)) return 'Debe contener al menos un número';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Confirmar Contraseña', 
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FilledTextField(
            hintText: 'Confirma tu contraseña',
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
              if (v == null || v.isEmpty) return 'Campo obligatorio';
              if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
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
                      'Altura (cm)', 
                      style: TextStyle(
                        color: colorScheme.onSurface, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledTextField(
                      hintText: '170',
                      controller: _heightCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (int.tryParse(v) == null) return 'Número inválido';
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
                      'Peso (kg)', 
                      style: TextStyle(
                        color: colorScheme.onSurface, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledTextField(
                      hintText: '70',
                      controller: _weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (double.tryParse(v) == null) return 'Número inválido';
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
            'Objetivo', 
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildGoalSelector(vm, colorScheme),
          const SizedBox(height: 16),
          Text(
            'Alergias', 
            style: TextStyle(
              color: colorScheme.onSurface, 
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FilledTextField(
            hintText: 'Ejemplo: Gluten, Lactosa',
            controller: _allergiesCtrl,
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          if (vm.error != null) ...[
            Text(
              vm.error!,
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
            const SizedBox(height: 8),
          ],
          PrimaryButton(
            text: 'Registrarse',
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

  Widget _buildGoalSelector(RegisterViewModel vm, ColorScheme colorScheme) {
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
              child: Text('Perder peso', style: TextStyle(color: colorScheme.onSurface)),
            ),
            DropdownMenuItem(
              value: 'Ganar masa muscular', 
              child: Text('Ganar masa muscular', style: TextStyle(color: colorScheme.onSurface)),
            ),
            DropdownMenuItem(
              value: 'Mantener peso', 
              child: Text('Mantener peso', style: TextStyle(color: colorScheme.onSurface)),
            ),
            DropdownMenuItem(
              value: 'Alimentación saludable', 
              child: Text('Alimentación saludable', style: TextStyle(color: colorScheme.onSurface)),
            ),
          ],
          onChanged: (v) => vm.setGoal(v ?? 'Perder peso'),
        ),
      ),
    );
  }
}