import 'package:smartmeal/domain/services/shopping/density_service.dart';

void main() {
  print('huevo: ${DensityService.suggestUnitKind('huevo')}');
  print('aguacate: ${DensityService.suggestUnitKind('aguacate')}');
  print('leche: ${DensityService.suggestUnitKind('leche')}');
}
