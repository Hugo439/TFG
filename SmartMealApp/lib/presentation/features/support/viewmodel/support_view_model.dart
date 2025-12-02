import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/support_message.dart';
import 'package:smartmeal/domain/entities/faq.dart';
import 'package:smartmeal/domain/usecases/get_support_messages_usecase.dart';
import 'package:smartmeal/domain/repositories/support_message_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smartmeal/data/models/faq_model.dart';
import 'package:smartmeal/data/mappers/faq_mapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/domain/value_objects/support_message_content.dart';
import 'package:smartmeal/domain/value_objects/support_category.dart';

class SupportViewModel extends ChangeNotifier {
  final GetSupportMessagesUseCase? getSupportMessagesUseCase;
  final SupportMessageRepository? supportMessageRepository;

  List<SupportMessage> _messages = [];
  List<SupportMessage> get messages => _messages;

  List<FAQ> _faqs = [];
  List<FAQ> get faqs => _faqs;

  bool _loadingHistory = false;
  bool get loadingHistory => _loadingHistory;

  bool _loadingForm = false;
  bool get loading => _loadingForm;

  String? formError;
  String? historyError;
  bool success = false;

  SupportViewModel({this.getSupportMessagesUseCase, this.supportMessageRepository});

  // Obtén el userId del usuario autenticado
  String get userId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }

  Future<void> loadMessages(String userId) async {
    if (getSupportMessagesUseCase == null) {
      debugPrint('getSupportMessagesUseCase es null');
      return;
    }
    
    _loadingHistory = true;
    historyError = null;
    notifyListeners();

    try {
      debugPrint('Cargando mensajes para userId: $userId');
      _messages = await getSupportMessagesUseCase!.call(userId);
      debugPrint('Mensajes cargados: ${_messages.length}');
    } catch (e) {
      historyError = 'Error al cargar los mensajes';
      debugPrint('Error al cargar mensajes: $e');
    }

    _loadingHistory = false;
    notifyListeners();
  }

  Future<bool> sendSupportMessage(
    String message,
    String? category,
    XFile? attachment,
  ) async {
    if (supportMessageRepository == null) return false;
    
    // VALIDAR usando Value Objects
    try {
      final messageVO = SupportMessageContent(message);
      final categoryVO = SupportCategory(category);
      
      _loadingForm = true;
      formError = null;
      success = false;
      notifyListeners();

      String? attachmentUrl;
      if (attachment != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('support_attachments/${DateTime.now().millisecondsSinceEpoch}_${attachment.name}');
          final uploadTask = await storageRef.putFile(File(attachment.path));
          attachmentUrl = await uploadTask.ref.getDownloadURL();
        } catch (e) {
          formError = 'Error al subir el archivo adjunto';
          _loadingForm = false;
          notifyListeners();
          return false;
        }
      }

      try {
        final supportMessage = SupportMessage(
          id: '',
          userId: userId,
          message: messageVO.value,
          sentAt: DateTime.now(),
          status: 'pendiente',
          category: categoryVO.value,
          attachmentUrl: attachmentUrl,
          response: null,
          responseDate: null,
        );
        await supportMessageRepository!.sendMessage(supportMessage);
        success = true;
        await loadMessages(userId);
      } catch (e) {
        formError = 'Error al enviar el mensaje';
        debugPrint('Error al enviar mensaje: $e');
        _loadingForm = false;
        notifyListeners();
        return false;
      }

      _loadingForm = false;
      notifyListeners();
      return true;
      
    } on ArgumentError catch (e) {
      // Captura errores de validación de Value Objects
      formError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadFAQs(String locale) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('faqs')
          .orderBy('order')
          .get();
    
      _faqs = query.docs
          .map((doc) => FAQMapper.toEntity(
                FAQModel.fromMap(doc.data(), doc.id),
                locale,
              ))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar FAQs: $e');
    }
  }

  // Limpia el estado de éxito/error
  void clearFormState() {
    formError = null;
    success = false;
    notifyListeners();
  }
}