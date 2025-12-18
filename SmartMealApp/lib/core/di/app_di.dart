import 'package:get_it/get_it.dart';
import 'package:smartmeal/domain/repositories/app_repository.dart';
import 'package:smartmeal/data/repositories_impl/app_repository_impl.dart';
import 'package:smartmeal/domain/usecases/initialize_app_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/check_auth_status_usecase.dart';

void setupAppDI(GetIt sl) {
  // Repository
  sl.registerLazySingleton<AppRepository>(() => AppRepositoryImpl());

  // Use cases
  sl.registerLazySingleton(() => InitializeAppUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
}
