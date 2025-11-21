import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/presentation/features/auth/viewmodel/login_view_model.dart';
import 'package:smartmeal/presentation/widgets/inputs/filled_text_field.dart';
import 'package:smartmeal/presentation/widgets/buttons/primary_button.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback? onSuccess;
  final String? prefilledEmail;
  
  const LoginForm({super.key, this.onSuccess, this.prefilledEmail});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.prefilledEmail != null) {
      _emailCtrl.text = widget.prefilledEmail!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cargar credenciales guardadas
    final vm = context.watch<LoginViewModel>();
    if (_emailCtrl.text.isEmpty && vm.email.isNotEmpty) {
      _emailCtrl.text = vm.email;
      _passCtrl.text = vm.password;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          FilledTextField(
            hintText: 'Correo electrónico',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
              if (!v.contains('@')) return 'Correo no válido';
              return null;
            },
          ),
          const SizedBox(height: 12),
          FilledTextField(
            hintText: 'Contraseña',
            controller: _passCtrl,
            obscureText: vm.obscurePassword,
            prefixIcon: Icons.lock_outline,
            suffix: IconButton(
              icon: Icon(
                vm.obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: colorScheme.primary,
              ),
              onPressed: context.read<LoginViewModel>().togglePasswordVisibility,
            ),
          ),
          if (vm.error != null) ...[
            const SizedBox(height: 8),
            Text(
              vm.error!,
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: vm.rememberMe,
                    onChanged: (value) =>
                        context.read<LoginViewModel>().toggleRememberMe(),
                    activeColor: colorScheme.primary,
                  ),
                  Text(
                    'Recordarme',
                    style: TextStyle(
                      color: colorScheme.onSurface, 
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Iniciar Sesión',
            isLoading: vm.isLoading,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final success = await vm.signIn(
                  _emailCtrl.text.trim(),
                  _passCtrl.text,
                );
                if (success && mounted) {
                  widget.onSuccess?.call();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}