class AppUser {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.identifier,
    required this.semester,
    required this.accountStatus,
    required this.avatarInitials,
    required this.faculty,
    required this.programme,
  });

  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String identifier;
  final String semester;
  final String accountStatus;
  final String avatarInitials;
  final String faculty;
  final String programme;

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: (map['uid'] ?? '').toString(),
      fullName: (map['fullName'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      role: (map['role'] ?? 'student').toString(),
      identifier: (map['matricId'] ?? map['staffId'] ?? '').toString(),
      semester: (map['currentSemester'] ?? map['semester'] ?? '').toString(),
      accountStatus: (map['accountStatus'] ?? 'Active').toString(),
      avatarInitials: (map['avatarInitials'] ?? 'SA').toString(),
      faculty: (map['faculty'] ?? '').toString(),
      programme: (map['programme'] ?? '').toString(),
    );
  }
}
