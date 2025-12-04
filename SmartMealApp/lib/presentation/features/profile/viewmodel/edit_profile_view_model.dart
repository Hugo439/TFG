import 'package:flutter/foundation.dart';
import 'package:smartmeal/domain/entities/user_profile.dart';
import 'package:smartmeal/domain/usecases/update_user_profile_usecase.dart';
import 'package:smartmeal/domain/value_objects/allergies.dart';
import 'package:smartmeal/domain/value_objects/display_name.dart';
import 'package:smartmeal/domain/value_objects/goal.dart';
import 'package:smartmeal/domain/value_objects/height.dart';
import 'package:smartmeal/domain/value_objects/phone_number.dart';
import 'package:smartmeal/domain/value_objects/weight.dart';
import 'package:smartmeal/domain/value_objects/age.dart';
import 'package:smartmeal/domain/value_objects/gender.dart';

enum EditProfileStatus { idle, loading, success, error }

enum EditProfileErrorCode {
  nameRequired,
  heightInvalid,
  weightInvalid,
  ageInvalid,
  validationError,
  generic,
}

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

class EditProfileViewModel extends ChangeNotifier {
  final UpdateUserProfileUseCase _updateProfile;
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

  EditProfileViewModel(this._updateProfile, this.initialProfile) {
    // Inicializar con los valores actuales del perfil
    displayName = initialProfile.displayName.value;
    phone = initialProfile.phone?.value ?? '';
    heightCm = initialProfile.height.value.toString();
    weightKg = initialProfile.weight.value.toString();
    goal = initialProfile.goal.displayName;
    allergies = initialProfile.allergies?.value ?? '';
    age = initialProfile.age?.value.toString() ?? '';
    gender = initialProfile.gender?.value ?? '';
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
    _update(_state.copyWith(
      status: EditProfileStatus.loading,
      errorCode: null,
      errorMessage: null,
    ));

    try {
      // Validar campos básicos
      if (displayName.trim().isEmpty) {
        _update(_state.copyWith(
          status: EditProfileStatus.error,
          errorCode: EditProfileErrorCode.nameRequired,
        ));
        return false;
      }

      final height = int.tryParse(heightCm);
      if (height == null) {
        _update(_state.copyWith(
          status: EditProfileStatus.error,
          errorCode: EditProfileErrorCode.heightInvalid,
        ));
        return false;
      }

      final weight = double.tryParse(weightKg);
      if (weight == null) {
        _update(_state.copyWith(
          status: EditProfileStatus.error,
          errorCode: EditProfileErrorCode.weightInvalid,
        ));
        return false;
      }

      // Validar edad si se proporciona
      Age? ageVO;
      if (age.trim().isNotEmpty) {
        final ageValue = int.tryParse(age);
        if (ageValue == null) {
          _update(_state.copyWith(
            status: EditProfileStatus.error,
            errorCode: EditProfileErrorCode.ageInvalid,
          ));
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
        photoUrl: initialProfile.photoUrl,
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
      _update(_state.copyWith(
        status: EditProfileStatus.error,
        errorCode: EditProfileErrorCode.validationError,
        errorMessage: e.message,
      ));
      return false;
    } catch (e) {
      _update(_state.copyWith(
        status: EditProfileStatus.error,
        errorCode: EditProfileErrorCode.generic,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  void _update(EditProfileState s) {
    _state = s;
    notifyListeners();
  }
}