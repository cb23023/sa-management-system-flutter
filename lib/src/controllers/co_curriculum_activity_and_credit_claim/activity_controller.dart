part of '../../screens/co_curriculum_activity_and_credit_claim/co_curriculum_module_page.dart';

class ActivityController {
  ActivityController({FirebaseFirestore? firestore})
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

  CollectionReference<Map<String, dynamic>> get creditClaims =>
      firestore.collection('credit_claims');

  Future<QuerySnapshot<Map<String, dynamic>>> getActivities() {
    return activities.get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getActivityById(
    String activityId,
  ) async {
    final doc = await activities.doc(activityId).get();
    return doc.exists ? doc : null;
  }

  Future<Map<String, dynamic>> validateActivityData(
    Map<String, dynamic> activityData, {
    String? currentActivityId,
  }) async {
    final title = (activityData['title'] ?? activityData['name'] ?? '')
        .toString()
        .trim();
    final sessionDate =
        (activityData['session_date'] ?? activityData['date'] ?? '')
            .toString()
            .trim();
    final startTime = (activityData['startTime'] ?? '').toString().trim();
    final endTime = (activityData['endTime'] ?? '').toString().trim();
    final venue = (activityData['venue'] ?? '').toString().trim();
    final status = (activityData['status'] ?? '').toString().trim();
    final lecturer =
        (activityData['supervisorLecturerId'] ??
                activityData['supervisorLecturerName'] ??
                activityData['supervisor'] ??
                activityData['lecturer'] ??
                '')
            .toString()
            .trim();
    final capacity =
        (activityData['capacity'] as num?)?.toInt() ??
        int.tryParse((activityData['capacity'] ?? '').toString()) ??
        0;

    if (title.isEmpty ||
        sessionDate.isEmpty ||
        startTime.isEmpty ||
        endTime.isEmpty ||
        venue.isEmpty ||
        status.isEmpty ||
        lecturer.isEmpty) {
      return {
        'success': false,
        'message': 'Complete all required activity fields before saving.',
      };
    }

    if (capacity <= 0) {
      return {'success': false, 'message': 'Capacity must be greater than 0.'};
    }

    final duplicateSnapshot = await activities
        .where('title', isEqualTo: title)
        .where('session_date', isEqualTo: sessionDate)
        .get();
    final hasDuplicate = duplicateSnapshot.docs.any(
      (doc) => doc.id != currentActivityId,
    );
    if (hasDuplicate) {
      return {
        'success': false,
        'message': 'An activity with the same title and date already exists.',
      };
    }

    return {'success': true, 'message': ''};
  }

  Future<Map<String, dynamic>> saveActivity(
    Map<String, dynamic> activityData,
  ) async {
    final validation = await validateActivityData(activityData);
    if (validation['success'] != true) {
      return validation;
    }

    final activityId = (activityData['id'] ?? '').toString().trim();
    if (activityId.isEmpty) {
      return {
        'success': false,
        'message': 'Activity ID is required before saving.',
      };
    }

    final payload = Map<String, dynamic>.from(activityData);
    payload['id'] = activityId;
    await _resolveSupervisorLecturerId(payload);
    payload['createdAt'] ??= FieldValue.serverTimestamp();
    payload['updatedAt'] = FieldValue.serverTimestamp();

    await activities.doc(activityId).set(payload, SetOptions(merge: true));
    return {
      'success': true,
      'message': 'Activity saved successfully.',
      'activityId': activityId,
    };
  }

  Future<Map<String, dynamic>> updateActivity(
    String activityId,
    Map<String, dynamic> activityData,
  ) async {
    final existing = await activities.doc(activityId).get();
    if (!existing.exists) {
      return {
        'success': false,
        'message': 'This activity record is no longer available.',
      };
    }

    final validation = await validateActivityData(
      activityData,
      currentActivityId: activityId,
    );
    if (validation['success'] != true) {
      return validation;
    }

    final existingData = existing.data() ?? <String, dynamic>{};
    final participantsCount =
        ((existingData['participantsCount'] as num?)?.toInt() ?? 0);
    final capacity =
        (activityData['capacity'] as num?)?.toInt() ??
        int.tryParse((activityData['capacity'] ?? '').toString()) ??
        0;
    if (participantsCount > capacity) {
      return {
        'success': false,
        'message':
            'Capacity cannot be lower than the current participant count.',
      };
    }

    final payload = Map<String, dynamic>.from(activityData);
    payload['id'] = activityId;
    await _resolveSupervisorLecturerId(payload);
    payload['participantsCount'] = participantsCount;
    payload['availableSlots'] = capacity - participantsCount;
    payload['updatedAt'] = FieldValue.serverTimestamp();
    if (existingData['createdAt'] != null) {
      payload.remove('createdAt');
    } else {
      payload['createdAt'] ??= FieldValue.serverTimestamp();
    }

    await activities.doc(activityId).set(payload, SetOptions(merge: true));
    return {
      'success': true,
      'message': 'Activity updated successfully.',
      'activityId': activityId,
    };
  }

  Future<Map<String, dynamic>> checkRelatedRecords(String activityId) async {
    final registrationsSnapshot = await activityRegistrations
        .where('activityId', isEqualTo: activityId)
        .limit(1)
        .get();
    if (registrationsSnapshot.docs.isNotEmpty) {
      return {
        'success': true,
        'hasRelatedRecords': true,
        'message':
            'This activity has related registration records and cannot be deleted.',
      };
    }

    final attendanceSnapshot = await attendanceRecords
        .where('activityId', isEqualTo: activityId)
        .limit(1)
        .get();
    if (attendanceSnapshot.docs.isNotEmpty) {
      return {
        'success': true,
        'hasRelatedRecords': true,
        'message':
            'This activity has related attendance records and cannot be deleted.',
      };
    }

    final claimSnapshot = await creditClaims
        .where('activityIds', arrayContains: activityId)
        .limit(1)
        .get();
    if (claimSnapshot.docs.isNotEmpty) {
      return {
        'success': true,
        'hasRelatedRecords': true,
        'message':
            'This activity has related credit claim records and cannot be deleted.',
      };
    }

    return {'success': true, 'hasRelatedRecords': false, 'message': ''};
  }

  Future<Map<String, dynamic>> deleteActivity(String activityId) async {
    final related = await checkRelatedRecords(activityId);
    if (related['hasRelatedRecords'] == true) {
      return {'success': false, 'message': related['message']};
    }

    await activities.doc(activityId).delete();
    return {'success': true, 'message': 'Activity deleted successfully.'};
  }

  Future<Map<String, dynamic>> registerActivity({
    required String activityId,
    required String studentUid,
    required Map<String, dynamic> activityData,
  }) async {
    final title = (activityData['title'] ?? activityData['name'] ?? activityId)
        .toString();
    final status = _safeLower(activityData['status']);
    final capacity = ((activityData['capacity'] as num?)?.toInt() ?? 0);
    final participantsCount =
        ((activityData['participantsCount'] as num?)?.toInt() ?? 0);
    final availableSlots =
        ((activityData['availableSlots'] as num?)?.toInt() ??
        (capacity - participantsCount));
    final activityDate = _parseStoredDate(
      activityData['session_date']?.toString(),
      activityData['date']?.toString(),
    );
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (status != 'active' ||
        availableSlots <= 0 ||
        activityDate == null ||
        activityDate.isBefore(todayOnly)) {
      return {
        'success': false,
        'message': 'Registration is not allowed for this activity.',
      };
    }

    final regRef = activityRegistrations.doc('actreg-$activityId-$studentUid');
    final existing = await regRef.get();
    if (existing.exists &&
        _safeLower(existing.data()?['status']) != 'cancelled') {
      return {
        'success': false,
        'message': 'You have already registered for this activity.',
      };
    }

    final writeBatch = batch();
    writeBatch.set(regRef, {
      'id': regRef.id,
      'activityId': activityId,
      'studentId': studentUid,
      'registeredAt': FieldValue.serverTimestamp(),
      'status': 'registered',
      'attendanceStatus': 'pending',
      'totalMarks': 0,
      'markStatus': 'pending',
    });
    writeBatch.set(activities.doc(activityId), {
      'participantsCount': participantsCount + 1,
      'availableSlots': availableSlots > 0 ? availableSlots - 1 : 0,
    }, SetOptions(merge: true));
    await writeBatch.commit();

    return {
      'success': true,
      'message': '$title registered successfully.',
      'registrationId': regRef.id,
    };
  }

  Future<Map<String, dynamic>> cancelRegistration({
    required String activityId,
    required String studentUid,
    required String registrationId,
    required Map<String, dynamic> activityData,
  }) async {
    final title = (activityData['title'] ?? activityData['name'] ?? activityId)
        .toString();
    final activityDate = _parseStoredDate(
      activityData['session_date']?.toString(),
      activityData['date']?.toString(),
    );
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (activityDate == null || !activityDate.isAfter(todayOnly)) {
      return {
        'success': false,
        'message':
            'Registration can only be cancelled before the activity date.',
      };
    }

    final attendanceSnapshot = await attendanceRecords
        .where('studentId', isEqualTo: studentUid)
        .where('activityId', isEqualTo: activityId)
        .limit(1)
        .get();
    final hasAttendanceRecord = attendanceSnapshot.docs.any(
      (doc) => _isAttendancePresent(doc.data()),
    );
    if (hasAttendanceRecord) {
      return {
        'success': false,
        'message':
            'Registration cannot be cancelled after attendance has been recorded.',
      };
    }

    final participantsCount =
        ((activityData['participantsCount'] as num?)?.toInt() ?? 0);
    final availableSlots =
        ((activityData['availableSlots'] as num?)?.toInt() ?? 0);

    final writeBatch = batch();
    writeBatch.set(activityRegistrations.doc(registrationId), {
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancellationReason': 'Cancelled by student before activity date.',
    }, SetOptions(merge: true));
    writeBatch.set(activities.doc(activityId), {
      'participantsCount': participantsCount > 0 ? participantsCount - 1 : 0,
      'availableSlots': availableSlots + 1,
    }, SetOptions(merge: true));
    await writeBatch.commit();

    return {'success': true, 'message': '$title registration cancelled.'};
  }

  Future<void> _resolveSupervisorLecturerId(
    Map<String, dynamic> activityData,
  ) async {
    if ((activityData['supervisorLecturerId'] ?? '').toString().isNotEmpty) {
      return;
    }
    final supervisorName =
        (activityData['supervisorLecturerName'] ??
                activityData['supervisor'] ??
                activityData['lecturer'] ??
                '')
            .toString()
            .trim();
    if (supervisorName.isEmpty) {
      return;
    }
    final lecturerQuery = await users
        .where('role', isEqualTo: 'lecturer')
        .where('fullName', isEqualTo: supervisorName)
        .limit(1)
        .get();
    if (lecturerQuery.docs.isNotEmpty) {
      activityData['supervisorLecturerId'] =
          (lecturerQuery.docs.first.data()['uid'] ?? '').toString();
    }
  }

  WriteBatch batch() => firestore.batch();
}

final ActivityController _activityController = ActivityController();
