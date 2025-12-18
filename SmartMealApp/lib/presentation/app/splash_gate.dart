import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmeal/presentation/features/splash/view/splash_view.dart';
import 'package:smartmeal/presentation/features/splash/viewmodel/splash_view_model.dart';
import 'package:smartmeal/core/di/service_locator.dart';
import 'package:smartmeal/domain/usecases/initialize_app_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/check_auth_status_usecase.dart';
import 'package:smartmeal/presentation/routes/routes.dart';

class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashViewModel(
        sl<InitializeAppUseCase>(),
        sl<CheckAuthStatusUseCase>(),
      )..initialize(),
      child: const _SplashGateBody(),
    );
  }
}

class _SplashGateBody extends StatefulWidget {
  const _SplashGateBody();

  @override
  State<_SplashGateBody> createState() => _SplashGateBodyState();
}

class _SplashGateBodyState extends State<_SplashGateBody> {
  @override
  Widget build(BuildContext context) {
    return Selector<SplashViewModel, SplashState>(
      selector: (_, vm) => vm.state,
      builder: (context, state, _) {
        if (state.status == SplashStatus.authenticated ||
            state.status == SplashStatus.notAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            // Guardamos la referencia local para no usar context tras gaps sin mounted.
            final navigator = Navigator.of(context);
            final destination = state.status == SplashStatus.authenticated
                ? Routes.home
                : Routes.login;

            try {
              await precacheImage(
                const AssetImage('assets/branding/logo.png'),
                context,
              );
            } catch (_) {
              // Ignorar errores de caché para no bloquear la navegación.
            }

            if (!mounted) return;
            navigator.pushReplacementNamed(destination);
          });
        }

        return SplashView(
          error: state.status == SplashStatus.error ? state.error : null,
          onRetry: () => context.read<SplashViewModel>().initialize(),
          showProgress: state.status == SplashStatus.loading,
        );
      },
    );
  }
}
