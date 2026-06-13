import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/open_registration_and_subject_registration/registration.dart';

class NotificationController {
  static Future<void> sendApprovalRequest({
    required String studentId,
    required List<RegisteredSubject> subjects,
    required String Function(String, String, String) buildDocId,
  }) async {
    for (final subject in subjects) {
      final docId = buildDocId(studentId, subject.courseCode, subject.section);
      await FirebaseFirestore.instance
          .collection('subject_registrations')
          .doc(docId)
          .set(
            {'status': 'notified', 'notifiedAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true),
          );
    }
  }

  static Future<void> sendStatusUpdate(String studentId, String status) async {
    try {
      final message = status == 'confirmed'
          ? 'Your subject registration has been confirmed.'
          : 'Your subject registration status has been updated to $status.';
      await FirebaseFirestore.instance.collection('notifications').add({
        'recipientId': studentId,
        'message': message,
        'status': status,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NotificationController.sendStatusUpdate: $e');
    }
  }

  static List<RegistrationRequest> getNotificationsByUser(
    NotificationService service,
    String userId,
  ) =>
      service.notifications.toList();

  static void markNotificationRead(String notifId) {
    debugPrint('markNotificationRead: $notifId');
  }

  static void clearUserNotifications(NotificationService service, String userId) {
    service.clearNotifications();
  }
}
