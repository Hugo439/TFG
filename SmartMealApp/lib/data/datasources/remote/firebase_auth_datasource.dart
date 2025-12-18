import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth;

  FirebaseAuthDataSource({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    await user.delete();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    await user.updateDisplayName(displayName);
  }

  Future<void> updatePhotoURL(String photoUrl) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    await user.updatePhotoURL(photoUrl);
  }
}
