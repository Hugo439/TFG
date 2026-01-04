import '../../domain/entities/support_message.dart';
import '../models/support_message_model.dart';

/// Mapper para convertir entre SupportMessage (dominio) y SupportMessageModel (datos).
///
/// Conversiones:
/// - **toEntity**: Model → Entity
/// - **toModel**: Entity → Model
///
/// Campos:
/// - **id**: identificador único del mensaje
/// - **userId**: quién envió el mensaje
/// - **message**: contenido del mensaje de soporte
/// - **sentAt**: timestamp de envío
/// - **status**: estado del mensaje (pendiente, resuelto, etc.)
/// - **category**: categoría del problema
/// - **attachmentUrl**: URL de archivo adjunto (opcional)
/// - **response**: respuesta del equipo de soporte (opcional)
/// - **responseDate**: fecha de respuesta (opcional)
///
/// Nota: Este mapper es simétrico (entity y model tienen misma estructura).
class SupportMessageMapper {
  /// Convierte SupportMessageModel a SupportMessage entity.
  ///
  /// [model] - Modelo desde Firestore.
  ///
  /// Returns: Entidad del dominio con mismos campos.
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

  /// Convierte SupportMessage entity a SupportMessageModel.
  ///
  /// [entity] - Entidad del dominio.
  ///
  /// Returns: Modelo listo para Firestore.
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
