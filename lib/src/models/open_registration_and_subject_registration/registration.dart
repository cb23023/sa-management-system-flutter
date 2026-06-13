class RegistrationRequest {
  final String studentName;
  final String courseCode;
  final String courseName;
  final String? section;
  final String? lab;
  String status;

  RegistrationRequest({
    required this.studentName,
    required this.courseCode,
    required this.courseName,
    this.section,
    this.lab,
    this.status = 'Pending',
  });
}

class RegisteredSubject {
  final String courseCode;
  final String courseName;
  final String section;
  final String lab;
  String status;

  RegisteredSubject({
    required this.courseCode,
    required this.courseName,
    required this.section,
    required this.lab,
    this.status = 'Registered',
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<RegistrationRequest> _notifications = [];

  List<RegistrationRequest> get notifications => List.unmodifiable(_notifications);

  void addNotification(RegistrationRequest notification) {
    _notifications.add(notification);
  }

  void updateNotificationStatus(String studentName, String courseCode, String status) {
    final index = _notifications.indexWhere(
      (n) => n.studentName == studentName && n.courseCode == courseCode,
    );
    if (index != -1) {
      _notifications[index] = RegistrationRequest(
        studentName: _notifications[index].studentName,
        courseCode: _notifications[index].courseCode,
        courseName: _notifications[index].courseName,
        section: _notifications[index].section,
        lab: _notifications[index].lab,
        status: status,
      );
    }
  }

  void clearNotifications() {
    _notifications.clear();
  }
}
