import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SaManagementSystemApp());
}

// ============================================================================
// REFACTORING IN PROGRESS:
// This app is undergoing a structural refactoring from monolithic to 
// feature-based architecture. See REFACTORING_SUMMARY.md for details.
//
// New structure:
// - core/: App-wide utilities (theme, constants, services, widgets)
// - features/: Feature modules (auth, home, open_registration, etc.)
// - shared/: Shared components across features
// - scripts/: Utility scripts
//
// OLD CODE in src/ continues to work during migration.
// ============================================================================
