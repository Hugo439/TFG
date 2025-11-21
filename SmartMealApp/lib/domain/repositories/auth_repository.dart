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
  });
  Future<bool> checkAuthStatus();
  Future<void> signOut();
  Future<void> deleteAccount();
}