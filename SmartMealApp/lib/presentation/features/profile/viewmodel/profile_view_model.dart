import 'package:flutter/foundation.dart';
import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/usecases/user/get_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/profile/update_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/sign_out_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/delete_account_usecase.dart';

/// Estados de la pantalla de perfil.
enum ProfileStatus { idle, loading, loaded, error }

/// Estado del ViewModel de perfil.
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

/// ViewModel para pantalla de perfil de usuario.
///
/// Responsabilidades:
/// - Cargar perfil del usuario desde Firestore
/// - Actualizar datos del perfil
/// - Cerrar sesión (sign out)
/// - Eliminar cuenta
///
/// Funcionalidades:
/// 1. **loadProfile()**: carga perfil desde GetUserProfileUseCase
/// 2. **updateProfile()**: actualiza perfil con UpdateUserProfileUseCase
/// 3. **signOut()**: cierra sesión con SignOutUseCase
/// 4. **deleteAccount()**: elimina cuenta con DeleteAccountUseCase
///
/// Estados:
/// - **idle**: sin datos cargados
/// - **loading**: cargando perfil
/// - **loaded**: perfil cargado exitosamente
/// - **error**: error al cargar/actualizar
///
/// Uso:
/// ```dart
/// final vm = Provider.of<ProfileViewModel>(context);
/// await vm.loadProfile();
/// if (vm.state.status == ProfileStatus.loaded) {
///   final profile = vm.state.profile;
///   await vm.updateProfile(updatedProfile);
/// }
/// ```
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

  /// Carga perfil del usuario desde Firestore.
  ///
  /// Llama a GetUserProfileUseCase.
  /// Actualiza estado a loaded si éxito, error si falla.
  Future<void> loadProfile() async {
    _update(_state.copyWith(status: ProfileStatus.loading, error: null));
    try {
      final profile = await _getProfile(const NoParams());
      _update(_state.copyWith(status: ProfileStatus.loaded, profile: profile));
    } catch (e) {
      _update(
        _state.copyWith(status: ProfileStatus.error, error: e.toString()),
      );
    }
  }

  /// Actualiza perfil del usuario en Firestore.
  ///
  /// Parámetros:
  /// - **profile**: perfil actualizado
  ///
  /// Retorna true si éxito, false si error.
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

  /// Cierra sesión del usuario.
  ///
  /// Llama a SignOutUseCase.
  /// Retorna true si éxito, false si error.
  Future<bool> signOut() async {
    try {
      await _signOut(const NoParams());
      return true;
    } catch (e) {
      _update(_state.copyWith(error: e.toString()));
      return false;
    }
  }

  /// Elimina cuenta del usuario.
  ///
  /// Elimina:
  /// - Usuario de Firebase Auth
  /// - Datos de Firestore (perfil, menús, recetas, compras)
  ///
  /// Llama a DeleteAccountUseCase.
  /// Retorna true si éxito, false si error.
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
