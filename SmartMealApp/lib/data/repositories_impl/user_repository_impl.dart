import 'package:smartmeal/domain/repositories/user_repository.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:smartmeal/data/datasources/remote/firestore_datasource.dart';
import 'package:smartmeal/data/mappers/user_profile_mapper.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuthDataSource _authDataSource;
  final FirestoreDataSource _firestoreDataSource;

  UserRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
    required FirestoreDataSource firestoreDataSource,
  })  : _authDataSource = authDataSource,
        _firestoreDataSource = firestoreDataSource;

  @override
  Future<UserProfile> getUserProfile() async {
    final user = _authDataSource.getCurrentUser();
    if (user == null) throw Exception('Usuario no autenticado');

    final data = await _firestoreDataSource.getUserProfile(user.uid);
    if (data == null) throw Exception('Perfil no encontrado');

    return UserProfileMapper.fromFirestore(
      data,
      user.uid,
      user.email ?? '',
      user.photoURL,
    );
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    final user = _authDataSource.getCurrentUser();
    if (user == null) throw Exception('Usuario no autenticado');

    await _firestoreDataSource.updateUserProfile(
      user.uid,
      UserProfileMapper.toFirestore(profile),
    );

    // Acceder al value del Value Object DisplayName
    await _authDataSource.updateDisplayName(profile.displayName.value);
  }

  @override
  Future<void> createUserProfile(UserProfile profile) async {
    await _firestoreDataSource.createUserProfile(
      profile.uid,
      UserProfileMapper.toFirestoreCreate(profile),
    );
  }

  @override
  Future<void> deleteUserProfile(String uid) async {
    await _firestoreDataSource.deleteUserProfile(uid);
  }
}