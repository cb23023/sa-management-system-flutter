import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

// SDD TuitionNotification model:
// stores reminders, verification results, and academic access notices.
class TuitionNotification {
  const TuitionNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.module,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String module;
  final bool isRead;
  final String createdAt;

  Color get bulletColor {
    switch (type) {
      case 'danger':
        return AppColors.danger;
      case 'warning':
        return AppColors.warning;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.studentBlue;
    }
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  factory TuitionNotification.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TuitionNotification(
      id: doc.id,
      userId: (data['userId'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      message: (data['message'] ?? '').toString(),
      type: (data['type'] ?? 'info').toString(),
      module: (data['module'] ?? 'tuition').toString(),
      isRead: (data['isRead'] as bool?) ?? false,
      createdAt: (data['createdAt'] ?? '').toString(),
    );
  }
}
