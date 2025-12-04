import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/usecases/auth/sign_in_usecase.dart';
import 'package:smartmeal/data/datasources/local/auth_local_datasource.dart';
import 'package:smartmeal/presentation/features/auth/viewmodel/login_view_model.dart';
import 'package:smartmeal/presentation/features/auth/widgets/login_form.dart';
import 'package:smartmeal/presentation/features/auth/widgets/login_header.dart';
import 'package:smartmeal/presentation/features/auth/widgets/register_prompt.dart';
import 'package:smartmeal/presentation/routes/routes.dart';

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
        sl<AuthLocalDataSource>(),
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: width > 1000 ? 48 : width > 800 ? 32 : 16,
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