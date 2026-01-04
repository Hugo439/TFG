import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/support_message.dart';
import '../../domain/repositories/support_message_repository.dart';
import '../mappers/support_message_mapper.dart';
import '../models/support_message_model.dart';

/// Implementación del repositorio de mensajes de soporte.
///
/// Responsabilidad:
/// - CRUD de mensajes de soporte en Firestore
/// - Mapeo entre modelos y entidades
///
/// Colección Firestore: 'support_messages'
///
/// Operaciones:
/// - **getMessagesByUser**: obtiene mensajes de un usuario ordenados por fecha desc
/// - **sendMessage**: crea nuevo mensaje de soporte
/// - **updateMessage**: actualiza mensaje (usado por admin para responder)
///
/// Flujo típico:
/// 1. Usuario envía mensaje desde app
/// 2. sendMessage() crea documento en Firestore
/// 3. Admin responde desde panel
/// 4. updateMessage() añade response y responseDate
/// 5. Usuario ve respuesta con getMessagesByUser()
///
/// Uso:
/// ```dart
/// final repo = SupportMessageRepositoryImpl();
///
/// // Enviar mensaje
/// await repo.sendMessage(SupportMessage(...));
///
/// // Ver historial
/// final messages = await repo.getMessagesByUser(userId);
/// ```
class SupportMessageRepositoryImpl implements SupportMessageRepository {
  final FirebaseFirestore firestore;

  SupportMessageRepositoryImpl({FirebaseFirestore? firestoreInstance})
    : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  @override
  Future<List<SupportMessage>> getMessagesByUser(String userId) async {
    final query = await firestore
        .collection('support_messages')
        .where('userId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .get();

    return query.docs
        .map(
          (doc) => SupportMessageMapper.toEntity(
            SupportMessageModel.fromMap(doc.data(), id: doc.id),
          ),
        )
        .toList();
  }

  @override
  Future<void> sendMessage(SupportMessage message) async {
    final model = SupportMessageMapper.toModel(message);
    await firestore.collection('support_messages').add(model.toMap());
  }

  @override
  Future<void> updateMessage(SupportMessage message) async {
    final model = SupportMessageMapper.toModel(message);
    await firestore
        .collection('support_messages')
        .doc(model.id)
        .update(model.toMap());
  }
}
