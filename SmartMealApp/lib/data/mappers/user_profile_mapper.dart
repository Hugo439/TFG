import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/value_objects/email.dart';
import 'package:smartmeal/domain/value_objects/display_name.dart';
import 'package:smartmeal/domain/value_objects/phone_number.dart';
import 'package:smartmeal/domain/value_objects/height.dart';
import 'package:smartmeal/domain/value_objects/weight.dart';
import 'package:smartmeal/domain/value_objects/goal.dart';
import 'package:smartmeal/domain/value_objects/allergies.dart';

class UserProfileMapper {
  static UserProfile fromFirestore(
    Map<String, dynamic> data,
    String uid,
    String emailString,
    String? photoUrl,
  ) {
    return UserProfile(
      uid: uid,
      displayName: DisplayName(data['displayName'] ?? ''),
      email: Email(emailString),
      photoUrl: photoUrl,
      phone: PhoneNumber.tryParse(data['phone']),
      height: Height(data['heightCm'] ?? 0),
      weight: Weight((data['weightKg'] ?? 0.0).toDouble()),
      goal: Goal.fromString(data['goal'] ?? 'Perder peso'),
      allergies: Allergies.tryParse(data['allergies']),
    );
  }

  static Map<String, dynamic> toFirestore(UserProfile profile) {
    return {
      'displayName': profile.displayName.value,
      'email': profile.email.value,
      'phone': profile.phone?.value,
      'heightCm': profile.height.value,
      'weightKg': profile.weight.value,
      'goal': profile.goal.displayName,
      'allergies': profile.allergies?.value,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> toFirestoreCreate(UserProfile profile) {
    return {
      ...toFirestore(profile),
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}