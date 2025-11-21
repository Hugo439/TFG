import 'package:smartmeal/domain/repositories/auth_repository.dart';
import 'package:smartmeal/domain/repositories/user_repository.dart';
import 'package:smartmeal/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/value_objects/email.dart';
import 'package:smartmeal/domain/value_objects/password.dart';
import 'package:smartmeal/domain/value_objects/display_name.dart';
import 'package:smartmeal/domain/value_objects/height.dart';
import 'package:smartmeal/domain/value_objects/weight.dart';
import 'package:smartmeal/domain/value_objects/goal.dart';
import 'package:smartmeal/domain/value_objects/allergies.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;
  final UserRepository _userRepository;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
    required UserRepository userRepository,
  })  : _authDataSource = authDataSource,
        _userRepository = userRepository;

  @override
  Future<void> signIn({required String email, required String password}) async {
    // Validar con Value Objects
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
  }) async {
    // Validar todos los campos con Value Objects
    final emailVO = Email(email);
    final passwordVO = Password(password);
    final displayNameVO = DisplayName(displayName);
    final heightVO = Height(heightCm);
    final weightVO = Weight(weightKg);
    final goalVO = Goal.fromString(goal);
    final allergiesVO = Allergies.tryParse(allergies);

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
    );

    await _userRepository.createUserProfile(profile);
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
    
    await _userRepository.deleteUserProfile(user.uid);
    await _authDataSource.deleteAccount();
  }
}