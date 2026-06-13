/// App user model representing authenticated user data
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
  });

  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String identifier;
  final String semester;
  final String accountStatus;
  final String avatarInitials;

  /// Creates AppUser from Firestore document data
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
    );
  }

  @override
  String toString() => 'AppUser(uid: $uid, fullName: $fullName, email: $email, role: $role)';
}
