import 'package:smartmeal/core/usecases/usecase.dart';
import 'package:smartmeal/core/services/firestore_init_service.dart';

class InitializePriceDatabaseUseCase implements UseCase<void, NoParams> {
  @override
  Future<void> call(NoParams params) async {
    await FirestoreInitService.initializePriceDatabase();
  }
}
