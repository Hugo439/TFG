import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para mensaje de soporte del usuario.
///
/// Responsabilidad:
/// - Almacenar mensajes de soporte enviados por usuarios
///
/// Campos:
/// - **id**: ID único del mensaje
/// - **userId**: ID del usuario que envió el mensaje
/// - **message**: contenido del mensaje
/// - **sentAt**: timestamp de envío
/// - **status**: estado ("pendiente", "respondido", "en proceso")
/// - **category**: categoría opcional ("bug", "feature", "ayuda")
/// - **attachmentUrl**: URL de archivo adjunto opcional
/// - **response**: respuesta del equipo de soporte
/// - **responseDate**: timestamp de respuesta
///
/// Ruta Firestore:
/// ```
/// support_messages/{messageId}
/// ```
///
/// Ejemplo:
/// ```json
/// {
///   "userId": "user123",
///   "message": "No puedo generar menú",
///   "sentAt": "2024-01-15T10:30:00.000Z",
///   "status": "pendiente",
///   "category": "bug",
///   "attachmentUrl": "https://...",
///   "response": "Hemos solucionado el problema",
///   "responseDate": "2024-01-16T14:00:00.000Z"
/// }
/// ```
class SupportMessageModel {
  final String id;
  final String userId;
  final String message;
  final DateTime sentAt;
  final String? status; // pendiente, respondido, en proceso
  final String? category;
  final String? attachmentUrl;
  final String? response;
  final DateTime? responseDate;

  SupportMessageModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.sentAt,
    this.status,
    this.category,
    this.attachmentUrl,
    this.response,
    this.responseDate,
  });

  /// Parsea mensaje desde Map de Firestore.
  ///
  /// Convierte Timestamp a DateTime.
  /// id viene como parámetro separado.
  factory SupportMessageModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return SupportMessageModel(
      id: id,
      userId: map['userId'] ?? '',
      message: map['message'] ?? '',
      sentAt: (map['sentAt'] as Timestamp).toDate(),
      status: map['status'],
      category: map['category'],
      attachmentUrl: map['attachmentUrl'],
      response: map['response'],
      responseDate: map['responseDate'] != null
          ? (map['responseDate'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convierte a Map para persistencia en Firestore.
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'message': message,
    'sentAt': sentAt,
    'status': status,
    'category': category,
    'attachmentUrl': attachmentUrl,
    'response': response,
    'responseDate': responseDate,
  };
}
