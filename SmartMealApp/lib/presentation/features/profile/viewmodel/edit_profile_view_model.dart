import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/usecases/profile/update_user_profile_usecase.dart';
import 'package:smartmeal/domain/usecases/profile/upload_profile_photo_usecase.dart';
import 'package:smartmeal/domain/value_objects/allergies.dart';
import 'package:smartmeal/domain/value_objects/display_name.dart';
import 'package:smartmeal/domain/value_objects/goal.dart';
import 'package:smartmeal/domain/value_objects/height.dart';
import 'package:smartmeal/domain/value_objects/phone_number.dart';
import 'package:smartmeal/domain/value_objects/weight.dart';
import 'package:smartmeal/domain/value_objects/age.dart';
import 'package:smartmeal/domain/value_objects/gender.dart';

/// Estados del formulario de edición de perfil.
enum EditProfileStatus { idle, loading, success, error }

/// Códigos de error en edición de perfil.
enum EditProfileErrorCode {
  nameRequired,
  heightInvalid,
  weightInvalid,
  ageInvalid,
  validationError,
  generic,
}

/// Estado del ViewModel de edición de perfil.
class EditProfileState {
  final EditProfileStatus status;
  final EditProfileErrorCode? errorCode;
  final String? errorMessage;

  const EditProfileState({
    this.status = EditProfileStatus.idle,
    this.errorCode,
    this.errorMessage,
  });

  EditProfileState copyWith({
    EditProfileStatus? status,
    EditProfileErrorCode? errorCode,
    String? errorMessage,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      errorCode: errorCode,
      errorMessage: errorMessage,
    );
  }
}

/// ViewModel para edición de perfil de usuario.
///
/// Responsabilidades:
/// - Gestionar formulario de edición de perfil
/// - Validar campos con Value Objects
/// - Subir foto de perfil a Firebase Storage
/// - Actualizar perfil en Firestore
///
/// Campos editables:
/// - **displayName**: nombre del usuario (requerido)
/// - **phone**: teléfono (opcional)
/// - **heightCm**: altura en cm (requerido, > 0)
/// - **weightKg**: peso en kg (requerido, > 0)
/// - **goal**: objetivo ("Perder peso", "Mantener", "Ganar músculo")
/// - **allergies**: alergias separadas por comas (opcional)
/// - **age**: edad (opcional, 10-120)
/// - **gender**: género ("Hombre", "Mujer", "Otro", opcional)
/// - **photoUrl**: URL de foto de perfil (opcional)
///
/// Validaciones:
/// - Value Objects validan formato de cada campo
/// - DisplayName, Height, Weight son requeridos
/// - Age debe estar en rango 10-120 si se proporciona
///
/// Subida de foto:
/// - uploadPhoto(XFile) sube a Firebase Storage
/// - Genera URL pública
/// - Actualiza photoUrl automáticamente
///
/// Uso:
/// ```dart
/// final vm = EditProfileViewModel(updateUseCase, uploadUseCase, currentProfile);
/// vm.setDisplayName('Nuevo Nombre');
/// vm.setHeightCm('175');
/// await vm.uploadPhoto(imageFile);
/// await vm.save();
/// ```
class EditProfileViewModel extends ChangeNotifier {
  final UpdateUserProfileUseCase _updateProfile;
  final UploadProfilePhotoUseCase _uploadProfilePhoto;
  final UserProfile initialProfile;

  EditProfileState _state = const EditProfileState();
  EditProfileState get state => _state;

  // Controllers de formulario
  late String displayName;
  late String phone;
  late String heightCm;
  late String weightKg;
  late String goal;
  late String allergies;
  late String age;
  late String gender;
  String? photoUrl;
  bool _uploadingPhoto = false;
  String? photoError;

  bool get uploadingPhoto => _uploadingPhoto;

  EditProfileViewModel(
    this._updateProfile,
    this._uploadProfilePhoto,
    this.initialProfile,
  ) {
    // Inicializar con los valores actuales del perfil
    displayName = initialProfile.displayName.value;
    phone = initialProfile.phone?.value ?? '';
    heightCm = initialProfile.height.value.toString();
    weightKg = initialProfile.weight.value.toString();
    goal = initialProfile.goal.displayName;
    allergies = initialProfile.allergies?.value ?? '';
    age = initialProfile.age?.value.toString() ?? '';
    gender = initialProfile.gender?.value ?? '';
    photoUrl = initialProfile.photoUrl;
  }

  void setDisplayName(String value) {
    displayName = value;
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }

  void setHeightCm(String value) {
    heightCm = value;
    notifyListeners();
  }

  void setWeightKg(String value) {
    weightKg = value;
    notifyListeners();
  }

  void setGoal(String value) {
    goal = value;
    notifyListeners();
  }

  void setAllergies(String value) {
    allergies = value;
    notifyListeners();
  }

  void setAge(String value) {
    age = value;
    notifyListeners();
  }

  void setGender(String value) {
    gender = value;
    notifyListeners();
  }

  Future<bool> saveChanges() async {
    _update(
      _state.copyWith(
        status: EditProfileStatus.loading,
        errorCode: null,
        errorMessage: null,
      ),
    );

    try {
      // Validar campos básicos
      if (displayName.trim().isEmpty) {
        _update(
          _state.copyWith(
            status: EditProfileStatus.error,
            errorCode: EditProfileErrorCode.nameRequired,
          ),
        );
        return false;
      }

      final height = int.tryParse(heightCm);
      if (height == null) {
        _update(
          _state.copyWith(
            status: EditProfileStatus.error,
            errorCode: EditProfileErrorCode.heightInvalid,
          ),
        );
        return false;
      }

      final weight = double.tryParse(weightKg);
      if (weight == null) {
        _update(
          _state.copyWith(
            status: EditProfileStatus.error,
            errorCode: EditProfileErrorCode.weightInvalid,
          ),
        );
        return false;
      }

      // Validar edad si se proporciona
      Age? ageVO;
      if (age.trim().isNotEmpty) {
        final ageValue = int.tryParse(age);
        if (ageValue == null) {
          _update(
            _state.copyWith(
              status: EditProfileStatus.error,
              errorCode: EditProfileErrorCode.ageInvalid,
            ),
          );
          return false;
        }
        ageVO = Age(ageValue);
      }

      // Crear Value Objects
      final displayNameVO = DisplayName(displayName.trim());
      final phoneVO = PhoneNumber.tryParse(phone.trim());
      final heightVO = Height(height);
      final weightVO = Weight(weight);
      final goalVO = Goal.fromString(goal);
      final allergiesVO = Allergies.tryParse(allergies.trim());
      final genderVO = gender.trim().isEmpty ? null : Gender(gender.trim());

      // Crear perfil actualizado con Value Objects
      final updatedProfile = UserProfile(
        uid: initialProfile.uid,
        displayName: displayNameVO,
        email: initialProfile.email,
        photoUrl: photoUrl,
        phone: phoneVO,
        height: heightVO,
        weight: weightVO,
        goal: goalVO,
        allergies: allergiesVO,
        age: ageVO,
        gender: genderVO,
      );

      await _updateProfile(updatedProfile);
      _update(_state.copyWith(status: EditProfileStatus.success));
      return true;
    } on ArgumentError catch (e) {
      // Errores de validación de Value Objects
      _update(
        _state.copyWith(
          status: EditProfileStatus.error,
          errorCode: EditProfileErrorCode.validationError,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      _update(
        _state.copyWith(
          status: EditProfileStatus.error,
          errorCode: EditProfileErrorCode.generic,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> uploadPhoto(String filePath) async {
    _uploadingPhoto = true;
    photoError = null;
    notifyListeners();

    try {
      final url = await _uploadProfilePhoto(
        UploadProfilePhotoParams(
          filePath: filePath,
          userId: initialProfile.uid,
        ),
      );
      photoUrl = url;
      _uploadingPhoto = false;
      notifyListeners();
      return true;
    } catch (e) {
      photoError = e.toString();
      _uploadingPhoto = false;
      notifyListeners();
      return false;
    }
  }

  void _update(EditProfileState s) {
    _state = s;
    notifyListeners();
  }
}
