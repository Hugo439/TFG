import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartmeal/domain/entities/support_message.dart';
import 'package:smartmeal/domain/entities/faq.dart';
import 'package:smartmeal/domain/usecases/support/get_support_messages_usecase.dart';
import 'package:smartmeal/domain/repositories/support_message_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smartmeal/data/models/faq_model.dart';
import 'package:smartmeal/data/mappers/faq_mapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartmeal/domain/value_objects/support_message_content.dart';
import 'package:smartmeal/domain/value_objects/support_category.dart';
import 'package:smartmeal/data/datasources/local/faq_local_datasource.dart';

/// ViewModel para pantalla de soporte.
///
/// Responsabilidades:
/// - Cargar historial de mensajes de soporte del usuario
/// - Enviar nuevos mensajes de soporte
/// - Subir archivos adjuntos a Firebase Storage
/// - Cargar FAQs (Preguntas Frecuentes)
///
/// Funcionalidades:
/// 1. **loadMessages(userId)**: carga historial de mensajes
/// 2. **sendSupportMessage()**: envía mensaje con adjunto opcional
/// 3. **loadFAQs()**: carga FAQs desde JSON local o Firestore
///
/// Mensaje de soporte incluye:
/// - **message**: contenido del mensaje (validado con Value Object)
/// - **category**: categoría ("bug", "feature", "ayuda", etc.)
/// - **attachment**: archivo adjunto opcional (imagen/documento)
///
/// Adjuntos:
/// - Se suben a Firebase Storage en support_attachments/
/// - Genera URL pública
/// - Se almacena en supportMessageRepository
///
/// Estados:
/// - **loadingHistory**: cargando mensajes
/// - **loadingForm**: enviando mensaje
/// - **success**: mensaje enviado correctamente
/// - **formError**: error al enviar mensaje
/// - **historyError**: error al cargar historial
///
/// Uso:
/// ```dart
/// final vm = Provider.of<SupportViewModel>(context);
/// await vm.loadMessages(userId);
/// await vm.sendSupportMessage(
///   'Tengo un problema con el menú',
///   'bug',
///   imageFile
/// );
/// ```
class SupportViewModel extends ChangeNotifier {
  final GetSupportMessagesUseCase? getSupportMessagesUseCase;
  final SupportMessageRepository? supportMessageRepository;
  final FAQLocalDatasource? faqLocalDatasource;

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

  SupportViewModel({
    this.getSupportMessagesUseCase,
    this.supportMessageRepository,
    this.faqLocalDatasource,
  });

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

  /// Envía mensaje de soporte a Firestore.
  ///
  /// Parámetros:
  /// - **message**: contenido del mensaje
  /// - **category**: categoría ("bug", "feature", "ayuda", etc.)
  /// - **attachment**: archivo adjunto opcional (imagen/documento)
  ///
  /// Validaciones:
  /// - SupportMessageContent valida mensaje no vacío
  /// - SupportCategory valida categoría
  ///
  /// Flujo:
  /// 1. Valida message y category con Value Objects
  /// 2. Si attachment != null:
  ///    - Sube a Firebase Storage
  ///    - Obtiene URL pública
  /// 3. Crea SupportMessage
  /// 4. Guarda en supportMessageRepository
  ///
  /// Retorna true si éxito, false si error.
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
          final storageRef = FirebaseStorage.instance.ref().child(
            'support_attachments/${DateTime.now().millisecondsSinceEpoch}_${attachment.name}',
          );
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
      // 1. Intenta cargar desde caché local
      if (faqLocalDatasource != null) {
        final cachedFAQs = await faqLocalDatasource!.getLatest(locale);
        if (cachedFAQs != null && cachedFAQs.isNotEmpty) {
          debugPrint('Cargando FAQs desde caché local ($locale)');
          _faqs = cachedFAQs
              .map((model) => FAQMapper.toEntity(model, locale))
              .toList();
          notifyListeners();
          return;
        }
      }

      // 2. Si no hay caché, carga desde Firestore
      debugPrint('Cargando FAQs desde Firestore ($locale)');
      final query = await FirebaseFirestore.instance
          .collection('faqs')
          .orderBy('order')
          .get();

      final faqModels = query.docs
          .map((doc) => FAQModel.fromMap(doc.data(), doc.id))
          .toList();

      // 3. Guarda en caché local
      if (faqLocalDatasource != null && faqModels.isNotEmpty) {
        await faqLocalDatasource!.saveLatest(faqModels, locale);
      }

      // 4. Convierte a entidades y notifica
      _faqs = faqModels
          .map((model) => FAQMapper.toEntity(model, locale))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar FAQs: $e');

      // 5. Fallback: intenta caché local si Firestore falla
      if (faqLocalDatasource != null) {
        final cachedFAQs = await faqLocalDatasource!.getLatest(locale);
        if (cachedFAQs != null && cachedFAQs.isNotEmpty) {
          debugPrint('Cargando FAQs desde caché de fallback ($locale)');
          _faqs = cachedFAQs
              .map((model) => FAQMapper.toEntity(model, locale))
              .toList();
          notifyListeners();
          return;
        }
      }

      // 6. Si todo falla, deja lista vacía
      _faqs = [];
      notifyListeners();
    }
  }

  // Limpia el estado de éxito/error
  void clearFormState() {
    formError = null;
    success = false;
    notifyListeners();
  }
}
