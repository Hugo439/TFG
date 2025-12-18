import 'package:smartmeal/domain/value_objects/value_object.dart';
import 'package:smartmeal/core/constants/app_constants.dart';

class Age extends ValueObject<int> {
  Age(super.input) {
    if (value < AppConstants.minAge || value > AppConstants.maxAge) {
      throw ArgumentError(
        'La edad debe estar entre ${AppConstants.minAge} y ${AppConstants.maxAge} años',
      );
    }
  }
}
