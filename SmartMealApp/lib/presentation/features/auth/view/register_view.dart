import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/usecases/auth/sign_up_usecase.dart';
import 'package:smartmeal/presentation/features/auth/viewmodel/register_view_model.dart';
import 'package:smartmeal/presentation/features/auth/widgets/register_header.dart';
import 'package:smartmeal/presentation/features/auth/widgets/register_form.dart';
import 'package:smartmeal/presentation/features/auth/widgets/login_prompt.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

/// Pantalla de registro de nuevo usuario.
///
/// Responsabilidades:
/// - Formulario de registro completo (RegisterForm)
/// - Validación de datos antes de crear cuenta
/// - Navegación a Login tras registro exitoso
/// - Link para volver a Login (LoginPrompt)
///
/// Componentes:
/// - **AppBar**: Botón volver + título
/// - **RegisterHeader**: Icono + mensaje descriptivo
/// - **RegisterForm**: Email, contraseña, confirmar contraseña + botón
/// - **LoginPrompt**: Link "Ya tienes cuenta? Inicia sesión"
///
/// State management:
/// - RegisterViewModel con ChangeNotifierProvider
/// - UseCase: SignUpUseCase
///
/// Validaciones:
/// - Email: formato válido
/// - Contraseña: mínimo 6 caracteres
/// - Confirmar contraseña: debe coincidir
///
/// Flujo:
/// 1. Usuario llena formulario
/// 2. RegisterForm valida campos
/// 3. SignUpUseCase crea cuenta en Firebase Auth
/// 4. CreateUserProfileUseCase crea perfil en Firestore
/// 5. Navega a Login con email prellenado
///
/// Navegación:
/// - Éxito: pop() para volver a Login con email prellenado
/// - Cancelar: pop() para volver a Login
///
/// Responsive:
/// - Max width: 420px (centrado)
/// - Padding: 48px (>1000px), 32px (>800px), 16px (<800px)
///
/// Uso:
/// ```dart
/// // Desde LoginView
/// Navigator.pushNamed(context, Routes.register);
/// ```
class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(sl<SignUpUseCase>()),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            l10n.registerTitle,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RegisterHeader(),
                  const SizedBox(height: 24),
                  const RegisterForm(),
                  const SizedBox(height: 16),
                  LoginPrompt(onTap: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
