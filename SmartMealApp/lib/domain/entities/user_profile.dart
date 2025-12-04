import 'package:smartmeal/domain/value_objects/email.dart';
import 'package:smartmeal/domain/value_objects/display_name.dart';
import 'package:smartmeal/domain/value_objects/phone_number.dart';
import 'package:smartmeal/domain/value_objects/height.dart';
import 'package:smartmeal/domain/value_objects/weight.dart';
import 'package:smartmeal/domain/value_objects/goal.dart';
import 'package:smartmeal/domain/value_objects/allergies.dart';
import 'package:smartmeal/domain/value_objects/age.dart';
import 'package:smartmeal/domain/value_objects/gender.dart';

class UserProfile {
  final String uid;
  final DisplayName displayName;
  final Email email;
  final String? photoUrl;
  final PhoneNumber? phone;
  final Height height;
  final Weight weight;
  final Goal goal;
  final Allergies? allergies;
  final Age? age;
  final Gender? gender;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.phone,
    required this.height,
    required this.weight,
    required this.goal,
    this.allergies,
    this.age,
    this.gender,
  });
  
  // Helper getters para acceso directo a valores primitivos
  String get displayNameValue => displayName.value;
  String get emailValue => email.value;
  String? get phoneValue => phone?.value;
  int get heightCm => height.value;
  double get weightKg => weight.value;
  String get goalValue => goal.displayName;
  String? get allergiesValue => allergies?.value;
  int? get ageValue => age?.value;
  String? get genderValue => gender?.value;
  
  // Cálculo de IMC
  double get bmi => weight.calculateBMI(height);
  
  // Clasificación de IMC
  String get bmiCategory {
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Peso normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }
}