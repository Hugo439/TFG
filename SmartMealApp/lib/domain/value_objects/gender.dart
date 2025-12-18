import 'package:smartmeal/domain/value_objects/value_object.dart';

enum GenderType { male, female, other }

class Gender extends ValueObject<String> {
  final GenderType type;

  Gender(String input)
    : type = _parseGenderType(input.trim()),
      super(input.trim()) {
    if (value.isEmpty) {
      throw ArgumentError('El género no puede estar vacío');
    }
  }

  static GenderType _parseGenderType(String value) {
    final normalized = value.toLowerCase();
    if (normalized == 'masculino' ||
        normalized == 'hombre' ||
        normalized == 'male' ||
        normalized == 'm') {
      return GenderType.male;
    } else if (normalized == 'femenino' ||
        normalized == 'mujer' ||
        normalized == 'female' ||
        normalized == 'f') {
      return GenderType.female;
    } else {
      return GenderType.other;
    }
  }

  String get displayName {
    switch (type) {
      case GenderType.male:
        return 'Masculino';
      case GenderType.female:
        return 'Femenino';
      case GenderType.other:
        return 'Otro';
    }
  }

  bool get isMale => type == GenderType.male;
  bool get isFemale => type == GenderType.female;
}
