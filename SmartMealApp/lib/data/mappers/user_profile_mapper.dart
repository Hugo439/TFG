import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/value_objects/email.dart';
import 'package:smartmeal/domain/value_objects/display_name.dart';
import 'package:smartmeal/domain/value_objects/phone_number.dart';
import 'package:smartmeal/domain/value_objects/height.dart';
import 'package:smartmeal/domain/value_objects/weight.dart';
import 'package:smartmeal/domain/value_objects/goal.dart';
import 'package:smartmeal/domain/value_objects/allergies.dart';
import 'package:smartmeal/domain/value_objects/age.dart';
import 'package:smartmeal/domain/value_objects/gender.dart';

/// Mapper para convertir entre UserProfile (entidad del dominio) y datos de Firestore.
///
/// Responsabilidades:
/// - **fromFirestore**: Convierte Map<String, dynamic> de Firestore → UserProfile con Value Objects validados
/// - **toFirestore**: Convierte UserProfile → Map para actualización en Firestore
/// - **toFirestoreCreate**: Igual que toFirestore pero añade timestamp de creación
///
/// Manejo de errores:
/// - Age y Gender pueden fallar en parsing → devuelve null (campos opcionales)
/// - Otros campos tienen valores por defecto si faltan en Firestore
///
/// Formato Firestore:
/// ```json
/// {
///   "displayName": "Juan Pérez",
///   "email": "juan@example.com",
///   "heightCm": 175,
///   "weightKg": 70.5,
///   "goal": "Perder peso",
///   "allergies": "gluten, lactosa",
///   "age": 30,
///   "gender": "male",
///   "phone": "+34666777888",
///   "createdAt": "2024-01-01T10:00:00.000Z",
///   "updatedAt": "2024-01-15T15:30:00.000Z"
/// }
/// ```
class UserProfileMapper {
  /// Convierte datos de Firestore a entidad UserProfile del dominio.
  ///
  /// [data] - Mapa de datos desde Firestore (documento del perfil).
  /// [uid] - ID del usuario desde Firebase Auth.
  /// [emailString] - Email desde Firebase Auth (fuente de verdad).
  /// [photoUrl] - URL de foto desde Firebase Auth (puede ser null).
  ///
  /// Returns: UserProfile con todos los Value Objects validados.
  ///
  /// Validación:
  /// - DisplayName, Email, Height, Weight, Goal son obligatorios (con defaults)
  /// - Phone, Allergies, Age, Gender son opcionales
  /// - Age y Gender usan parsers especiales que retornan null si fallan
  ///
  /// Nota: El email siempre viene de Firebase Auth, no de Firestore.
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
      age: _parseAge(data['age']),
      gender: _parseGender(data['gender']),
    );
  }

  /// Parsea edad desde valor dinámico de Firestore.
  ///
  /// Maneja tanto int como string. Retorna null si falla el parsing.
  static Age? _parseAge(dynamic value) {
    if (value == null) return null;
    try {
      final ageValue = value is int ? value : int.parse(value.toString());
      return Age(ageValue);
    } catch (e) {
      return null;
    }
  }

  /// Parsea género desde valor dinámico de Firestore.
  ///
  /// Retorna null si el valor es null, vacío o inválido.
  static Gender? _parseGender(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return null;
    try {
      return Gender(value.toString());
    } catch (e) {
      return null;
    }
  }

  /// Convierte UserProfile a Map para actualización en Firestore.
  ///
  /// Extrae los valores primitivos de los Value Objects.
  /// Incluye timestamp de actualización.
  ///
  /// Returns: Map listo para Firestore update().
  static Map<String, dynamic> toFirestore(UserProfile profile) {
    return {
      'displayName': profile.displayName.value,
      'email': profile.email.value,
      'phone': profile.phone?.value,
      'heightCm': profile.height.value,
      'weightKg': profile.weight.value,
      'goal': profile.goal.displayName,
      'allergies': profile.allergies?.value,
      'age': profile.age?.value,
      'gender': profile.gender?.value,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Convierte UserProfile a Map para creación inicial en Firestore.
  ///
  /// Igual que toFirestore pero añade timestamp de creación.
  ///
  /// Returns: Map listo para Firestore set().
  static Map<String, dynamic> toFirestoreCreate(UserProfile profile) {
    return {
      ...toFirestore(profile),
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
