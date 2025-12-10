import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<void> signIn({required String email, required String password});
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
  });
  Future<bool> checkAuthStatus();
  Future<void> signOut();
  Future<void> deleteAccount();
  User? getCurrentUser();
  
  Future<void> saveCredentials(String email, String password);
  Future<void> clearCredentials();
  Future<Map<String, String>?> getSavedCredentials();
}