import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RegistrationController {
  static Future<void> submitRegistration({
    required String docId,
    required String studentId,
    required String studentName,
    required String subjectCode,
    required String subjectName,
    required String section,
    required String lab,
    required String semester,
  }) async {
    await FirebaseFirestore.instance
        .collection('subject_registrations')
        .doc(docId)
        .set({
      'id': docId,
      'studentId': studentId,
      'studentName': studentName,
      'subjectCode': subjectCode,
      'subjectName': subjectName,
      'section': section,
      'lab': lab,
      'semester': semester,
      'status': 'registered',
      'registeredAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateRegistrationStatus({
    required String studentName,
    required String subjectCode,
    required String status,
    required String confirmedBy,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('subject_registrations')
        .where('studentName', isEqualTo: studentName)
        .where('subjectCode', isEqualTo: subjectCode)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'status': status,
        'confirmedAt': FieldValue.serverTimestamp(),
        'confirmedBy': confirmedBy,
      });
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getRegistrationsByStudent(
    String studentId,
  ) =>
      FirebaseFirestore.instance
          .collection('subject_registrations')
          .where('studentId', isEqualTo: studentId)
          .get();

  static Future<List<Map<String, dynamic>>> getRegistrationsByLecturer(
    String lecturerId,
  ) async {
    try {
      final offeringsSnap = await FirebaseFirestore.instance
          .collection('subject_offerings')
          .where('lecturerId', isEqualTo: lecturerId)
          .get();

      final results = <Map<String, dynamic>>[];
      for (final offering in offeringsSnap.docs) {
        final data = offering.data();
        final subjectCode = data['subjectCode']?.toString() ?? '';
        final section = data['section']?.toString() ?? '';
        if (subjectCode.isEmpty || section.isEmpty) continue;

        final regSnap = await FirebaseFirestore.instance
            .collection('subject_registrations')
            .where('subjectCode', isEqualTo: subjectCode)
            .where('section', isEqualTo: section)
            .get();

        for (final reg in regSnap.docs) {
          results.add(reg.data());
        }
      }
      return results;
    } catch (e) {
      debugPrint('RegistrationController.getRegistrationsByLecturer: $e');
      return [];
    }
  }

  static Future<void> updateSettings({
    required String docId,
    bool? isOpen,
    String? startDate,
    String? endDate,
  }) async {
    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (isOpen != null) data['isOpen'] = isOpen;
    if (startDate != null) data['startDate'] = startDate;
    if (endDate != null) data['endDate'] = endDate;
    await FirebaseFirestore.instance
        .collection('registration_periods')
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }
}
