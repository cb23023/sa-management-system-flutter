import 'package:cloud_firestore/cloud_firestore.dart';

class SeedSummary {
  const SeedSummary({
    required this.collectionCount,
    required this.documentCount,
  });

  final int collectionCount;
  final int documentCount;
}

class SeedService {
  SeedService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<SeedSummary> seedDemoData() async {
    final collections = _seedCollections();
    final batch = _firestore.batch();
    var documentCount = 0;

    collections.forEach((collectionName, documents) {
      for (final document in documents) {
        final id = (document['id'] ?? document['uid'] ?? '').toString();
        if (id.isEmpty) {
          continue;
        }

        final ref = _firestore.collection(collectionName).doc(id);
        batch.set(ref, document, SetOptions(merge: true));
        documentCount += 1;
      }
    });

    await batch.commit();
    return SeedSummary(
      collectionCount: collections.length,
      documentCount: documentCount,
    );
  }

  Map<String, List<Map<String, dynamic>>> _seedCollections() {
    const semester = 'Semester 2, 2025/2026';
    const createdAt = '2026-04-01T08:00:00.000Z';

    final users =
        [
          {
            'uid': 'stu-001',
            'fullName': 'Ahmad Malik',
            'email': 'student@demo.sa',
            'role': 'student',
            'matricId': '2023012345',
            'staffId': '',
            'faculty': 'Faculty of Computing',
            'programme': 'Bachelor of Computer Science',
            'semester': semester,
            'currentSemester': semester,
            'accountStatus': 'Active',
            'maxCreditHours': 9,
            'completedSubjects': ['CSC1101', 'CSC1201'],
            'themeRole': 'student',
            'avatarInitials': 'AM',
            'createdAt': createdAt,
          },
          {
            'uid': 'lec-001',
            'fullName': 'Dr. Nur Hidayah',
            'email': 'lecturer@demo.sa',
            'role': 'lecturer',
            'matricId': '',
            'staffId': 'L20018',
            'faculty': 'Faculty of Computing',
            'programme': 'Academic Staff',
            'semester': semester,
            'currentSemester': semester,
            'accountStatus': 'Active',
            'maxCreditHours': 0,
            'completedSubjects': <String>[],
            'themeRole': 'lecturer',
            'avatarInitials': 'NH',
            'createdAt': createdAt,
          },
          {
            'uid': 'reg-001',
            'fullName': 'Pn. Siti Nabila',
            'email': 'registrar@demo.sa',
            'role': 'faculty_registrar',
            'matricId': '',
            'staffId': 'R10042',
            'faculty': 'Faculty of Computing',
            'programme': 'Registrar Office',
            'semester': semester,
            'currentSemester': semester,
            'accountStatus': 'Active',
            'maxCreditHours': 0,
            'completedSubjects': <String>[],
            'themeRole': 'faculty_registrar',
            'avatarInitials': 'SN',
            'createdAt': createdAt,
          },
          {
            'uid': 'pad-001',
            'fullName': 'Encik Farhan Adib',
            'email': 'pusatadab@demo.sa',
            'role': 'pusat_adab',
            'matricId': '',
            'staffId': 'PA3409',
            'faculty': 'Student Affairs',
            'programme': 'Pusat Adab',
            'semester': semester,
            'currentSemester': semester,
            'accountStatus': 'Active',
            'maxCreditHours': 0,
            'completedSubjects': <String>[],
            'themeRole': 'pusat_adab',
            'avatarInitials': 'FA',
            'createdAt': createdAt,
          },
          {
            'uid': 'adm-001',
            'fullName': 'System Administrator',
            'email': 'admin@demo.sa',
            'role': 'admin',
            'matricId': '',
            'staffId': 'ADM9001',
            'faculty': 'ICT Department',
            'programme': 'System Administration',
            'semester': semester,
            'currentSemester': semester,
            'accountStatus': 'Active',
            'maxCreditHours': 0,
            'completedSubjects': <String>[],
            'themeRole': 'admin',
            'avatarInitials': 'SA',
            'createdAt': createdAt,
          },
        ].map((user) {
          return {'id': user['email'], ...user};
        }).toList();

    final notifications = [
      {
        'id': 'notif-adm-001',
        'userId': 'adm-001',
        'title': 'Firestore seed ready',
        'message':
            'Initial demo documents can be written from the Settings page.',
        'type': 'info',
        'module': 'system',
        'isRead': false,
        'createdAt': createdAt,
        'actionLink': '',
      },
      {
        'id': 'notif-stu-001',
        'userId': 'stu-001',
        'title': 'Open Registration available',
        'message': 'Module 1 is available for the current semester demo flow.',
        'type': 'success',
        'module': 'module1',
        'isRead': false,
        'createdAt': createdAt,
        'actionLink': '',
      },
    ];

    final subjects = [
      {
        'id': 'sub-001',
        'subjectCode': 'CSC2201',
        'subjectName': 'Database Systems',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': ['CSC1101'],
      },
      {
        'id': 'sub-002',
        'subjectCode': 'CSC2401',
        'subjectName': 'Web Application Development',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
    ];

    final subjectOfferings = [
      {
        'id': 'off-001',
        'subjectId': 'sub-001',
        'semester': semester,
        'year': 2026,
        'lecturerId': 'lec-001',
        'lecturerName': 'Dr. Nur Hidayah',
        'schedule': 'Tue 09:00 - 11:00',
        'seats': 30,
        'seatsTaken': 24,
        'status': 'active',
      },
      {
        'id': 'off-002',
        'subjectId': 'sub-002',
        'semester': semester,
        'year': 2026,
        'lecturerId': 'lec-001',
        'lecturerName': 'Dr. Nur Hidayah',
        'schedule': 'Thu 10:00 - 12:00',
        'seats': 25,
        'seatsTaken': 18,
        'status': 'active',
      },
    ];

    final registrationPeriods = [
      {
        'id': 'reg-period-001',
        'semester': semester,
        'startDate': '2026-04-01',
        'endDate': '2026-04-30',
        'isOpen': true,
        'updatedBy': 'reg-001',
        'updatedAt': createdAt,
      },
    ];

    final subjectRegistrations = [
      {
        'id': 'subreg-001',
        'studentId': 'stu-001',
        'subjectOfferingId': 'off-001',
        'semester': semester,
        'registeredAt': createdAt,
        'status': 'registered',
      },
    ];

    final activities = [
      {
        'id': 'act-001',
        'title': 'Leadership Camp',
        'date': '2026-05-10',
        'venue': 'University Hall',
        'creditValue': 2,
        'description':
            'Leadership and teamwork activity for student development.',
        'supervisorLecturerId': 'lec-001',
        'supervisorLecturerName': 'Dr. Nur Hidayah',
        'maxParticipants': 100,
        'participantsCount': 42,
        'status': 'open',
        'isCompleted': false,
        'createdBy': 'pad-001',
        'createdAt': createdAt,
        'updatedAt': createdAt,
      },
    ];

    final activityRegistrations = [
      {
        'id': 'actreg-001',
        'activityId': 'act-001',
        'studentId': 'stu-001',
        'registeredAt': createdAt,
        'status': 'registered',
      },
    ];

    final creditClaims = [
      {
        'id': 'claim-001',
        'activityId': 'act-001',
        'studentId': 'stu-001',
        'claimStatus': 'pending',
        'attendanceValidated': true,
        'submittedAt': createdAt,
        'reviewedBy': '',
        'reviewedAt': '',
        'remarks': '',
      },
    ];

    final attendanceRecords = [
      {
        'id': 'att-001',
        'attendanceCategory': 'module',
        'sessionId': 'session-001',
        'subjectName': 'Leadership Camp',
        'sessionName': 'Check In Session',
        'studentId': 'stu-001',
        'studentIdentifier': '2023012345',
        'studentName': 'Ahmad Malik',
        'status': 'Present',
        'detail': 'Checked in successfully',
        'submissionMethod': 'QR',
        'classCode': '450001',
        'date': '2026-05-10',
        'time': '08:00 - 10:00',
        'lecturerId': 'lec-001',
        'lecturerName': 'Dr. Nur Hidayah',
        'createdAt': createdAt,
      },
    ];

    final attendanceSessions = [
      {
        'id': 'session-001',
        'attendanceCategory': 'module',
        'subjectName': 'Leadership Camp',
        'sessionName': 'Check In Session',
        'date': '2026-05-10',
        'time': '08:00 - 10:00',
        'classCode': '450001',
        'qrValue': 'QR-session-001',
        'lecturerId': 'lec-001',
        'lecturerName': 'Dr. Nur Hidayah',
        'latitude': 3.0738,
        'longitude': 101.5183,
        'allowedRadiusMeters': 100,
        'isActive': true,
        'sourceOptionId': 'act-001',
        'createdAt': createdAt,
      },
    ];

    return {
      'users': users,
      'notifications': notifications,
      'subjects': subjects,
      'subject_offerings': subjectOfferings,
      'registration_periods': registrationPeriods,
      'subject_registrations': subjectRegistrations,
      'activities': activities,
      'activity_registrations': activityRegistrations,
      'credit_claims': creditClaims,
      'attendance_sessions': attendanceSessions,
      'attendance_records': attendanceRecords,
    };
  }
}
