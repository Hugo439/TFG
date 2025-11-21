import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/usecases/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/sign_out_usecase.dart';
import 'package:smartmeal/domain/usecases/delete_account_usecase.dart';

enum SettingsStatus { idle, loading, loaded, error }

class SettingsState {
  final SettingsStatus status;
  final UserProfile? profile;
  final String? error;
  final bool notificationsEnabled;
  final String language;

  const SettingsState({
    this.status = SettingsStatus.idle,
    this.profile,
    this.error,
    this.notificationsEnabled = true,
    this.language = 'es',
  });

  SettingsState copyWith({
    SettingsStatus? status,
    UserProfile? profile,
    String? error,
    bool? notificationsEnabled,
    String? language,
  }) {
    return SettingsState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: error,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
    );
  }
}

class SettingsViewModel extends ChangeNotifier {
  final GetUserProfileUseCase _getProfile;
  final SignOutUseCase _signOut;
  final DeleteAccountUseCase _deleteAccount;

  SettingsState _state = const SettingsState();
  SettingsState get state => _state;

  SettingsViewModel(
    this._getProfile,
    this._signOut,
    this._deleteAccount,
  );

  Future<void> loadProfile() async {
    _update(_state.copyWith(status: SettingsStatus.loading, error: null));
    try {
      final profile = await _getProfile(const NoParams());
      _update(_state.copyWith(status: SettingsStatus.loaded, profile: profile));
    } catch (e) {
      _update(_state.copyWith(status: SettingsStatus.error, error: e.toString()));
    }
  }

  void toggleNotifications(bool value) {
    _update(_state.copyWith(notificationsEnabled: value));
    // TODO: Guardar en SharedPreferences o Firebase
  }

  void changeLanguage(String languageCode) {
    _update(_state.copyWith(language: languageCode));
    // TODO: Cambiar idioma de la app
  }

  Future<bool> signOut() async {
    try {
      await _signOut(const NoParams());
      return true;
    } catch (e) {
      _update(_state.copyWith(error: e.toString()));
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      await _deleteAccount(const NoParams());
      return true;
    } catch (e) {
      _update(_state.copyWith(error: e.toString()));
      return false;
    }
  }

  void _update(SettingsState s) {
    _state = s;
    notifyListeners();
  }
}