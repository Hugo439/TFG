import '../entities/support_message.dart';

abstract class SupportMessageRepository {
  Future<List<SupportMessage>> getMessagesByUser(String userId);
  Future<void> sendMessage(SupportMessage message);
  Future<void> updateMessage(SupportMessage message);
}
