import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/usecases/user/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/profile/update_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/sign_out_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/delete_account_usecase.dart';

enum ProfileStatus { idle, loading, loaded, error }

class ProfileState {
  final ProfileStatus status;
  final UserProfile? profile;
  final String? error;

  const ProfileState({
    this.status = ProfileStatus.idle,
    this.profile,
    this.error,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

class ProfileViewModel extends ChangeNotifier {
  final GetUserProfileUseCase _getProfile;
  final UpdateUserProfileUseCase _updateProfile;
  final SignOutUseCase _signOut;
  final DeleteAccountUseCase _deleteAccount;

  ProfileState _state = const ProfileState();
  ProfileState get state => _state;

  ProfileViewModel(
    this._getProfile,
    this._updateProfile,
    this._signOut,
    this._deleteAccount,
  );

  Future<void> loadProfile() async {
    _update(_state.copyWith(status: ProfileStatus.loading, error: null));
    try {
      final profile = await _getProfile(const NoParams());
      _update(_state.copyWith(status: ProfileStatus.loaded, profile: profile));
    } catch (e) {
      _update(_state.copyWith(status: ProfileStatus.error, error: e.toString()));
    }
  }

  Future<bool> updateProfile(UserProfile profile) async {
    try {
      await _updateProfile(profile);
      _update(_state.copyWith(profile: profile));
      return true;
    } catch (e) {
      _update(_state.copyWith(error: e.toString()));
      return false;
    }
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

  void _update(ProfileState s) {
    _state = s;
    notifyListeners();
  }
}