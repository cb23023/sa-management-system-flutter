import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

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

  Future<AppUser> getUserProfileByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final document = await _firestore
        .collection('users')
        .doc(normalizedEmail)
        .get();

    if (!document.exists || document.data() == null) {
      throw Exception(
        'Firestore profile users/$normalizedEmail was not found.',
      );
    }

    return AppUser.fromMap(document.data()!);
  }

  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    final email = user?.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) {
      return null;
    }

    return getUserProfileByEmail(email);
  }

  Future<void> signOut() => _auth.signOut();
}
