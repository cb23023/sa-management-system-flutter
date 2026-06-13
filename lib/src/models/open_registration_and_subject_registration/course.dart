enum UserRole { student, registrar, lecturer }

class CourseSessionDetail {
  final String sectionCode;
  final String type;
  final String day;
  final String time;
  final String location;

  CourseSessionDetail({
    required this.sectionCode,
    required this.type,
    required this.day,
    required this.time,
    required this.location,
  });
}

class Course {
  final String code;
  final String name;
  final int credits;
  final String schedule;
  String instructor;
  final int capacity;
  int enrolled;
  final bool requiresApproval;
  final Map<String, List<String>> sections;
  final Map<String, CourseSessionDetail> sessionDetails;
  final Map<String, String> assignedLecturersBySection;

  Course({
    required this.code,
    required this.name,
    required this.credits,
    required this.schedule,
    required this.instructor,
    required this.capacity,
    required this.enrolled,
    required this.sections,
    required this.sessionDetails,
    Map<String, String>? assignedLecturersBySection,
    this.requiresApproval = false,
  }) : assignedLecturersBySection = assignedLecturersBySection ?? {};

  bool get isFull => enrolled >= capacity;
  int get seatsAvailable => capacity - enrolled;
}
