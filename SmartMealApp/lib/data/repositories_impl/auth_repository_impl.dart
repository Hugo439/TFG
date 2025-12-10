import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/data/datasources/local/auth_local_datasource.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';
import 'package:smartmeal/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:smartmeal/data/datasources/remote/firestore_datasource.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/value_objects/email.dart';
import 'package:smartmeal/domain/value_objects/password.dart';
import 'package:smartmeal/domain/value_objects/display_name.dart';
import 'package:smartmeal/domain/value_objects/height.dart';
import 'package:smartmeal/domain/value_objects/weight.dart';
import 'package:smartmeal/domain/value_objects/goal.dart';
import 'package:smartmeal/domain/value_objects/allergies.dart';
import 'package:smartmeal/domain/value_objects/age.dart';
import 'package:smartmeal/domain/value_objects/gender.dart';
import 'package:smartmeal/data/mappers/user_profile_mapper.dart';
import 'package:flutter/foundation.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;
  final AuthLocalDataSource _authLocalDataSource;
  final FirestoreDataSource _firestoreDataSource;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
    required AuthLocalDataSource authLocalDataSource,
    required FirestoreDataSource firestoreDataSource,
  })  : _authDataSource = authDataSource,
        _authLocalDataSource = authLocalDataSource,
        _firestoreDataSource = firestoreDataSource;

  @override
  Future<void> signIn({required String email, required String password}) async {
    final emailVO = Email(email);
    final passwordVO = Password(password);
    
    await _authDataSource.signIn(
      email: emailVO.value,
      password: passwordVO.value,
    );
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required int heightCm,
    required double weightKg,
    required String goal,
    String? allergies,
    int? age,
    String? gender,
  }) async {
    final emailVO = Email(email);
    final passwordVO = Password(password);
    final displayNameVO = DisplayName(displayName);
    final heightVO = Height(heightCm);
    final weightVO = Weight(weightKg);
    final goalVO = Goal.fromString(goal);
    final allergiesVO = Allergies.tryParse(allergies);
    final ageVO = age != null ? Age(age) : null;
    final genderVO = gender != null ? Gender(gender) : null;

    final credential = await _authDataSource.signUp(
      email: emailVO.value,
      password: passwordVO.value,
    );

    final user = credential.user;
    if (user == null) throw Exception('Error al crear usuario');

    await _authDataSource.updateDisplayName(displayNameVO.value);

    final profile = UserProfile(
      uid: user.uid,
      displayName: displayNameVO,
      email: emailVO,
      height: heightVO,
      weight: weightVO,
      goal: goalVO,
      allergies: allergiesVO,
      age: ageVO,
      gender: genderVO,
    );

    await _firestoreDataSource.createUserProfile(
      user.uid,
      UserProfileMapper.toFirestoreCreate(profile),
    );
  }

  @override
  Future<bool> checkAuthStatus() async {
    return _authDataSource.isUserAuthenticated();
  }

  @override
  Future<void> signOut() async {
    await _authDataSource.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = _authDataSource.getCurrentUser();
    if (user == null) throw Exception('Usuario no autenticado');
    
    await _firestoreDataSource.deleteUserProfile(user.uid);
    await _authDataSource.deleteAccount();
  }

  @override
  User? getCurrentUser() {
    return _authDataSource.getCurrentUser();
  }

  @override
  Future<void> saveCredentials(String email, String password) async {
    try {
      if (kDebugMode) {
        print('💾 [AuthRepository] Guardando credenciales...');
      }
      await _authLocalDataSource.saveCredentials(email, password);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AuthRepository] Error guardando credenciales: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> clearCredentials() async {
    try {
      if (kDebugMode) {
        print('🗑️ [AuthRepository] Limpiando credenciales...');
      }
      await _authLocalDataSource.clearCredentials();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AuthRepository] Error limpiando credenciales: $e');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      if (kDebugMode) {
        print('🔓 [AuthRepository] Obteniendo credenciales guardadas...');
      }
      return await _authLocalDataSource.getSavedCredentials();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AuthRepository] Error obteniendo credenciales: $e');
      }
      rethrow;
    }
  }
}