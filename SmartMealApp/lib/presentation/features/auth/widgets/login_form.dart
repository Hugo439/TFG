import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/presentation/features/auth/viewmodel/login_view_model.dart';
import 'package:smartmeal/presentation/widgets/inputs/filled_text_field.dart';
import 'package:smartmeal/presentation/widgets/buttons/primary_button.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Formulario de inicio de sesión.
///
/// Responsabilidades:
/// - Campos de email y contraseña
/// - Validación de inputs
/// - Llamar a LoginViewModel.login()
/// - Mostrar errores localizados
/// - Opción "Recordar contraseña"
/// - Botón de login
///
/// Campos:
/// 1. **Email**: FilledTextField con validación
/// 2. **Contraseña**: FilledTextField con obscureText
///
/// Flujo de uso:
/// 1. Usuario introduce email y password
/// 2. Toca botón "Iniciar sesión"
/// 3. Llama vm.login(email, password)
/// 4. LoginViewModel maneja autenticación Firebase
/// 5. Si éxito: onSuccess() callback
/// 6. Si error: muestra mensaje localizado
///
/// Estados:
/// - **Normal**: formulario habilitado
/// - **Loading**: botón con spinner, campos disabled
/// - **Error**: mensaje rojo debajo del formulario
///
/// Códigos de error:
/// - fieldsRequired: Campos requeridos
/// - userNotFound: Usuario no encontrado
/// - wrongPassword: Contraseña incorrecta
/// - invalidEmail: Email inválido
/// - userDisabled: Cuenta deshabilitada
/// - invalidCredential: Credenciales inválidas
/// - generic: Error genérico
///
/// Prefill:
/// - Acepta prefilledEmail para pre-llenar campo
/// - Útil al venir de RegisterView
/// - didChangeDependencies actualiza desde ViewModel
///
/// Recordar contraseña:
/// - Checkbox para guardar credenciales
/// - Almacenado en SharedPreferences
/// - vm.rememberMe controla estado
///
/// _getErrorText:
/// - Mapea LoginErrorCode a strings localizados
/// - Usa l10n para multi-idioma
///
/// Parámetros:
/// [onSuccess] - Callback al login exitoso
/// [prefilledEmail] - Email pre-llenado (opcional)
///
/// Uso:
/// ```dart
/// LoginForm(
///   onSuccess: () => navigateToHome(),
///   prefilledEmail: 'user@example.com',
/// )
/// ```
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

  String? _getErrorText(BuildContext context, LoginErrorCode? code) {
    if (code == null) return null;
    final l10n = context.l10n;
    switch (code) {
      case LoginErrorCode.fieldsRequired:
        return l10n.loginErrorFieldsRequired;
      case LoginErrorCode.userNotFound:
        return l10n.loginErrorUserNotFound;
      case LoginErrorCode.wrongPassword:
        return l10n.loginErrorWrongPassword;
      case LoginErrorCode.invalidEmail:
        return l10n.loginErrorInvalidEmail;
      case LoginErrorCode.userDisabled:
        return l10n.loginErrorUserDisabled;
      case LoginErrorCode.invalidCredential:
        return l10n.loginErrorInvalidCredential;
      case LoginErrorCode.generic:
        return l10n.loginErrorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          FilledTextField(
            hintText: l10n.loginEmailHint,
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l10n.loginFieldRequired;
              if (!v.contains('@')) return l10n.loginEmailInvalid;
              return null;
            },
          ),
          const SizedBox(height: 12),
          FilledTextField(
            hintText: l10n.loginPasswordHint,
            controller: _passCtrl,
            obscureText: vm.obscurePassword,
            prefixIcon: Icons.lock_outline,
            suffix: IconButton(
              icon: Icon(
                vm.obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: colorScheme.primary,
              ),
              onPressed: context
                  .read<LoginViewModel>()
                  .togglePasswordVisibility,
            ),
          ),
          if (_getErrorText(context, vm.errorCode) != null) ...[
            const SizedBox(height: 8),
            Text(
              _getErrorText(context, vm.errorCode)!,
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
                    l10n.loginRememberMe,
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
            text: l10n.loginButton,
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
