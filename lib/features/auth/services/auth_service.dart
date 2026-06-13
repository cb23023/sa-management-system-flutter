import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

/// Handles authentication operations with Firebase
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Stream of authentication state changes
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Sign in with email and password
  /// Returns AppUser on successful authentication
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final credential = await _auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final signedInEmail =
        credential.user?.email?.trim().toLowerCase() ?? normalizedEmail;
    return getUserProfileByEmail(signedInEmail);
  }

  /// Retrieve user profile from Firestore using email as document ID
  Future<AppUser> getUserProfileByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final document = await _firestore
        .collection(FirebaseCollections.users)
        .doc(normalizedEmail)
        .get();

    if (!document.exists || document.data() == null) {
      throw Exception(
        'Firestore profile ${FirebaseCollections.users}/$normalizedEmail was not found.',
      );
    }

    return AppUser.fromMap(document.data()!);
  }

  /// Get current authenticated user's profile
  /// Returns null if no user is logged in
  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    final email = user?.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) {
      return null;
    }

    return getUserProfileByEmail(email);
  }

  /// Sign out current user
  Future<void> signOut() => _auth.signOut();
}

/// Firebase collection constants used by AuthService
class FirebaseCollections {
  static const String users = 'users';
}
