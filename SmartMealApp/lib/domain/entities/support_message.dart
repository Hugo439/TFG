class SupportMessage {
  final String id;
  final String userId;
  final String message;
  final DateTime sentAt;
  final String? status;
  final String? category;
  final String? attachmentUrl;
  final String? response;
  final DateTime? responseDate;

  SupportMessage({
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
}