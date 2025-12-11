import 'package:smartmeal/domain/services/shopping/variant_adjustment_service.dart';

void main() {
  final variants = VariantAdjustmentService.detectVariants('fresas congeladas');
  print('Variants: $variants');
  print('Length: ${variants.length}');
}
