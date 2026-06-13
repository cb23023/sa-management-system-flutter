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
        batch.set(ref, document, SetOptions(merge: false));
        documentCount += 1;
      }
    });

    await batch.commit();
    return SeedSummary(
      collectionCount: collections.length,
      documentCount: documentCount,
    );
  }

  Future<int> seedSubjectsOnly() async {
    final subjects = _seedCollections()['subjects'] ?? const [];
    final batch = _firestore.batch();

    for (final subject in subjects) {
      final id = (subject['id'] ?? '').toString();
      if (id.isEmpty) {
        continue;
      }

      final ref = _firestore.collection('subjects').doc(id);
      batch.set(ref, subject, SetOptions(merge: false));
    }

    await batch.commit();
    return subjects.length;
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
            'role': 'faculty',
            'matricId': '',
            'staffId': 'R10042',
            'faculty': 'Faculty of Computing',
            'programme': 'Registrar Office',
            'semester': semester,
            'currentSemester': semester,
            'accountStatus': 'Active',
            'maxCreditHours': 0,
            'completedSubjects': <String>[],
            'themeRole': 'faculty',
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

    final subjectSections = <String, Map<String, List<String>>>{
      'BCI1023': {
        '01': ['01A', '01B'],
        '02': ['02A', '02B'],
      },
      'BCI1143': {
        '01': ['01A', '01B', '01C'],
      },
      'BCI1033': {
        '08A': ['08P'],
        '08B': ['08P'],
      },
      'BCI1093': {
        '09': ['09P'],
        '10': ['10P'],
        '11': ['11P'],
      },
      'BCI2033': {
        '01': ['01A'],
      },
      'BCI2313': {
        '01': ['01A'],
      },
      'BCI2323': {
        '01': ['01A'],
      },
      'BCI2353': {
        '01': ['01A'],
      },
      'BCI3302': {
        '01': ['01A'],
      },
      'BCI3313': {
        '01': ['01A'],
      },
      'BCI3323': {
        '01': ['01A'],
      },
      'BCI3333': {
        '01': ['01A', '01B'],
      },
      'BCI3353': {
        '01': ['01A'],
      },
      'BCI3363': {
        '01': ['01A', '01B'],
      },
      'BCN1083': {
        '01': ['01A', '01B'],
      },
      'BCN2053': {
        '01': ['01A', '01B'],
        '02': ['02A', '02B'],
      },
      'BCN2173': {
        '01': ['01A'],
      },
      'BCN3173': {
        '01': ['01A'],
      },
      'BCN3243': {
        '01': ['01A'],
      },
      'BCN3273': {
        '07A': ['07P'],
        '07B': <String>[],
      },
      'BCM2073': {
        '01': ['01A'],
      },
      'BCM2113': {
        '01': ['01A'],
      },
      'BCM2123': {
        '01': ['01A'],
      },
      'BCM2133': {
        '01': ['01A'],
      },
      'BCM3203': {
        '01': ['01A'],
      },
      'BCM3243': {
        '01': ['01A'],
      },
      'BCM3253': {
        '01': ['01A'],
      },
      'BCM3263': {
        '01': ['01A', '01B'],
      },
      'BCM3283': {
        '02': ['02A', '02B'],
      },
      'BCM3293': {
        '03': ['03A'],
      },
      'BCM3313': {
        '01': ['01A', '01B'],
      },
      'BCM3323': {
        '01': ['01A'],
      },
      'BCS2143': {
        '01': ['01A'],
      },
      'BCS2213': {
        '01': ['01A'],
      },
      'BCS2233': {
        '01': ['01A'],
      },
      'BCS2313': {
        '01': ['01A'],
      },
      'BCS2343': {
        '01': ['01A'],
      },
      'BCS3143': {
        '01': ['01A'],
      },
      'BCS3153': {
        '01': ['01A'],
      },
      'BCS3263': {
        '06A': ['06P'],
        '06B': <String>[],
      },
      'BCS3423': {
        '01': ['01A'],
      },
      'BCY1013': {
        '01': <String>[],
      },
    };

    final subjects = [
      {
        'id': 'sub-001',
        'subjectCode': 'BCI1023',
        'subjectName': 'Programming Techniques',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-002',
        'subjectCode': 'BCI1143',
        'subjectName': 'Problem Solving',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-003',
        'subjectCode': 'BCI1033',
        'subjectName': 'Programming Techniques',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-004',
        'subjectCode': 'BCI1093',
        'subjectName': 'Data Structure & Algorithms',
        'creditHour': 4,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-005',
        'subjectCode': 'BCI2033',
        'subjectName': 'Data Structure & Algorithms',
        'creditHour': 4,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-006',
        'subjectCode': 'BCI2313',
        'subjectName': 'Algorithm & Complexity',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-007',
        'subjectCode': 'BCI2323',
        'subjectName': 'Web Development',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-008',
        'subjectCode': 'BCI2353',
        'subjectName': 'Algorithm & Complexity',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-009',
        'subjectCode': 'BCI3302',
        'subjectName': 'Project Management & Professional Practice',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-010',
        'subjectCode': 'BCI3313',
        'subjectName': 'IoT Data Integration',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-011',
        'subjectCode': 'BCI3323',
        'subjectName': 'IoT Application Development',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-012',
        'subjectCode': 'BCI3333',
        'subjectName': 'Machine Learning Applications',
        'creditHour': 4,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-013',
        'subjectCode': 'BCI3353',
        'subjectName': 'Blockchain Technology',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-014',
        'subjectCode': 'BCI3363',
        'subjectName': 'Mobile Application Development',
        'creditHour': 4,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-015',
        'subjectCode': 'BCN1083',
        'subjectName': 'Data Communication & Networking',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-016',
        'subjectCode': 'BCN2053',
        'subjectName': 'Operating Systems',
        'creditHour': 4,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-017',
        'subjectCode': 'BCN2173',
        'subjectName': 'Operating Systems',
        'creditHour': 4,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-018',
        'subjectCode': 'BCN3173',
        'subjectName': 'Embedded System Application & Design',
        'creditHour': 4,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-019',
        'subjectCode': 'BCN3243',
        'subjectName': 'Cloud Computing Technology',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-020',
        'subjectCode': 'BCN3273',
        'subjectName': 'Distributed & Parallel Computing',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-021',
        'subjectCode': 'BCM2073',
        'subjectName': 'Modeling & Simulation',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-022',
        'subjectCode': 'BCM2113',
        'subjectName': '3D Modelling',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-023',
        'subjectCode': 'BCM2123',
        'subjectName': '3D Digital Animation',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-024',
        'subjectCode': 'BCM2133',
        'subjectName': 'Computer Graphics',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-025',
        'subjectCode': 'BCM3203',
        'subjectName': 'Computer Game Programming II',
        'creditHour': 4,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-026',
        'subjectCode': 'BCM3243',
        'subjectName': 'Multimedia Development Workshop',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-027',
        'subjectCode': 'BCM3253',
        'subjectName': 'Data Analytics & Visualization',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-028',
        'subjectCode': 'BCM3263',
        'subjectName': 'Augmented Reality',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-029',
        'subjectCode': 'BCM3283',
        'subjectName': 'Fundamental of Game Development',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-030',
        'subjectCode': 'BCM3293',
        'subjectName': 'Game Programming & Development',
        'creditHour': 4,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-031',
        'subjectCode': 'BCM3313',
        'subjectName': 'Data Analytics & Visualization',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-032',
        'subjectCode': 'BCM3323',
        'subjectName': 'Augmented Reality',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-033',
        'subjectCode': 'BCS2143',
        'subjectName': 'Object Oriented Programming',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-034',
        'subjectCode': 'BCS2213',
        'subjectName': 'Formal Method',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-035',
        'subjectCode': 'BCS2233',
        'subjectName': 'Software Requirement Workshop',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-036',
        'subjectCode': 'BCS2313',
        'subjectName': 'Artificial Intelligence Techniques',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-037',
        'subjectCode': 'BCS2343',
        'subjectName': 'Software Design Workshop',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-038',
        'subjectCode': 'BCS3143',
        'subjectName': 'Software Project Management',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-039',
        'subjectCode': 'BCS3153',
        'subjectName': 'Software Evolution & Maintenance',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-040',
        'subjectCode': 'BCS3263',
        'subjectName': 'Software Quality Assurance',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-041',
        'subjectCode': 'BCS3423',
        'subjectName': 'Integrated Business Processing (SAP)',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
      {
        'id': 'sub-042',
        'subjectCode': 'BCY1013',
        'subjectName': 'Cyber Law & Security Policy',
        'creditHour': 3,
        'faculty': 'Faculty of Computing',
        'prerequisites': <String>[],
      },
    ].map((subject) {
      final subjectCode = subject['subjectCode'] as String;
      return {
        ...subject,
        'sections': subjectSections[subjectCode] ?? <String, List<String>>{},
      };
    }).toList();

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
