class ActivityRegistrationModel {
  const ActivityRegistrationModel({
    required this.id,
    required this.activityId,
    required this.studentId,
    required this.status,
    required this.attendanceStatus,
    required this.totalMarks,
    required this.markStatus,
  });

  final String id;
  final String activityId;
  final String studentId;
  final String status;
  final String attendanceStatus;
  final int totalMarks;
  final String markStatus;

  factory ActivityRegistrationModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return ActivityRegistrationModel(
      id: id,
      activityId: (data['activityId'] ?? '').toString(),
      studentId: (data['studentId'] ?? '').toString(),
      status: (data['status'] ?? 'registered').toString(),
      attendanceStatus: (data['attendanceStatus'] ?? 'pending').toString(),
      totalMarks: ((data['totalMarks'] as num?)?.toInt() ?? 0),
      markStatus: (data['markStatus'] ?? 'pending').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityId': activityId,
      'studentId': studentId,
      'status': status,
      'attendanceStatus': attendanceStatus,
      'totalMarks': totalMarks,
      'markStatus': markStatus,
    };
  }
}
