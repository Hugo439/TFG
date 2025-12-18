import 'package:smartmeal/domain/value_objects/value_object.dart';

class Allergies extends ValueObject<String> {
  Allergies(String value) : super(value.trim());

  static Allergies? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return Allergies(value);
  }

  bool get hasAllergies => value.isNotEmpty;

  List<String> get list {
    if (!hasAllergies) return [];
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  bool contains(String allergen) {
    return list.any((a) => a.toLowerCase().contains(allergen.toLowerCase()));
  }
}
