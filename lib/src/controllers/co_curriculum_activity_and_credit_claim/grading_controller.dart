part of '../../screens/co_curriculum_activity_and_credit_claim/co_curriculum_module_page.dart';

class GradingController {
  GradingController({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get activities =>
      firestore.collection('activities');

  CollectionReference<Map<String, dynamic>> get activityRegistrations =>
      firestore.collection('activity_registrations');

  CollectionReference<Map<String, dynamic>> get attendanceRecords =>
      firestore.collection('attendance_records');

  CollectionReference<Map<String, dynamic>> get users =>
      firestore.collection('users');

  Future<QuerySnapshot<Map<String, dynamic>>> getSupervisedActivities(
    String lecturerUid,
  ) {
    return activities
        .where('supervisorLecturerId', isEqualTo: lecturerUid)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getActivityRegistrations(
    String activityId,
  ) {
    return activityRegistrations
        .where('activityId', isEqualTo: activityId)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAttendanceRecords(
    String activityId,
  ) {
    return attendanceRecords.where('activityId', isEqualTo: activityId).get();
  }

  Future<Map<String, dynamic>> validateAttendance(
    String activityId,
    String studentId,
  ) async {
    final attendanceSnapshot = await attendanceRecords
        .where('activityId', isEqualTo: activityId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    final hasPresentAttendance = attendanceSnapshot.docs.any(
      (doc) => _isAttendancePresent(doc.data()),
    );
    if (!hasPresentAttendance) {
      return {
        'success': false,
        'message':
            'Marks cannot be saved because attendance has not been recorded as present.',
      };
    }
    return {'success': true, 'message': ''};
  }

  Future<Map<String, dynamic>> updateStudentMark(
    String registrationId,
    int totalMarks,
    String lecturerUid,
  ) async {
    if (totalMarks < 0 || totalMarks > 100) {
      return {
        'success': false,
        'message': 'Total mark must be between 0 and 100.',
      };
    }

    await activityRegistrations.doc(registrationId).set({
      'totalMarks': totalMarks,
      'markStatus': totalMarks >= 40 ? 'passed' : 'failed',
      'evaluatedByLecturerId': lecturerUid,
      'evaluatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return {'success': true, 'message': 'Marks updated successfully.'};
  }

  WriteBatch batch() => firestore.batch();
}

final GradingController _gradingController = GradingController();
