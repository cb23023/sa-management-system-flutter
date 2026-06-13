import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/app_user.dart';
import '../../models/open_registration_and_subject_registration/course.dart';

class CourseController {
  static Future<QuerySnapshot<Map<String, dynamic>>> getAllCourses() =>
      FirebaseFirestore.instance.collection('subjects').get();

  static List<String> getSectionsByCourse(List<Course> courses, String courseCode) {
    final course = courses.firstWhere(
      (c) => c.code == courseCode,
      orElse: () => Course(
        code: '',
        name: '',
        credits: 0,
        schedule: '',
        instructor: '',
        capacity: 0,
        enrolled: 0,
        sections: {},
        sessionDetails: {},
      ),
    );
    return course.sections.keys.toList();
  }

  static Future<String> addCourse(Course course) async {
    final allDocs = await FirebaseFirestore.instance.collection('subjects').get();
    int maxNum = 0;
    for (final doc in allDocs.docs) {
      final match = RegExp(r'^sub-(\d+)$').firstMatch(doc.id);
      if (match != null) {
        final n = int.tryParse(match.group(1)!) ?? 0;
        if (n > maxNum) maxNum = n;
      }
    }
    final docId = 'sub-${(maxNum + 1).toString().padLeft(3, '0')}';
    await FirebaseFirestore.instance.collection('subjects').doc(docId).set({
      'id': docId,
      'subjectCode': course.code,
      'subjectName': course.name,
      'creditHour': course.credits,
      'faculty': 'Faculty of Computing',
      'prerequisites': <String>[],
    });
    return docId;
  }

  static Future<void> updateCourse(
    DocumentReference subjectRef,
    String section,
    AppUser lecturer,
  ) async {
    await subjectRef.set({
      'assignedLecturersBySection.$section': lecturer.fullName,
      'assignedLecturerIdsBySection.$section': lecturer.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> deleteCourse(String subjectCode) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .where('subjectCode', isEqualTo: subjectCode)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
      }
    } catch (e) {
      debugPrint('CourseController.deleteCourse: $e');
    }
  }
}
