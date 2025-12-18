import 'package:get_it/get_it.dart';
import 'package:smartmeal/domain/repositories/auth_repository.dart';
import 'package:smartmeal/data/repositories_impl/auth_repository_impl.dart';
import 'package:smartmeal/domain/usecases/auth/sign_in_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/sign_up_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/sign_out_usecase.dart';
import 'package:smartmeal/domain/usecases/user/get_current_user_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/load_saved_credentials_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/save_credentials_usecase.dart';
import 'package:smartmeal/domain/usecases/auth/delete_account_usecase.dart';

void setupAuthDI(GetIt sl) {
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authDataSource: sl(),
      authLocalDataSource: sl(),
      firestoreDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LoadSavedCredentialsUseCase(sl()));
  sl.registerLazySingleton(() => SaveCredentialsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
}
