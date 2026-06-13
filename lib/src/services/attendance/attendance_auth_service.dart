import '../../models/app_user.dart';
import '../../services/auth_service.dart';

class AttendanceAuthService {
  AttendanceAuthService({AuthService? authService})
      : _auth = authService ?? AuthService();

  final AuthService _auth;

  Future<AppUser?> getCurrentUser() => _auth.getCurrentAppUser();

  Stream<AppUser?> get userStream => _auth.authStateChanges().asyncMap(
        (firebaseUser) async {
          if (firebaseUser == null) return null;
          return _auth.getCurrentAppUser();
        },
      );
}
