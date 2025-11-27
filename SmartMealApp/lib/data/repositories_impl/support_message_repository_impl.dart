import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/support_message.dart';
import '../../domain/repositories/support_message_repository.dart';
import '../mappers/support_message_mapper.dart';
import '../models/support_message_model.dart';

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
        .map((doc) => SupportMessageMapper.toEntity(
              SupportMessageModel.fromMap(doc.data(), id: doc.id),
            ))
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