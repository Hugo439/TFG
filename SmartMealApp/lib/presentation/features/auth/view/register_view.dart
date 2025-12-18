import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/usecases/auth/sign_up_usecase.dart';
import 'package:smartmeal/presentation/features/auth/viewmodel/register_view_model.dart';
import 'package:smartmeal/presentation/features/auth/widgets/register_header.dart';
import 'package:smartmeal/presentation/features/auth/widgets/register_form.dart';
import 'package:smartmeal/presentation/features/auth/widgets/login_prompt.dart';
import 'package:smartmeal/l10n/l10n_ext.dart';

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
