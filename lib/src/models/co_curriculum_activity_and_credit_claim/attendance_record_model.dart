class AttendanceRecordModel {
  const AttendanceRecordModel({
    required this.id,
    required this.activityId,
    required this.studentId,
    required this.status,
  });

  final String id;
  final String activityId;
  final String studentId;
  final String status;

  factory AttendanceRecordModel.fromMap(String id, Map<String, dynamic> data) {
    return AttendanceRecordModel(
      id: id,
      activityId: (data['activityId'] ?? '').toString(),
      studentId: (data['studentId'] ?? '').toString(),
      status: (data['status'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityId': activityId,
      'studentId': studentId,
      'status': status,
    };
  }
}
