import '../../domain/entities/support_message.dart';
import '../models/support_message_model.dart';

class SupportMessageMapper {
  static SupportMessage toEntity(SupportMessageModel model) {
    return SupportMessage(
      id: model.id,
      userId: model.userId,
      message: model.message,
      sentAt: model.sentAt,
      status: model.status,
      category: model.category,
      attachmentUrl: model.attachmentUrl,
      response: model.response,
      responseDate: model.responseDate,
    );
  }

  static SupportMessageModel toModel(SupportMessage entity) {
    return SupportMessageModel(
      id: entity.id,
      userId: entity.userId,
      message: entity.message,
      sentAt: entity.sentAt,
      status: entity.status,
      category: entity.category,
      attachmentUrl: entity.attachmentUrl,
      response: entity.response,
      responseDate: entity.responseDate,
    );
  }
}
