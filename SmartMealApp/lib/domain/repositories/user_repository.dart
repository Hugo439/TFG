import 'package:smartmeal/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile> getUserProfile();
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> createUserProfile(UserProfile profile);
  Future<void> deleteUserProfile(String uid);
  Future<String> uploadProfilePhoto(String filePath, String userId);
}
