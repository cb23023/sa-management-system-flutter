import 'package:cloud_firestore/cloud_firestore.dart';

import 'attendance_session_model.dart';

enum RecordDateFilter { today, thisWeek, thisMonth, all }

extension RecordDateFilterExtension on RecordDateFilter {
  String get label => switch (this) {
    RecordDateFilter.today => 'Today',
    RecordDateFilter.thisWeek => 'This Week',
    RecordDateFilter.thisMonth => 'This Month',
    RecordDateFilter.all => 'All',
  };
}

class AttendanceRecordData {
  const AttendanceRecordData({
    required this.id,
    required this.sessionId,
    required this.activityId,
    required this.category,
    required this.name,
    required this.studentId,
    required this.lecturerName,
    required this.subject,
    required this.sessionName,
    required this.date,
    required this.status,
    required this.detail,
    required this.method,
  });

  final String id;
  final String sessionId;
  final String activityId;
  final AttendanceCategory category;
  final String name;
  final String studentId;
  final String lecturerName;
  final String subject;
  final String sessionName;
  final String date;
  final String status;
  final String detail;
  final String method;

  AttendanceRecordData copyWith({
    String? id,
    String? sessionId,
    String? activityId,
    AttendanceCategory? category,
    String? name,
    String? studentId,
    String? lecturerName,
    String? subject,
    String? sessionName,
    String? date,
    String? status,
    String? detail,
    String? method,
  }) {
    return AttendanceRecordData(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      activityId: activityId ?? this.activityId,
      category: category ?? this.category,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      lecturerName: lecturerName ?? this.lecturerName,
      subject: subject ?? this.subject,
      sessionName: sessionName ?? this.sessionName,
      date: date ?? this.date,
      status: status ?? this.status,
      detail: detail ?? this.detail,
      method: method ?? this.method,
    );
  }

  factory AttendanceRecordData.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return AttendanceRecordData(
      id: doc.id,
      sessionId: (data['sessionId'] ?? '').toString(),
      activityId: (data['activityId'] ?? '').toString(),
      category: attendanceCategoryFromKey(data['attendanceCategory']?.toString()),
      name: (data['studentName'] ?? data['name'] ?? 'Student').toString(),
      studentId: (data['studentId'] ?? data['matricId'] ?? '').toString(),
      lecturerName: (data['lecturerName'] ?? '').toString(),
      subject: (data['subjectName'] ?? data['subject'] ?? '').toString(),
      sessionName: (data['sessionName'] ?? 'Session').toString(),
      date: (data['date'] ?? '').toString(),
      status: (data['status'] ??
              ((data['present'] == true) ? 'Present' : 'Pending'))
          .toString(),
      detail: (data['detail'] ?? '').toString(),
      method: (data['submissionMethod'] ?? 'Manual').toString(),
    );
  }
}

class PusatAdabDataBundle {
  const PusatAdabDataBundle({
    required this.records,
    required this.sessionsById,
    required this.activityTitles,
  });

  final List<AttendanceRecordData> records;
  final Map<String, AttendanceSession> sessionsById;
  final Map<String, String> activityTitles;
}

class PusatAdabModuleSummary {
  const PusatAdabModuleSummary({
    required this.key,
    required this.moduleName,
    required this.lecturerName,
    required this.records,
    required this.sessionCount,
    required this.latestDate,
  });

  final String key;
  final String moduleName;
  final String lecturerName;
  final List<AttendanceRecordData> records;
  final int sessionCount;
  final DateTime? latestDate;

  int get presentCount =>
      records.where((r) => r.status == 'Present').length;

  int get attendanceRate =>
      records.isEmpty ? 0 : ((presentCount / records.length) * 100).round();
}

DateTime? tryParseRecordDate(String value) {
  try {
    return DateTime.parse(value);
  } catch (_) {
    return null;
  }
}

String recordSessionKey(AttendanceRecordData record) {
  final sessionId = record.sessionId.isEmpty ? 'session' : record.sessionId;
  final subject = record.subject.isEmpty ? 'Attendance' : record.subject;
  final sessionName = record.sessionName.isEmpty ? 'Session' : record.sessionName;
  return '$sessionId|$subject|$sessionName';
}
