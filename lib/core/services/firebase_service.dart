import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_constants.dart';


/// Centralized Firebase Firestore service
/// Handles all Firestore-related operations with proper error handling and collection access
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() => _instance;

  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get reference to users collection
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection(FirebaseCollections.users);

  /// Get reference to subjects collection
  CollectionReference<Map<String, dynamic>> get subjectsCollection =>
      _firestore.collection(FirebaseCollections.subjects);

  /// Get reference to subject offerings collection
  CollectionReference<Map<String, dynamic>> get subjectOfferingsCollection =>
      _firestore.collection(FirebaseCollections.subjectOfferings);

  /// Get reference to any collection by name
  CollectionReference<Map<String, dynamic>> getCollection(String collectionName) =>
      _firestore.collection(collectionName);
}

