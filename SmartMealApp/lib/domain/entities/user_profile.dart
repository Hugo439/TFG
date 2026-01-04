import 'package:smartmeal/domain/value_objects/email.dart';
import 'package:smartmeal/domain/value_objects/display_name.dart';
import 'package:smartmeal/domain/value_objects/phone_number.dart';
import 'package:smartmeal/domain/value_objects/height.dart';
import 'package:smartmeal/domain/value_objects/weight.dart';
import 'package:smartmeal/domain/value_objects/goal.dart';
import 'package:smartmeal/domain/value_objects/allergies.dart';
import 'package:smartmeal/domain/value_objects/age.dart';
import 'package:smartmeal/domain/value_objects/gender.dart';

/// Entidad que representa el perfil completo de un usuario en el sistema.
///
/// Contiene toda la información personal y nutricional necesaria para:
/// - Calcular necesidades calóricas personalizadas
/// - Generar menús adaptados a objetivos
/// - Filtrar recetas según alergias
/// - Mostrar datos del perfil en la UI
///
/// Utiliza Value Objects para garantizar la validez de los datos.
class UserProfile {
  /// ID único del usuario en Firebase Authentication.
  final String uid;

  /// Nombre para mostrar (validado por DisplayName value object).
  final DisplayName displayName;

  /// Email del usuario (validado por Email value object).
  final Email email;

  /// URL de la foto de perfil (opcional).
  final String? photoUrl;

  /// Número de teléfono (opcional, validado por PhoneNumber).
  final PhoneNumber? phone;

  /// Altura del usuario (validada por Height value object).
  final Height height;

  /// Peso del usuario (validado por Weight value object).
  final Weight weight;

  /// Objetivo nutricional (perder peso, mantener, ganar músculo, etc).
  final Goal goal;

  /// Alergias alimentarias (opcional).
  final Allergies? allergies;

  /// Edad del usuario (opcional, para cálculos calóricos más precisos).
  final Age? age;

  /// Género del usuario (opcional, para cálculos calóricos más precisos).
  final Gender? gender;

  /// Crea una instancia de [UserProfile].
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

  // ==================== Helper Getters ====================
  // Proporcionan acceso directo a valores primitivos desde value objects

  /// Obtiene el nombre para mostrar como String.
  String get displayNameValue => displayName.value;

  /// Obtiene el email como String.
  String get emailValue => email.value;

  /// Obtiene el teléfono como String (null si no está configurado).
  String? get phoneValue => phone?.value;

  /// Obtiene la altura en centímetros.
  int get heightCm => height.value;

  /// Obtiene el peso en kilogramos.
  double get weightKg => weight.value;

  /// Obtiene el objetivo como String legible.
  String get goalValue => goal.displayName;

  /// Obtiene las alergias como String (null si no hay).
  String? get allergiesValue => allergies?.value;

  /// Obtiene la edad en años (null si no está configurada).
  int? get ageValue => age?.value;

  /// Obtiene el género como String (null si no está configurado).
  String? get genderValue => gender?.value;

  // ==================== Cálculos de Salud ====================

  /// Calcula el Índice de Masa Corporal (IMC) usando altura y peso.
  ///
  /// Fórmula: IMC = peso(kg) / altura(m)²
  double get bmi => weight.calculateBMI(height);

  /// Clasifica el IMC en categorías de salud estándar.
  ///
  /// Categorías:
  /// - < 18.5: Bajo peso
  /// - 18.5-24.9: Peso normal
  /// - 25-29.9: Sobrepeso
  /// - ≥ 30: Obesidad
  String get bmiCategory {
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Peso normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }
}
