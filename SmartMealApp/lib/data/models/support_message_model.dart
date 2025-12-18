import 'package:cloud_firestore/cloud_firestore.dart';

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
