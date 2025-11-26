import 'package:cloud_firestore/cloud_firestore.dart';
import 'day_menu_model.dart';

class WeeklyMenuModel {
  final String id;
  final String userId;
  final String? name;
  final DateTime weekStartDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<DayMenuModel> days;

  WeeklyMenuModel({
    required this.id,
    required this.userId,
    this.name,
    required this.weekStartDate,
    required this.createdAt,
    this.updatedAt,
    required this.days,
  });

  factory WeeklyMenuModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      return WeeklyMenuModel(
        id: doc.id,
        userId: data['userId'] ?? '',
        name: data['name'],
        weekStartDate: (data['weekStart'] as Timestamp).toDate(),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
        days: (data['days'] as List<dynamic>)
            .map((d) => DayMenuModel.fromMap(d as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw Exception('Error al convertir WeeklyMenuModel: $e');
    }
  }
}