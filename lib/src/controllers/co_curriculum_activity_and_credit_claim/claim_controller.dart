part of '../../screens/co_curriculum_activity_and_credit_claim/co_curriculum_module_page.dart';

class ClaimController {
  ClaimController({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get creditClaims =>
      firestore.collection('credit_claims');

  CollectionReference<Map<String, dynamic>> get activities =>
      firestore.collection('activities');

  CollectionReference<Map<String, dynamic>> get activityRegistrations =>
      firestore.collection('activity_registrations');

  CollectionReference<Map<String, dynamic>> get attendanceRecords =>
      firestore.collection('attendance_records');

  CollectionReference<Map<String, dynamic>> get notifications =>
      firestore.collection('notifications');

  CollectionReference<Map<String, dynamic>> get users =>
      firestore.collection('users');

  Future<QuerySnapshot<Map<String, dynamic>>> getStudentClaims(
    String studentUid,
  ) {
    return creditClaims
        .where('studentId', isEqualTo: studentUid)
        .orderBy('submittedAt', descending: true)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPendingClaims() {
    return creditClaims.where('claimStatus', isEqualTo: 'pending').get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getClaimById(
    String claimId,
  ) async {
    final doc = await creditClaims.doc(claimId).get();
    return doc.exists ? doc : null;
  }

  Future<Map<String, dynamic>> validateClaimActivities(
    String studentUid,
    List<String> activityIds,
  ) async {
    if (studentUid.trim().isEmpty) {
      return {'success': false, 'message': 'Student ID is required.'};
    }
    if (activityIds.length != 4) {
      return {
        'success': false,
        'message': 'Select exactly four completed activities.',
      };
    }

    final registrationSnapshot = await activityRegistrations
        .where('studentId', isEqualTo: studentUid)
        .get();
    final registrationsByActivityId = {
      for (final doc in registrationSnapshot.docs)
        (doc.data()['activityId'] ?? '').toString(): doc.data(),
    };

    final attendanceSnapshot = await attendanceRecords
        .where('studentId', isEqualTo: studentUid)
        .get();
    final attendanceReadyIds = attendanceSnapshot.docs
        .where((doc) => _isAttendancePresent(doc.data()))
        .map((doc) => _attendanceActivityId(doc.data()))
        .where((id) => id.isNotEmpty)
        .toSet();

    final activitySnapshot = await activities.get();
    final activitiesById = {
      for (final doc in activitySnapshot.docs) doc.id: doc.data(),
    };

    final selectedActivities = <Map<String, dynamic>>[];
    for (final activityId in activityIds) {
      final registration = registrationsByActivityId[activityId];
      final activity = activitiesById[activityId] ?? <String, dynamic>{};
      final registrationStatus = _safeLower(registration?['status']);
      final attendanceStatus = _safeLower(registration?['attendanceStatus']);
      final hasAttendance =
          attendanceReadyIds.contains(activityId) ||
          attendanceStatus == 'present' ||
          attendanceStatus == 'validated';
      final totalMarks = ((registration?['totalMarks'] as num?)?.toInt() ?? 0);

      if (registration == null ||
          registrationStatus != 'completed' ||
          !hasAttendance ||
          totalMarks <= 0) {
        return {
          'success': false,
          'message':
              'Credit claim cannot proceed. Select exactly four completed activities with present attendance and marks.',
        };
      }

      selectedActivities.add({
        'activityId': activityId,
        'title': (activity['title'] ?? activity['name'] ?? activityId)
            .toString(),
        'name': (activity['name'] ?? activity['title'] ?? activityId)
            .toString(),
        'hours': ((activity['hours'] as num?)?.toInt() ?? 0),
        'cats':
            (((activity['cats'] ?? activity['creditValue']) as num?)?.toInt() ??
            0),
        'totalMarks': totalMarks,
        'registrationStatus': registrationStatus,
        'attendanceStatus': hasAttendance ? 'present' : attendanceStatus,
      });
    }

    final totalMarks = selectedActivities.fold<int>(
      0,
      (runningTotal, item) =>
          runningTotal + ((item['totalMarks'] as num?)?.toInt() ?? 0),
    );
    final averageMark = selectedActivities.isEmpty
        ? 0
        : (totalMarks / selectedActivities.length).round();
    final totalHours = selectedActivities.fold<int>(
      0,
      (runningTotal, item) =>
          runningTotal + ((item['hours'] as num?)?.toInt() ?? 0),
    );
    final totalCats = selectedActivities.fold<int>(
      0,
      (runningTotal, item) =>
          runningTotal + ((item['cats'] as num?)?.toInt() ?? 0),
    );

    return {
      'success': true,
      'message': '',
      'selectedActivities': selectedActivities,
      'totalMarks': totalMarks,
      'averageMark': averageMark,
      'totalHours': totalHours,
      'totalCats': totalCats,
      'allModulesPassed': selectedActivities.every(
        (item) => ((item['totalMarks'] as num?)?.toInt() ?? 0) >= 40,
      ),
    };
  }

  Future<Map<String, dynamic>> submitClaim(
    Map<String, dynamic> claimData,
  ) async {
    final studentUid = (claimData['studentId'] ?? claimData['studentUid'] ?? '')
        .toString();
    final activityIds =
        ((claimData['activityIds'] as List<dynamic>?) ?? const <dynamic>[])
            .map((item) => item.toString())
            .where((item) => item.isNotEmpty)
            .toList();
    final validation = await validateClaimActivities(studentUid, activityIds);
    if (validation['success'] != true) {
      return validation;
    }

    final selectedActivities =
        (validation['selectedActivities'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
    final claimId = (claimData['id'] ?? 'claim-$studentUid').toString();

    await creditClaims.doc(claimId).set({
      'id': claimId,
      'studentId': studentUid,
      'activityId': activityIds.first,
      'activityIds': activityIds,
      'claimStatus': 'pending',
      'attendanceValidated': true,
      'allModulesPassed': validation['allModulesPassed'] == true,
      'averageMark': validation['averageMark'],
      'totalHours': validation['totalHours'],
      'totalCats': validation['totalCats'],
      'submittedAt': FieldValue.serverTimestamp(),
      'reviewedBy': '',
      'reviewedAt': null,
      'rejectionReason': '',
      'remarks':
          (claimData['remarks'] ??
                  'Submitted by student for Pusat Adab review.')
              .toString(),
    });

    try {
      await notifyPusatAdabClaimSubmitted(
        claimId: claimId,
        studentId: studentUid,
        activityTitles: selectedActivities
            .map(
              (item) =>
                  (item['title'] ?? item['name'] ?? 'Activity').toString(),
            )
            .toList(),
      );
    } catch (_) {
      return {
        'success': true,
        'message':
            'Credit claim submitted successfully. Notification could not be created.',
        'claimId': claimId,
      };
    }

    return {
      'success': true,
      'message': 'Credit claim submitted successfully.',
      'claimId': claimId,
    };
  }

  Future<Map<String, dynamic>> approveClaim(
    String claimId,
    String reviewerId,
  ) async {
    final doc = await getClaimById(claimId);
    if (doc == null) {
      return {'success': false, 'message': 'Claim record was not found.'};
    }
    final data = doc.data() ?? <String, dynamic>{};
    if (data['allModulesPassed'] != true ||
        data['attendanceValidated'] != true) {
      return {
        'success': false,
        'message':
            'Claim approval cannot proceed because attendance or marks validation failed.',
      };
    }

    await creditClaims.doc(claimId).set({
      'claimStatus': 'approved',
      'reviewedBy': reviewerId,
      'reviewedAt': FieldValue.serverTimestamp(),
      'rejectionReason': '',
      'remarks':
          'Approved by Pusat Adab after attendance and participation review.',
    }, SetOptions(merge: true));

    try {
      await notifyStudentClaimReviewed(
        claimId: claimId,
        studentId: (data['studentId'] ?? '').toString(),
        isApproved: true,
        rejectionReason: '',
      );
    } catch (_) {
      return {
        'success': true,
        'message':
            'Claim marked as approved. Notification could not be created.',
      };
    }

    return {'success': true, 'message': 'Claim marked as approved.'};
  }

  Future<Map<String, dynamic>> rejectClaim(
    String claimId,
    String reviewerId,
    String rejectionReason,
  ) async {
    if (rejectionReason.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Please enter a reason before rejecting this claim.',
      };
    }

    final doc = await getClaimById(claimId);
    if (doc == null) {
      return {'success': false, 'message': 'Claim record was not found.'};
    }
    final data = doc.data() ?? <String, dynamic>{};

    await creditClaims.doc(claimId).set({
      'claimStatus': 'rejected',
      'reviewedBy': reviewerId,
      'reviewedAt': FieldValue.serverTimestamp(),
      'rejectionReason': rejectionReason.trim(),
      'remarks': rejectionReason.trim(),
    }, SetOptions(merge: true));

    try {
      await notifyStudentClaimReviewed(
        claimId: claimId,
        studentId: (data['studentId'] ?? '').toString(),
        isApproved: false,
        rejectionReason: rejectionReason.trim(),
      );
    } catch (_) {
      return {
        'success': true,
        'message':
            'Claim marked as rejected. Notification could not be created.',
      };
    }

    return {'success': true, 'message': 'Claim marked as rejected.'};
  }

  Future<List<_ReviewClaimRecord>> _buildClaimRecords(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final usersSnapshot = await users.get();
    final activitiesSnapshot = await activities.get();
    final registrationsSnapshot = await activityRegistrations.get();

    final usersByUid = <String, Map<String, dynamic>>{};
    final usersByDocId = <String, Map<String, dynamic>>{};
    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      usersByDocId[doc.id] = data;
      final uid = (data['uid'] ?? '').toString();
      if (uid.isNotEmpty) {
        usersByUid[uid] = data;
      }
    }

    final activitiesById = <String, Map<String, dynamic>>{};
    for (final doc in activitiesSnapshot.docs) {
      activitiesById[doc.id] = doc.data();
    }

    final registrationsByStudentAndActivity = <String, Map<String, dynamic>>{};
    for (final doc in registrationsSnapshot.docs) {
      final data = doc.data();
      final studentId = (data['studentId'] ?? '').toString();
      final activityId = (data['activityId'] ?? '').toString();
      if (studentId.isEmpty || activityId.isEmpty) {
        continue;
      }
      registrationsByStudentAndActivity['$studentId::$activityId'] = data;
    }

    final mappedRecords = docs.map((doc) {
      final data = doc.data();
      final studentId = (data['studentId'] ?? '').toString();
      final rawActivityIds = data['activityIds'];
      final activityIds = rawActivityIds is Iterable
          ? rawActivityIds
                .map((item) => item.toString())
                .where((item) => item.isNotEmpty)
                .toList()
          : <String>[
              (data['activityId'] ?? '').toString(),
            ].where((item) => item.isNotEmpty).toList();
      final studentData =
          usersByUid[studentId] ??
          usersByDocId[studentId] ??
          <String, dynamic>{};
      final studentName =
          (studentData['fullName'] ??
                  studentData['name'] ??
                  studentData['email'] ??
                  studentId)
              .toString();
      final matricId = (studentData['matricId'] ?? '').toString();
      final activityTitles = activityIds
          .map((activityId) {
            final activityData =
                activitiesById[activityId] ?? <String, dynamic>{};
            return (activityData['title'] ?? activityData['name'] ?? activityId)
                .toString();
          })
          .where((title) => title.isNotEmpty)
          .toList();
      final activityItems = activityIds.map((activityId) {
        final activityData = activitiesById[activityId] ?? <String, dynamic>{};
        final registration =
            registrationsByStudentAndActivity['$studentId::$activityId'];
        return <String, dynamic>{
          'id': activityId,
          'title': (activityData['title'] ?? activityData['name'] ?? activityId)
              .toString(),
          'marks': ((registration?['totalMarks'] as num?)?.toInt() ?? 0),
          'attendanceStatus': (registration?['attendanceStatus'] ?? 'present')
              .toString(),
          'markStatus': (registration?['markStatus'] ?? 'passed').toString(),
        };
      }).toList();
      final claimStatus = (data['claimStatus'] ?? 'pending').toString();
      final attendanceValidated = data['attendanceValidated'] == true;
      final totalHours =
          (data['totalHours'] as num?)?.toInt() ??
          activityIds.fold<int>(0, (runningTotal, activityId) {
            final activityData =
                activitiesById[activityId] ?? <String, dynamic>{};
            return runningTotal +
                ((activityData['hours'] as num?)?.toInt() ?? 0);
          });
      final totalCats =
          (data['totalCats'] as num?)?.toInt() ??
          activityIds.fold<int>(0, (runningTotal, activityId) {
            final activityData =
                activitiesById[activityId] ?? <String, dynamic>{};
            return runningTotal +
                (((activityData['cats'] ?? activityData['creditValue']) as num?)
                        ?.toInt() ??
                    0);
          });
      final marks = activityIds
          .map((activityId) {
            final registration =
                registrationsByStudentAndActivity['$studentId::$activityId'];
            return (registration?['totalMarks'] as num?)?.toInt();
          })
          .whereType<int>()
          .toList();
      final averageMark = marks.isEmpty
          ? ((data['averageMark'] as num?)?.toInt() ?? 0)
          : (marks.reduce((a, b) => a + b) / marks.length).round();
      final allModulesPassed = marks.isEmpty
          ? data['allModulesPassed'] == true
          : marks.every((mark) => mark >= 40);
      final submittedAt = _parseDynamicDate(data['submittedAt']);
      final rejectionReason = (data['rejectionReason'] ?? '').toString().trim();

      return _ReviewClaimRecord(
        claimId: doc.id,
        sourceClaimIds: [doc.id],
        studentName: studentName,
        studentId: studentId,
        matricId: matricId,
        activityTitles: activityTitles,
        activityIds: activityIds,
        activityItems: activityItems,
        claimStatus: claimStatus,
        submittedAt: submittedAt,
        totalHours: totalHours,
        totalCats: totalCats,
        averageMark: averageMark,
        allModulesPassed: allModulesPassed,
        attendanceStatus: attendanceValidated
            ? 'Attendance confirmed.'
            : 'Attendance not ready yet.',
        claimNotes: (data['remarks'] ?? 'Pending staff review.').toString(),
        rejectionReason: rejectionReason,
      );
    }).toList();

    final grouped = <String, _ReviewClaimRecord>{};
    int statusPriority(String status) {
      switch (_safeLower(status)) {
        case 'pending':
          return 3;
        case 'approved':
          return 2;
        case 'rejected':
          return 1;
        default:
          return 0;
      }
    }

    for (final record in mappedRecords) {
      final existing = grouped[record.studentId];
      if (existing == null) {
        grouped[record.studentId] = record;
        continue;
      }

      final existingPriority = statusPriority(existing.claimStatus);
      final recordPriority = statusPriority(record.claimStatus);
      final existingTime = existing.submittedAt?.millisecondsSinceEpoch ?? 0;
      final recordTime = record.submittedAt?.millisecondsSinceEpoch ?? 0;

      final shouldReplace =
          recordPriority > existingPriority ||
          (recordPriority == existingPriority && recordTime > existingTime);

      if (shouldReplace) {
        grouped[record.studentId] = record;
      }
    }

    return grouped.values.toList();
  }

  Future<Map<String, dynamic>> createNotification(
    Map<String, dynamic> notificationData,
  ) async {
    final payload = Map<String, dynamic>.from(notificationData);
    final notificationId = (payload['id'] ?? '').toString().trim();
    final doc = notificationId.isEmpty
        ? notifications.doc()
        : notifications.doc(notificationId);
    payload['id'] = notificationId.isEmpty ? doc.id : notificationId;
    payload['module'] = 'module2';
    payload['isRead'] = payload['isRead'] ?? false;
    payload['createdAt'] = payload['createdAt'] ?? FieldValue.serverTimestamp();
    await doc.set(payload);
    return {'success': true, 'message': 'Notification created.'};
  }

  Future<void> notifyPusatAdabClaimSubmitted({
    required String claimId,
    required String studentId,
    required List<String> activityTitles,
  }) async {
    final studentByDoc = await users.doc(studentId).get();
    Map<String, dynamic> studentData =
        studentByDoc.data() ?? <String, dynamic>{};
    if (studentData.isEmpty) {
      final studentByUid = await users
          .where('uid', isEqualTo: studentId)
          .limit(1)
          .get();
      if (studentByUid.docs.isNotEmpty) {
        studentData = studentByUid.docs.first.data();
      }
    }

    final studentName = (studentData['fullName'] ?? 'Student').toString();
    final studentIdentifier = (studentData['matricId'] ?? '').toString().trim();
    final usersSnapshot = await users.get();
    final pusatAdabUsers = usersSnapshot.docs.where((doc) {
      final role = _safeLower(doc.data()['role']);
      return role == 'pusat_adab' || role == 'pusat adab';
    }).toList();
    if (pusatAdabUsers.isEmpty) {
      return;
    }

    final title = 'New co-curriculum claim submitted';
    final activityText = activityTitles.isEmpty
        ? 'A new claim is pending review.'
        : 'Activities: ${activityTitles.join(', ')}.';
    final message = studentIdentifier.isEmpty
        ? '$studentName submitted a new claim. $activityText'
        : '$studentName ($studentIdentifier) submitted a new claim. $activityText';

    for (final userDoc in pusatAdabUsers) {
      await createNotification({
        'userId': (userDoc.data()['uid'] ?? userDoc.id).toString(),
        'title': title,
        'message': message,
        'type': 'info',
        'actionLink': claimId,
      });
    }
  }

  Future<void> notifyStudentClaimReviewed({
    required String claimId,
    required String studentId,
    required bool isApproved,
    required String rejectionReason,
  }) async {
    final title = isApproved
        ? 'Co-curriculum claim approved'
        : 'Co-curriculum claim rejected';
    final message = isApproved
        ? 'Pusat Adab approved your co-curriculum credit claim.'
        : rejectionReason.trim().isEmpty
        ? 'Pusat Adab rejected your co-curriculum credit claim.'
        : 'Pusat Adab rejected your co-curriculum credit claim. Reason: $rejectionReason';

    await createNotification({
      'userId': studentId,
      'title': title,
      'message': message,
      'type': isApproved ? 'success' : 'warning',
      'actionLink': claimId,
    });
  }

  WriteBatch batch() => firestore.batch();
}

final ClaimController _claimController = ClaimController();
