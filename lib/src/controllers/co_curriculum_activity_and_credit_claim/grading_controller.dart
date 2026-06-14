// =============================================================================
// SAMMS-PACK-210 | grading_controller.dart
// Class Type    : Controller
// Responsibility: Manages Firestore read and write operations for the Co-
//   Curriculum grading workflow. Provides collection references for supervised
//   activities, registrations, attendance, and users. Validates that student
//   attendance is recorded as present before allowing mark entry, then writes
//   totalMarks, markStatus, and evaluator metadata to the registration document.
// Attributes   : firestore (FirebaseFirestore), activities, activityRegistrations,
//                attendanceRecords, users (CollectionReference)
// Methods      : getSupervisedActivities, getActivityRegistrations,
//                getAttendanceRecords, validateAttendance, updateStudentMark, batch
// =============================================================================

part of '../../screens/co_curriculum_activity_and_credit_claim/co_curriculum_module_page.dart';

// GradingController — Firestore controller for Co-Curriculum grading operations.
// Instantiated once as _gradingController and shared across all screens in
// this library.
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

  // getSupervisedActivities — returns all activities where supervisorLecturerId
  //   matches the given lecturerUid.
  Future<QuerySnapshot<Map<String, dynamic>>> getSupervisedActivities(
    String lecturerUid,
  ) {
    return activities
        .where('supervisorLecturerId', isEqualTo: lecturerUid)
        .get();
  }

  // getActivityRegistrations — returns all activity_registrations documents for
  //   a given activityId.
  Future<QuerySnapshot<Map<String, dynamic>>> getActivityRegistrations(
    String activityId,
  ) {
    return activityRegistrations
        .where('activityId', isEqualTo: activityId)
        .get();
  }

  // getAttendanceRecords — returns all attendance_records for a given activityId.
  Future<QuerySnapshot<Map<String, dynamic>>> getAttendanceRecords(
    String activityId,
  ) {
    return attendanceRecords.where('activityId', isEqualTo: activityId).get();
  }

  // validateAttendance — queries attendance_records for the activityId+studentId
  //   pair and checks whether any record is marked present via _isAttendancePresent.
  //   Returns {success: false, message} if no present record exists; otherwise
  //   {success: true, message: ''}.
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

  // updateStudentMark — validates that totalMarks is in the range 0–100, then
  //   writes totalMarks, markStatus ('passed' if >= 40, else 'failed'),
  //   evaluatedByLecturerId, and evaluatedAt to the registration document.
  //   Returns {success, message}.
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

  // batch — returns a new Firestore WriteBatch for atomic multi-document writes.
  WriteBatch batch() => firestore.batch();
}

final GradingController _gradingController = GradingController();
