import 'package:flutter/foundation.dart';

import '../../models/app_user.dart';
import '../../models/attendance/attendance_record_model.dart';
import '../../models/attendance/attendance_session_model.dart';
import '../../services/attendance/api_service.dart';

class AttendanceController extends ChangeNotifier {
  AttendanceController({
    required AppUser? currentUser,
    AttendanceApiService? apiService,
  })  : _currentUser = currentUser,
        _api = apiService ?? AttendanceApiService();

  final AppUser? _currentUser;
  final AttendanceApiService _api;

  // ── Session creation state ────────────────────────────────────────────────

  AttendanceCategory selectedCategory = AttendanceCategory.module;
  String? selectedOptionId;
  AttendanceSession? previewSession;
  bool qrSaved = false;
  bool saving = false;

  // ── Record viewing state ──────────────────────────────────────────────────

  String selectedSessionKey = '';
  RecordDateFilter dateFilter = RecordDateFilter.thisWeek;

  // ── Student check-in state ────────────────────────────────────────────────

  bool qrScanned = false;
  bool identityVerified = false;
  bool sessionActive = true;
  bool submitting = false;
  String statusMessage = 'Scan QR or enter the code.';
  ScannedSessionData? scannedSession;

  // ── Module options ────────────────────────────────────────────────────────

  Future<List<AttendanceOption>> loadModuleOptions() async {
    return loadCoCurriculumOptions();
  }

  Future<List<AttendanceOption>> loadCoCurriculumOptions() async {
    return _api.getCoCurriculumOptions(_currentUser);
  }

  Future<List<AttendanceOption>> loadAcademicSubjectOptions() async {
    return _api.getAcademicSubjectOptions(_currentUser);
  }

  // ── Sessions ──────────────────────────────────────────────────────────────

  Future<List<AttendanceSession>> loadSessionsForLecturer() async {
    return _api.getSessionsForLecturer(_currentUser);
  }

  Future<List<AttendanceSession>> loadActiveSessions() async {
    return _api.getActiveSessions();
  }

  Future<void> createSession(List<AttendanceOption> options) async {
    if (selectedOptionId == null && options.isEmpty) return;
    final selectedOption = options.firstWhere(
      (o) => o.id == selectedOptionId,
      orElse: () => options.first,
    );

    final now = DateTime.now();
    final codeSeed = now.millisecondsSinceEpoch.toString();
    final session = AttendanceSession(
      id: 'session-${now.microsecondsSinceEpoch}',
      activityId: selectedOption.id,
      category: selectedCategory,
      subject: selectedOption.title,
      sessionName: _pendingSessionName.isEmpty ? 'Session 1' : _pendingSessionName,
      date: _pendingDate,
      time: _pendingTime,
      classCode: codeSeed.substring(codeSeed.length - 6),
      qrValue: 'QR-${now.microsecondsSinceEpoch}',
      lecturerId: _currentUser?.uid ?? 'lecturer-demo',
      lecturerName: _currentUser?.fullName ?? 'Lecturer',
      latitude: _pendingLatitude ?? 0,
      longitude: _pendingLongitude ?? 0,
      allowedRadiusMeters: 100,
      isActive: true,
    );

    saving = true;
    notifyListeners();
    try {
      await _api.createSession(
        session,
        createdAt: now.toIso8601String(),
        sourceOptionId: selectedOption.id,
      );
      previewSession = session;
      qrSaved = false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  // ── Pending form fields (set by the UI layer) ─────────────────────────────

  String _pendingSessionName = 'Session 1';
  String _pendingDate = '';
  String _pendingTime = '';
  double? _pendingLatitude;
  double? _pendingLongitude;

  void setPendingSessionName(String value) => _pendingSessionName = value;
  void setPendingDate(String value) => _pendingDate = value;
  void setPendingTime(String value) => _pendingTime = value;
  void setPendingLocation(double latitude, double longitude) {
    _pendingLatitude = latitude;
    _pendingLongitude = longitude;
    notifyListeners();
  }

  bool get hasLocation =>
      _pendingLatitude != null && _pendingLongitude != null;

  double? get pendingLatitude => _pendingLatitude;
  double? get pendingLongitude => _pendingLongitude;

  // ── Records ───────────────────────────────────────────────────────────────

  Future<List<AttendanceRecordData>> loadRecordsForLecturer() async {
    return _api.getRecordsForLecturer(_currentUser);
  }

  Future<void> updateRecordStatus(
    AttendanceRecordData record,
    String status,
  ) async {
    await _api.updateRecordStatus(record.id, status);
  }

  // ── Student check-in ──────────────────────────────────────────────────────

  Future<List<AttendanceRecordData>> loadRecordsForStudent() async {
    return _api.getRecordsForStudent(_currentUser);
  }

  Future<AttendanceSession?> loadSessionById(String sessionId) async {
    return _api.getSessionById(sessionId);
  }

  Future<bool> isSessionInactiveById(String sessionId) async {
    return _api.isSessionInactiveById(sessionId);
  }

  Future<AttendanceSession?> loadSessionByCode(String code) async {
    return _api.getSessionByCode(code);
  }

  Future<bool> isSessionInactiveByCode(String code) async {
    return _api.isSessionInactiveByCode(code);
  }

  Future<AttendanceSession?> loadSessionFromQrRaw(String raw) async {
    final payload = raw.trim();
    if (payload.isEmpty) return null;

    final parsed = ScannedSessionData.fromPayload(payload);
    if (parsed != null) {
      return loadSessionById(parsed.sessionId);
    }
    return loadSessionByCode(payload);
  }

  void applySession(
    AttendanceSession session, {
    required String message,
    required bool scannedViaQr,
  }) {
    scannedSession = ScannedSessionData(
      sessionId: session.id,
      activityId: session.activityId,
      category: session.category,
      subject: session.subject,
      sessionName: session.sessionName,
      classCode: session.classCode,
      date: session.date,
      time: session.time,
      qrValue: session.qrValue,
      latitude: session.latitude,
      longitude: session.longitude,
      allowedRadiusMeters: session.allowedRadiusMeters,
    );
    qrScanned = scannedViaQr;
    statusMessage = message;
    notifyListeners();
  }

  Future<void> submitAttendance() async {
    if (scannedSession == null) {
      statusMessage = 'Complete scan/code, identity, location, and active session.';
      notifyListeners();
      return;
    }

    submitting = true;
    notifyListeners();
    try {
      String lecturerId = '';
      String lecturerName = '';
      String activityId = scannedSession!.activityId;

      final sessionData = await _api.getSessionData(scannedSession!.sessionId);
      if ((sessionData?['isActive'] ?? true) != true) {
        statusMessage = 'Attendance session is inactive.';
        submitting = false;
        notifyListeners();
        return;
      }
      lecturerId = (sessionData?['lecturerId'] ?? '').toString();
      lecturerName = (sessionData?['lecturerName'] ?? '').toString();
      activityId =
          (sessionData?['activityId'] ??
                  sessionData?['sourceOptionId'] ??
                  activityId)
              .toString();

      await _api.submitAttendance({
        'attendanceCategory': scannedSession!.category.key,
        'sessionId': scannedSession!.sessionId,
        'activityId': activityId,
        'sourceOptionId': activityId,
        'subjectName': scannedSession!.subject,
        'sessionName': scannedSession!.sessionName,
        'studentId': _currentUser?.uid ?? 'student-demo',
        'studentIdentifier': _currentUser?.identifier ?? '',
        'studentName': _currentUser?.fullName ?? 'Student',
        'status': 'Present',
        'detail': 'Checked in successfully',
        'submissionMethod': qrScanned ? 'QR' : 'Code',
        'classCode': scannedSession!.classCode,
        'date': scannedSession!.date,
        'time': scannedSession!.time,
        'lecturerId': lecturerId,
        'lecturerName': lecturerName,
        'createdAt': DateTime.now().toIso8601String(),
      });
      statusMessage = 'Attendance submitted successfully.';
    } catch (_) {
      statusMessage = 'Unable to submit right now.';
      rethrow;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  void resetCheckIn() {
    qrScanned = false;
    identityVerified = false;
    sessionActive = true;
    scannedSession = null;
    statusMessage = 'Scan QR or enter the code.';
    notifyListeners();
  }

  void setIdentityVerified(bool value) {
    identityVerified = value;
    notifyListeners();
  }

  void setSessionActive(bool value) {
    sessionActive = value;
    notifyListeners();
  }

  void setStatusMessage(String message) {
    statusMessage = message;
    notifyListeners();
  }
}
