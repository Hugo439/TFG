import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/support_message.dart';
import 'package:smartmeal/domain/usecases/get_support_messages_usecase.dart';
import 'package:smartmeal/domain/repositories/support_message_repository.dart'; // Asegúrate de importar el repositorio

class SupportViewModel extends ChangeNotifier {
  final GetSupportMessagesUseCase? getSupportMessagesUseCase;
  final SupportMessageRepository? supportMessageRepository; // Añade el repositorio

  List<SupportMessage> _messages = [];
  List<SupportMessage> get messages => _messages;

  bool loading = false;
  String? error;
  bool success = false;

  SupportViewModel({this.getSupportMessagesUseCase, this.supportMessageRepository});

  Future<void> loadMessages(String userId) async {
    if (getSupportMessagesUseCase == null) return;
    loading = true;
    error = null;
    notifyListeners();

    try {
      _messages = await getSupportMessagesUseCase!.call(userId);
    } catch (e) {
      error = 'Error al cargar los mensajes';
    }

    loading = false;
    notifyListeners();
  }

  Future<void> sendSupportMessage(String message) async {
    if (supportMessageRepository == null) return;
    loading = true;
    error = null;
    success = false;
    notifyListeners();

    try {
      final supportMessage = SupportMessage(
        id: '', // Firestore lo genera
        userId: 'user_id_actual', // Debes obtener el userId real
        message: message,
        sentAt: DateTime.now(),
        status: 'pendiente',
        category: null,
        attachmentUrl: null,
        response: null,
        responseDate: null,
      );
      await supportMessageRepository!.sendMessage(supportMessage);
      success = true;
      await loadMessages(supportMessage.userId); // Recarga el historial
    } catch (e) {
      error = 'Error al enviar el mensaje';
    }

    loading = false;
    notifyListeners();
  }
}