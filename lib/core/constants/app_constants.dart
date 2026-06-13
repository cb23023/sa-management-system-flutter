/// Firebase Firestore collection names
/// Centralized constant to avoid hardcoded strings throughout the app.
class FirebaseCollections {
  // User management
  static const String users = 'users';

  // Registration & courses
  static const String subjects = 'subjects';
  static const String subjectOfferings = 'subject_offerings';
  static const String registrationPeriods = 'registration_periods';
  static const String subjectRegistrations = 'subject_registrations';

  // Co-curricular activities
  static const String activities = 'activities';
  static const String activityRegistrations = 'activity_registrations';
  static const String creditClaims = 'credit_claims';
  static const String attendanceRecords = 'attendance_records';

  // System notifications
  static const String notifications = 'notifications';
}

/// Common constant values across the app
class AppConstants {
  // Semester info
  static const String currentSemester = 'Semester 2, 2025/2026';

  // Roles
  static const String roleStudent = 'student';
  static const String roleLecturer = 'lecturer';
  static const String roleAdmin = 'admin';
  static const String roleRegistrar = 'faculty';
  static const String rolePustadAb = 'pusat_adab';

  // Default values
  static const int maxCreditHours = 9;
  static const String defaultAvatar = 'SA';

  // UI spacing
  static const double paddingXSmall = 8;
  static const double paddingSmall = 16;
  static const double paddingMedium = 24;
  static const double paddingLarge = 32;

  // Border radius
  static const double borderRadiusSmall = 12;
  static const double borderRadiusMedium = 20;
  static const double borderRadiusLarge = 28;
}

/// Error messages
class AppErrorMessages {
  static const String networkError = 'Network connection failed.';
  static const String invalidEmail = 'Invalid email format.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String userNotFound = 'No account found for this email.';
  static const String firebaseNotConfigured =
      'Firebase Auth is not fully configured.';
  static const String profileNotFound =
      'User profile not found in the database.';
  static const String unexpectedError = 'An unexpected error occurred.';
}
