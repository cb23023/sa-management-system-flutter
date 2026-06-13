import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceCategory { module, academicClass }

extension AttendanceCategoryExtension on AttendanceCategory {
  String get label => switch (this) {
    AttendanceCategory.module => 'Co-Curriculum Module',
    AttendanceCategory.academicClass => 'Academic Class',
  };

  String get key => switch (this) {
    AttendanceCategory.module => 'module',
    AttendanceCategory.academicClass => 'academic',
  };
}

AttendanceCategory attendanceCategoryFromKey(String? value) {
  return switch (value) {
    'academic' => AttendanceCategory.academicClass,
    _ => AttendanceCategory.module,
  };
}

class AttendanceOption {
  const AttendanceOption({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

class AttendanceSession {
  const AttendanceSession({
    required this.id,
    required this.activityId,
    required this.category,
    required this.subject,
    required this.sessionName,
    required this.date,
    required this.time,
    required this.classCode,
    required this.qrValue,
    required this.lecturerId,
    required this.lecturerName,
    required this.latitude,
    required this.longitude,
    required this.allowedRadiusMeters,
    required this.isActive,
  });

  final String id;
  final String activityId;
  final AttendanceCategory category;
  final String subject;
  final String sessionName;
  final String date;
  final String time;
  final String classCode;
  final String qrValue;
  final String lecturerId;
  final String lecturerName;
  final double latitude;
  final double longitude;
  final double allowedRadiusMeters;
  final bool isActive;

  AttendanceSession copyWith({
    String? id,
    String? activityId,
    AttendanceCategory? category,
    String? subject,
    String? sessionName,
    String? date,
    String? time,
    String? classCode,
    String? qrValue,
    String? lecturerId,
    String? lecturerName,
    double? latitude,
    double? longitude,
    double? allowedRadiusMeters,
    bool? isActive,
  }) {
    return AttendanceSession(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      sessionName: sessionName ?? this.sessionName,
      date: date ?? this.date,
      time: time ?? this.time,
      classCode: classCode ?? this.classCode,
      qrValue: qrValue ?? this.qrValue,
      lecturerId: lecturerId ?? this.lecturerId,
      lecturerName: lecturerName ?? this.lecturerName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      allowedRadiusMeters: allowedRadiusMeters ?? this.allowedRadiusMeters,
      isActive: isActive ?? this.isActive,
    );
  }

  factory AttendanceSession.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return AttendanceSession.fromMap(doc.id, doc.data());
  }

  factory AttendanceSession.fromMap(String id, Map<String, dynamic> data) {
    return AttendanceSession(
      id: id,
      activityId: (data['activityId'] ?? data['sourceOptionId'] ?? '').toString(),
      category: attendanceCategoryFromKey(data['attendanceCategory']?.toString()),
      subject: (data['subjectName'] ?? data['subject'] ?? '').toString(),
      sessionName: (data['sessionName'] ?? 'Attendance Session').toString(),
      date: (data['date'] ?? '').toString(),
      time: (data['time'] ?? '').toString(),
      classCode: (data['classCode'] ?? '').toString(),
      qrValue: (data['qrValue'] ?? '').toString(),
      lecturerId: (data['lecturerId'] ?? '').toString(),
      lecturerName: (data['lecturerName'] ?? '').toString(),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      allowedRadiusMeters: (data['allowedRadiusMeters'] as num?)?.toDouble() ?? 100,
      isActive: (data['isActive'] ?? true) == true,
    );
  }

  Map<String, dynamic> toFirestore({String? createdAt, String? sourceOptionId}) {
    return {
      'activityId': activityId,
      'attendanceCategory': category.key,
      'subjectName': subject,
      'sessionName': sessionName,
      'date': date,
      'time': time,
      'classCode': classCode,
      'qrValue': qrValue,
      'lecturerId': lecturerId,
      'lecturerName': lecturerName,
      'latitude': latitude,
      'longitude': longitude,
      'allowedRadiusMeters': allowedRadiusMeters,
      'isActive': isActive,
      'sourceOptionId': sourceOptionId ?? activityId,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}

class ScannedSessionData {
  const ScannedSessionData({
    required this.sessionId,
    required this.activityId,
    required this.category,
    required this.subject,
    required this.sessionName,
    required this.classCode,
    required this.date,
    required this.time,
    required this.qrValue,
    required this.latitude,
    required this.longitude,
    required this.allowedRadiusMeters,
  });

  final String sessionId;
  final String activityId;
  final AttendanceCategory category;
  final String subject;
  final String sessionName;
  final String classCode;
  final String date;
  final String time;
  final String qrValue;
  final double latitude;
  final double longitude;
  final double allowedRadiusMeters;

  String toQrPayload() {
    return [
      'sessionId=$sessionId',
      'activityId=$activityId',
      'category=${category.key}',
      'subject=$subject',
      'session=$sessionName',
      'classCode=$classCode',
      'date=$date',
      'time=$time',
      'qr=$qrValue',
      'lat=$latitude',
      'lng=$longitude',
      'radius=$allowedRadiusMeters',
    ].join(';');
  }

  static ScannedSessionData? fromPayload(String payload) {
    final parts = payload.split(';');
    final map = <String, String>{};
    for (final part in parts) {
      final index = part.indexOf('=');
      if (index <= 0) continue;
      map[part.substring(0, index)] = part.substring(index + 1);
    }

    final sessionId = map['sessionId'];
    final activityId = map['activityId'] ?? '';
    final category = map['category'];
    final subject = map['subject'];
    final sessionName = map['session'];
    final classCode = map['classCode'];
    final date = map['date'];
    final time = map['time'];
    final qrValue = map['qr'];
    final latitude = double.tryParse(map['lat'] ?? '');
    final longitude = double.tryParse(map['lng'] ?? '');
    final allowedRadiusMeters = double.tryParse(map['radius'] ?? '');

    if ([sessionId, category, subject, sessionName, classCode, date, time, qrValue]
            .any((v) => v == null || v.isEmpty) ||
        latitude == null ||
        longitude == null ||
        allowedRadiusMeters == null) {
      return null;
    }

    return ScannedSessionData(
      sessionId: sessionId!,
      activityId: activityId,
      category: attendanceCategoryFromKey(category),
      subject: subject!,
      sessionName: sessionName!,
      classCode: classCode!,
      date: date!,
      time: time!,
      qrValue: qrValue!,
      latitude: latitude,
      longitude: longitude,
      allowedRadiusMeters: allowedRadiusMeters,
    );
  }
}
