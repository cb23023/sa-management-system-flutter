import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/app_user.dart';
import '../../models/attendance/attendance_record_model.dart';
import '../../models/attendance/attendance_session_model.dart';

const _sessionsCollection = 'attendance_sessions';
const _recordsCollection = 'attendance_records';

class AttendanceApiService {
  AttendanceApiService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ── Sessions ──────────────────────────────────────────────────────────────

  Future<List<AttendanceOption>> getModuleOptions(AppUser? currentUser) {
    return getCoCurriculumOptions(currentUser);
  }

  Future<List<AttendanceOption>> getCoCurriculumOptions(
    AppUser? currentUser,
  ) async {
    if (currentUser == null) return [];

    try {
      final snapshot = await _db.collection('activities').get();
      final options =
          snapshot.docs.where((doc) {
              return _isLecturerActivity(doc.data(), currentUser);
            }).map((doc) {
              final data = doc.data();
              final title = (data['title'] ?? 'Co-Curriculum Activity')
                  .toString()
                  .trim();
              final subtitle = [
                (data['date'] ?? '').toString().trim(),
                (data['venue'] ?? '').toString().trim(),
              ].where((value) => value.isNotEmpty).join(' | ');

              return AttendanceOption(
                id: doc.id,
                title: title.isEmpty ? 'Co-Curriculum Activity' : title,
                subtitle: subtitle.isEmpty ? 'Assigned activity' : subtitle,
              );
            }).toList()
            ..sort((a, b) => a.title.compareTo(b.title));
      return options;
    } catch (_) {
      return [];
    }
  }

  Future<List<AttendanceOption>> getAcademicSubjectOptions(
    AppUser? currentUser,
  ) async {
    if (currentUser == null) return [];

    final subjectsById = <String, Map<String, dynamic>>{};
    try {
      final snapshot = await _db.collection('subjects').get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        subjectsById[doc.id] = data;
        final subjectId = (data['id'] ?? '').toString().trim();
        if (subjectId.isNotEmpty) {
          subjectsById[subjectId] = data;
        }
      }
    } catch (_) {}

    try {
      final snapshot = await _db.collection('subject_offerings').get();
      final options = snapshot.docs.where((doc) {
        final data = doc.data();
        return _isLecturerOffering(data, currentUser) &&
            _isActiveOffering(data);
      }).map((doc) {
        final data = doc.data();
        final subjectId = (data['subjectId'] ?? '').toString().trim();
        final subject = subjectsById[subjectId] ?? const <String, dynamic>{};
        final subjectCode =
            (subject['subjectCode'] ?? data['subjectCode'] ?? '')
                .toString()
                .trim();
        final subjectName =
            (subject['subjectName'] ?? data['subjectName'] ?? 'Module')
                .toString()
                .trim();
        final title = [
          if (subjectCode.isNotEmpty) subjectCode,
          if (subjectName.isNotEmpty) subjectName,
        ].join(' - ');
        final subtitle = [
          (data['schedule'] ?? '').toString().trim(),
          (data['semester'] ?? '').toString().trim(),
        ].where((value) => value.isNotEmpty).join(' | ');

        return AttendanceOption(
          id: doc.id,
          title: title.isEmpty ? 'Module' : title,
          subtitle: subtitle.isEmpty ? 'Assigned subject' : subtitle,
        );
      }).toList()
        ..sort((a, b) => a.title.compareTo(b.title));
      return options;
    } catch (_) {
      return [];
    }
  }

  Future<List<AttendanceSession>> getSessionsForLecturer(
    AppUser? currentUser,
  ) async {
    try {
      final snapshot = await _db.collection(_sessionsCollection).get();
      return snapshot.docs
          .map(AttendanceSession.fromFirestore)
          .where((session) {
            return session.lecturerId == currentUser?.uid ||
                session.lecturerName.toLowerCase() ==
                    (currentUser?.fullName.toLowerCase() ?? '');
          })
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<AttendanceSession>> getActiveSessions() async {
    try {
      final snapshot = await _db.collection(_sessionsCollection).get();
      return snapshot.docs
          .map(AttendanceSession.fromFirestore)
          .where(
            (s) =>
                s.subject.trim().isNotEmpty &&
                s.sessionName.trim().isNotEmpty &&
                s.date.trim().isNotEmpty &&
                s.classCode.trim().isNotEmpty &&
                s.isActive,
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<AttendanceSession?> getSessionById(String sessionId) async {
    if (sessionId.trim().isEmpty) return null;
    try {
      final doc = await _db.collection(_sessionsCollection).doc(sessionId).get();
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      final session = AttendanceSession.fromMap(doc.id, data);
      return _isSessionAccessible(session) ? session : null;
    } catch (_) {
      try {
        final snapshot = await _db.collection(_sessionsCollection).get();
        final match = snapshot.docs.where((doc) {
          final s = AttendanceSession.fromMap(doc.id, doc.data());
          return doc.id == sessionId && _isSessionAccessible(s);
        });
        return match.isNotEmpty
            ? AttendanceSession.fromFirestore(match.first)
            : null;
      } catch (_) {
        return null;
      }
    }
  }

  Future<bool> isSessionInactiveById(String sessionId) async {
    if (sessionId.trim().isEmpty) return false;
    try {
      final doc =
          await _db.collection(_sessionsCollection).doc(sessionId).get();
      final data = doc.data();
      if (!doc.exists || data == null) return false;
      return !AttendanceSession.fromMap(doc.id, data).isActive;
    } catch (_) {
      return false;
    }
  }

  Future<AttendanceSession?> getSessionByCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    try {
      final snapshot = await _db.collection(_sessionsCollection).get();
      final match = snapshot.docs.where((doc) {
        final data = doc.data();
        return (data['classCode'] ?? '').toString().trim().toUpperCase() ==
                normalized &&
            _isSessionAccessible(AttendanceSession.fromMap(doc.id, data));
      });
      return match.isNotEmpty
          ? AttendanceSession.fromFirestore(match.first)
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isSessionInactiveByCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return false;
    try {
      final snapshot = await _db.collection(_sessionsCollection).get();
      return snapshot.docs.any((doc) {
        final s = AttendanceSession.fromMap(doc.id, doc.data());
        return s.classCode.trim().toUpperCase() == normalized && !s.isActive;
      });
    } catch (_) {
      return false;
    }
  }

  Future<void> createSession(
    AttendanceSession session, {
    required String createdAt,
    required String sourceOptionId,
  }) async {
    await _db
        .collection(_sessionsCollection)
        .doc(session.id)
        .set(session.toFirestore(
          createdAt: createdAt,
          sourceOptionId: sourceOptionId,
        ));
  }

  // ── Records ───────────────────────────────────────────────────────────────

  Future<List<AttendanceRecordData>> getRecordsForLecturer(
    AppUser? currentUser,
  ) async {
    try {
      final snapshot = await _db.collection(_recordsCollection).get();
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            final lecturerId = (data['lecturerId'] ?? '').toString();
            final lecturerName = (data['lecturerName'] ?? '').toString();
            return lecturerId == currentUser?.uid ||
                lecturerName.toLowerCase() ==
                    (currentUser?.fullName.toLowerCase() ?? '');
          })
          .map(AttendanceRecordData.fromFirestore)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<AttendanceRecordData>> getRecordsForStudent(
    AppUser? currentUser,
  ) async {
    try {
      final snapshot = await _db.collection(_recordsCollection).get();
      return snapshot.docs
          .map(AttendanceRecordData.fromFirestore)
          .where(
            (r) =>
                r.studentId == currentUser?.uid ||
                r.studentId == currentUser?.identifier,
          )
          .where(
            (r) =>
                r.subject.trim().isNotEmpty &&
                r.sessionName.trim().isNotEmpty &&
                r.date.trim().isNotEmpty,
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> updateRecordStatus(String recordId, String status) async {
    final detail = switch (status) {
      'Present' => 'Updated by lecturer',
      'Late' => 'Marked late by lecturer',
      'Absent' => 'Marked absent by lecturer',
      'Excused' => 'Excused by lecturer',
      _ => 'Updated by lecturer',
    };
    await _db.collection(_recordsCollection).doc(recordId).update({
      'status': status,
      'detail': detail,
    });
  }

  Future<void> submitAttendance(Map<String, dynamic> data) async {
    await _db.collection(_recordsCollection).add(data);
  }

  Future<Map<String, dynamic>?> getSessionData(String sessionId) async {
    try {
      final doc =
          await _db.collection(_sessionsCollection).doc(sessionId).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  // ── Pusat Adab ────────────────────────────────────────────────────────────

  Future<PusatAdabDataBundle> getPusatAdabBundle() async {
    List<AttendanceRecordData> records = [];
    Map<String, AttendanceSession> sessions = {};
    Map<String, String> activityTitles = {};

    try {
      final snapshot = await _db.collection(_recordsCollection).get();
      records = snapshot.docs.map(AttendanceRecordData.fromFirestore).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {}

    try {
      final snapshot = await _db.collection(_sessionsCollection).get();
      sessions = {
        for (final doc in snapshot.docs)
          doc.id: AttendanceSession.fromFirestore(doc),
      };
    } catch (_) {}

    try {
      final snapshot = await _db.collection('activities').get();
      activityTitles = {
        for (final doc in snapshot.docs)
          doc.id: (doc.data()['title'] ?? '').toString(),
      };
    } catch (_) {}

    return PusatAdabDataBundle(
      records: records,
      sessionsById: sessions,
      activityTitles: activityTitles,
    );
  }

  // ── Registrations ─────────────────────────────────────────────────────────

  Future<Set<String>> getRegisteredActivityIds(AppUser? user) async {
    if (user == null) return {};
    try {
      final snapshot =
          await _db.collection('activity_registrations').get();
      final validIds = <String>{user.uid, user.identifier}
          .where((v) => v.trim().isNotEmpty)
          .toSet();
      return snapshot.docs
          .where(
            (doc) => validIds.contains(
              (doc.data()['studentId'] ?? '').toString(),
            ),
          )
          .map((doc) => (doc.data()['activityId'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (_) {
      return {};
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  bool _isSessionAccessible(AttendanceSession session) {
    return session.subject.trim().isNotEmpty &&
        session.sessionName.trim().isNotEmpty &&
        session.date.trim().isNotEmpty &&
        session.classCode.trim().isNotEmpty &&
        session.isActive;
  }

  bool _isLecturerOffering(
    Map<String, dynamic> data,
    AppUser currentUser,
  ) {
    final lecturerId = (data['lecturerId'] ?? '').toString().trim();
    final lecturerName = (data['lecturerName'] ?? '').toString().trim();
    return _matchesCurrentUser(lecturerId, lecturerName, currentUser);
  }

  bool _isLecturerActivity(
    Map<String, dynamic> data,
    AppUser currentUser,
  ) {
    final lecturerId =
        (data['supervisorLecturerId'] ?? data['lecturerId'] ?? '')
            .toString()
            .trim();
    final lecturerName =
        (data['supervisorLecturerName'] ?? data['lecturerName'] ?? '')
            .toString()
            .trim();
    return _matchesCurrentUser(lecturerId, lecturerName, currentUser);
  }

  bool _matchesCurrentUser(
    String ownerId,
    String ownerName,
    AppUser currentUser,
  ) {
    final userIds = {
      currentUser.uid.trim(),
      currentUser.identifier.trim(),
    }.where((value) => value.isNotEmpty);

    return userIds.contains(ownerId) ||
        ownerName.toLowerCase() == currentUser.fullName.toLowerCase();
  }

  bool _isActiveOffering(Map<String, dynamic> data) {
    final status = (data['status'] ?? '').toString().trim().toLowerCase();
    return status.isEmpty || status == 'active';
  }
}
