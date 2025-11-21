import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/usecases/initialize_app_usecase.dart';
import 'package:smartmeal/domain/usecases/check_auth_status_usecase.dart';

enum SplashStatus { idle, loading, authenticated, notAuthenticated, error }

class SplashState {
  final SplashStatus status;
  final String? error;

  const SplashState({this.status = SplashStatus.idle, this.error});

  SplashState copyWith({SplashStatus? status, String? error}) {
    return SplashState(
      status: status ?? this.status,
      error: error,
    );
  }
}

class SplashViewModel extends ChangeNotifier {
  final InitializeAppUseCase _initializeApp;
  final CheckAuthStatusUseCase _checkAuthStatus;

  SplashState _state = const SplashState();
  SplashState get state => _state;

  SplashViewModel(this._initializeApp, this._checkAuthStatus);

  Future<void> initialize() async {
    _update(_state.copyWith(status: SplashStatus.loading, error: null));

    try {
      await _initializeApp(const NoParams());
      await Future.delayed(const Duration(seconds: 1));
      
      final isAuthenticated = await _checkAuthStatus(const NoParams());
      
      _update(_state.copyWith(
        status: isAuthenticated ? SplashStatus.authenticated : SplashStatus.notAuthenticated,
      ));
    } catch (e) {
      _update(_state.copyWith(status: SplashStatus.error, error: e.toString()));
    }
  }

  void _update(SplashState s) {
    _state = s;
    notifyListeners();
  }
}