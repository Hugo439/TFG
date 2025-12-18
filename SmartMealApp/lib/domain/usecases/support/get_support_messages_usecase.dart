import '../../entities/support_message.dart';
import '../../repositories/support_message_repository.dart';

class GetSupportMessagesUseCase {
  final SupportMessageRepository repository;

  GetSupportMessagesUseCase(this.repository);

  Future<List<SupportMessage>> call(String userId) async {
    return await repository.getMessagesByUser(userId);
  }
}
