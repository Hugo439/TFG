import 'package:get_it/get_it.dart';
import 'package:smartmeal/domain/repositories/support_message_repository.dart';
import 'package:smartmeal/data/repositories_impl/support_message_repository_impl.dart';
import 'package:smartmeal/domain/usecases/support/get_support_messages_usecase.dart';

void setupSupportDI(GetIt sl) {
  // Repository
  sl.registerLazySingleton<SupportMessageRepository>(
    () => SupportMessageRepositoryImpl(),
  );

  // Use case
  sl.registerLazySingleton(() => GetSupportMessagesUseCase(sl()));
}
