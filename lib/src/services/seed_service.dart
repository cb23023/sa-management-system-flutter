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
        if (id.isEmpty) continue;

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

    // ── users ────────────────────────────────────────────────────────────────
    final users = [
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
        'uid': 'stu-002',
        'fullName': 'Siti Aisyah',
        'email': 'student2@demo.sa',
        'role': 'student',
        'matricId': '2023012346',
        'staffId': '',
        'faculty': 'Faculty of Computing',
        'programme': 'Bachelor of Computer Science',
        'semester': semester,
        'currentSemester': semester,
        'accountStatus': 'Active',
        'maxCreditHours': 9,
        'completedSubjects': ['CSC1101'],
        'themeRole': 'student',
        'avatarInitials': 'SA',
        'createdAt': createdAt,
      },
      {
        'uid': 'stu-003',
        'fullName': 'Haziq Ibrahim',
        'email': 'student3@demo.sa',
        'role': 'student',
        'matricId': '2023012350',
        'staffId': '',
        'faculty': 'Faculty of Computing',
        'programme': 'Bachelor of Information Technology',
        'semester': semester,
        'currentSemester': semester,
        'accountStatus': 'Active',
        'maxCreditHours': 9,
        'completedSubjects': ['CSC1101', 'CSC1201', 'CSC1301'],
        'themeRole': 'student',
        'avatarInitials': 'HI',
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
        'uid': 'tre-001',
        'fullName': 'Nor Azizah',
        'email': 'treasury@demo.sa',
        'role': 'treasury',
        'matricId': '',
        'staffId': 'T10001',
        'faculty': 'Treasury Department',
        'programme': 'Treasury Services',
        'semester': semester,
        'currentSemester': semester,
        'accountStatus': 'Active',
        'maxCreditHours': 0,
        'completedSubjects': <String>[],
        'themeRole': 'treasury',
        'avatarInitials': 'NA',
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
    ].map((user) => {'id': user['email'], ...user}).toList();

    // ── tuition_fees (one doc per student, keyed by uid) ─────────────────────
    final tuitionFees = [
      {
        'id': 'stu-001',              // doc ID = student uid
        'studentId': 'stu-001',
        'studentName': 'Ahmad Malik',
        'matricId': '2023012345',
        'semester': semester,
        'programme': 'Bachelor of Computer Science',
        'programFee': 1200.00,
        'otherFee': 250.00,
        'outstandingAmount': 1450.00,
        'paymentStatus': 'Unpaid',    // Unpaid | Pending | Paid | Verified
        'isBlocked': true,
        'dueDate': '28 Apr 2026',
        'updatedAt': createdAt,
      },
      {
        'id': 'stu-002',
        'studentId': 'stu-002',
        'studentName': 'Siti Aisyah',
        'matricId': '2023012346',
        'semester': semester,
        'programme': 'Bachelor of Computer Science',
        'programFee': 1200.00,
        'otherFee': 200.00,
        'outstandingAmount': 0.00,
        'paymentStatus': 'Paid',
        'isBlocked': false,
        'dueDate': '',
        'updatedAt': createdAt,
      },
      {
        'id': 'stu-003',
        'studentId': 'stu-003',
        'studentName': 'Haziq Ibrahim',
        'matricId': '2023012350',
        'semester': semester,
        'programme': 'Bachelor of Information Technology',
        'programFee': 1100.00,
        'otherFee': 250.00,
        'outstandingAmount': 1350.00,
        'paymentStatus': 'Pending',
        'isBlocked': false,
        'dueDate': '28 Apr 2026',
        'updatedAt': createdAt,
      },
    ];

    // ── payment_transactions ─────────────────────────────────────────────────
    final paymentTransactions = [
      {
        'id': 'txn-001',
        'studentId': 'stu-002',
        'studentName': 'Siti Aisyah',
        'matricId': '2023012346',
        'semester': semester,
        'amount': 1400.00,
        'referenceNo': 'TXN-2026-0401-7823',
        'paymentMethod': 'Online Transfer',
        'bank': 'Maybank',
        'accountOrCard': '123-456-7890',
        'bankRef': 'IB-20260401-XX',
        'status': 'Verified',          // Pending | Verified | Rejected
        'verifiedBy': 'treasury',
        'remarks': '',
        'module': 'tuition',
        'createdAt': '2026-04-01T09:41:00.000Z',
        'updatedAt': '2026-04-01T10:15:00.000Z',
      },
      {
        'id': 'txn-002',
        'studentId': 'stu-003',
        'studentName': 'Haziq Ibrahim',
        'matricId': '2023012350',
        'semester': semester,
        'amount': 1350.00,
        'referenceNo': 'TXN-2026-0402-5102',
        'paymentMethod': 'Credit Card',
        'bank': '',
        'accountOrCard': '4111111111111111',
        'bankRef': 'CC-20260402-YY',
        'status': 'Pending',
        'verifiedBy': '',
        'remarks': '',
        'module': 'tuition',
        'createdAt': '2026-04-02T11:20:00.000Z',
        'updatedAt': '2026-04-02T11:20:00.000Z',
      },
    ];

    // ── notifications ────────────────────────────────────────────────────────
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
      {
        'id': 'notif-stu-002',
        'userId': 'stu-001',
        'title': 'Academic access blocked',
        'message':
            'Your academic access has been restricted by treasury. Please settle your outstanding fee of RM 1,450.00.',
        'type': 'danger',
        'module': 'tuition',
        'isRead': false,
        'createdAt': createdAt,
        'actionLink': '',
      },
      {
        'id': 'notif-stu-003',
        'userId': 'stu-001',
        'title': 'Payment deadline in 3 days',
        'message':
            'Week 5 deadline: 28 Apr 2026. Pay RM 1,450.00 to avoid access block.',
        'type': 'warning',
        'module': 'tuition',
        'isRead': false,
        'createdAt': createdAt,
        'actionLink': '',
      },
      {
        'id': 'notif-stu-004',
        'userId': 'stu-002',
        'title': 'Payment verified',
        'message':
            'Your payment of RM 1,400.00 has been verified by treasury.',
        'type': 'success',
        'module': 'tuition',
        'isRead': false,
        'createdAt': createdAt,
        'actionLink': '',
      },
      {
        'id': 'notif-stu-005',
        'userId': 'stu-002',
        'title': 'Academic access restored',
        'message':
            'Your academic access has been restored. You can now register for classes, exams, and access academic records.',
        'type': 'success',
        'module': 'tuition',
        'isRead': false,
        'createdAt': createdAt,
        'actionLink': '',
      },
    ];

    // ── subjects ─────────────────────────────────────────────────────────────
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
        'activityId': 'act-001',
        'studentId': 'stu-001',
        'present': true,
        'validatedAt': createdAt,
      },
    ];

    return {
      'users': users,
      'tuition_fees': tuitionFees,
      'payment_transactions': paymentTransactions,
      'notifications': notifications,
      'subjects': subjects,
      'subject_offerings': subjectOfferings,
      'registration_periods': registrationPeriods,
      'subject_registrations': subjectRegistrations,
      'activities': activities,
      'activity_registrations': activityRegistrations,
      'credit_claims': creditClaims,
      'attendance_records': attendanceRecords,
    };
  }
}
