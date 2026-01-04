import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/usecases/auth/load_saved_credentials_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/save_credentials_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/sign_in_usecase.dart';
import 'package:smartmeal/presentation/features/auth/viewmodel/login_view_model.dart';
import 'package:smartmeal/presentation/features/auth/widgets/login_form.dart';
import 'package:smartmeal/presentation/features/auth/widgets/login_header.dart';
import 'package:smartmeal/presentation/features/auth/widgets/register_prompt.dart';
import 'package:smartmeal/presentation/routes/routes.dart';

/// Pantalla de inicio de sesión.
///
/// Responsabilidades:
/// - Formulario de login (LoginForm)
/// - "Recordar credenciales" con checkbox
/// - Navegación a Home tras login exitoso
/// - Link a pantalla de registro (RegisterPrompt)
///
/// Componentes:
/// - **LoginHeader**: Logo + título + mensaje bienvenida
/// - **LoginForm**: Email + contraseña + checkbox + botón
/// - **RegisterPrompt**: Link "No tienes cuenta? Regístrate"
///
/// State management:
/// - LoginViewModel con ChangeNotifierProvider
/// - UseCases: SignInUseCase, LoadSavedCredentialsUseCase, SaveCredentialsUseCase
///
/// Funcionalidad "Remember me":
/// - Si activado: guarda email/password en SharedPreferences
/// - Al abrir app: carga credenciales guardadas
/// - Al desactivar: borra credenciales guardadas
///
/// Navegación:
/// - Éxito: pushReplacementNamed(Routes.home)
/// - Ir a registro: Navigator.pushNamed(Routes.register)
///
/// Responsive:
/// - Max width: 420px (centrado)
/// - Padding: 48px (>1000px), 32px (>800px), 16px (<800px)
///
/// Parámetros:
/// [prefilledEmail] - Email prellenado (opcional, usado tras registro)
///
/// Uso:
/// ```dart
/// // Login normal
/// Navigator.pushNamed(context, Routes.login);
///
/// // Login con email prellenado
/// LoginView(prefilledEmail: 'user@example.com');
/// ```
class LoginView extends StatelessWidget {
  final String? prefilledEmail;

  const LoginView({super.key, this.prefilledEmail});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(
        sl<SignInUseCase>(),
        sl<LoadSavedCredentialsUseCase>(),
        sl<SaveCredentialsUseCase>(),
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: width > 1000
                  ? 48
                  : width > 800
                  ? 32
                  : 16,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _LoginContent(prefilledEmail: prefilledEmail),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  final String? prefilledEmail;

  const _LoginContent({this.prefilledEmail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LoginHeader(),
        const SizedBox(height: 24),
        LoginForm(
          prefilledEmail: prefilledEmail,
          onSuccess: () {
            Navigator.of(context).pushReplacementNamed(Routes.home);
          },
        ),
        const SizedBox(height: 16),
        const RegisterPrompt(),
      ],
    );
  }
}
