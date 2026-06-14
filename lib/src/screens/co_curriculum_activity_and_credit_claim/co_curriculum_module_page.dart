// =============================================================================
// SAMMS-PACK-201 | co_curriculum_module_page.dart
// Class Type    : Screen (Library Root)
// Responsibility: Displays the Co-Curriculum Activity and Credit Claim module
//   shell based on the user role. Loads role-based subtitle, accent colour,
//   soft accent colour, and module tabs for Student, Lecturer, and Pusat Adab.
//   This file is the part-of library root — all other files in this module
//   are declared as `part of` this file and compiled as a single library.
// Attributes   : role (CoCurriculumRole), userName (String), userUid (String)
// Methods      : build, _subtitleForRole, _accentForRole,
//                _softAccentForRole, _tabsForRole
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../modules/module_shell_screen.dart';

// Controllers — Firestore logic for activities, claims, and grading
part '../../controllers/co_curriculum_activity_and_credit_claim/activity_controller.dart';
part '../../controllers/co_curriculum_activity_and_credit_claim/claim_controller.dart';
part '../../controllers/co_curriculum_activity_and_credit_claim/grading_controller.dart';

// Screens — each tab and sub-page for this module
part 'dashboard.dart';
part 'activities_page.dart';
part 'claims_page.dart';
part 'review_page.dart';
part 'grading_page.dart';
part 'notification_area.dart';

// Shared — reusable UI components and utility functions for this module
part 'shared_components.dart';
part 'shared_models_and_utils.dart';

// CoCurriculumModulePage — entry point widget for the Co-Curriculum module.
// Delegates rendering to ModuleShellScreen using role-based configuration.
class CoCurriculumModulePage extends StatelessWidget {
  const CoCurriculumModulePage({
    super.key,
    this.role = CoCurriculumRole.student,
    this.userName = 'System User',
    this.userUid = '',
  });

  final CoCurriculumRole role;
  final String userName;
  final String userUid;

  @override
  // build — constructs the ModuleShellScreen with the module title, role-based
  // subtitle, groups icon, accent colour, soft accent, and role-specific tabs.
  Widget build(BuildContext context) {
    return ModuleShellScreen(
      title: 'Co-Curriculum Activity and Credit Claim',
      subtitle: _subtitleForRole(role),
      icon: Icons.groups_rounded,
      accent: _accentForRole(role),
      softAccent: _softAccentForRole(role),
      tabs: _tabsForRole(role, userName, userUid),
    );
  }
}

// CoCurriculumActivityAndCreditClaimScreen — public alias for CoCurriculumModulePage,
// used as the named route target throughout the app navigation.
class CoCurriculumActivityAndCreditClaimScreen extends CoCurriculumModulePage {
  const CoCurriculumActivityAndCreditClaimScreen({
    super.key,
    super.role,
    super.userName,
    super.userUid,
  });
}

// CoCurriculumRole — identifies the three user types supported by this module.
enum CoCurriculumRole { student, pusatAdab, lecturer }

// _subtitleForRole — returns the descriptive subtitle shown below the module
// title based on the user role (student, pusatAdab, or lecturer).
String _subtitleForRole(CoCurriculumRole role) {
  switch (role) {
    case CoCurriculumRole.student:
      return 'Join activities, track progress, and submit your credit claim.';
    case CoCurriculumRole.pusatAdab:
      return 'Manage activities and review student claims.';
    case CoCurriculumRole.lecturer:
      return 'Manage your activities and enter student marks.';
  }
}

// _accentForRole — returns the primary accent colour used in headers and
// action buttons based on the user role.
Color _accentForRole(CoCurriculumRole role) {
  switch (role) {
    case CoCurriculumRole.student:
      return AppColors.studentBlue;
    case CoCurriculumRole.pusatAdab:
      return AppColors.treasuryTeal;
    case CoCurriculumRole.lecturer:
      return AppColors.studentBlue;
  }
}

// _softAccentForRole — returns the soft/pastel background colour used in
// cards and badges based on the user role.
Color _softAccentForRole(CoCurriculumRole role) {
  switch (role) {
    case CoCurriculumRole.student:
      return AppColors.infoSoft;
    case CoCurriculumRole.pusatAdab:
      return AppColors.tealSoft;
    case CoCurriculumRole.lecturer:
      return AppColors.infoSoft;
  }
}

// _tabsForRole — builds the tab list for the ModuleShellScreen.
//   Student  : Dashboard, Activities, Claims, Notifications
//   PusatAdab: Dashboard, Activities, Review, Notifications
//   Lecturer : Dashboard, Activities, Grading, Notifications
// Each Notifications tab receives a _ModuleNotificationBadge as its badge.
List<ModuleTabItem> _tabsForRole(
  CoCurriculumRole role,
  String userName,
  String userUid,
) {
  switch (role) {
    case CoCurriculumRole.student:
      return [
        ModuleTabItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          content: _Dashboard(role: role, userName: userName, userUid: userUid),
        ),
        ModuleTabItem(
          label: 'Activities',
          icon: Icons.event_note_outlined,
          content: _ActivitiesPage(role: role, userUid: userUid),
        ),
        ModuleTabItem(
          label: 'Claims',
          icon: Icons.assignment_turned_in_outlined,
          content: _ClaimsPage(studentUid: userUid),
        ),
        ModuleTabItem(
          label: 'Notifications',
          icon: Icons.notifications_active_outlined,
          content: _NotificationArea(userUid: userUid, role: role),
          badgeBuilder: (_) => _ModuleNotificationBadge(userUid: userUid),
        ),
      ];
    case CoCurriculumRole.pusatAdab:
      return [
        ModuleTabItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          content: _Dashboard(role: role, userName: userName, userUid: userUid),
        ),
        ModuleTabItem(
          label: 'Activities',
          icon: Icons.event_note_outlined,
          content: _ActivitiesPage(role: role, userUid: userUid),
        ),
        const ModuleTabItem(
          label: 'Review',
          icon: Icons.rule_folder_outlined,
          content: _ReviewPage(),
        ),
        ModuleTabItem(
          label: 'Notifications',
          icon: Icons.notifications_active_outlined,
          content: _NotificationArea(userUid: userUid, role: role),
          badgeBuilder: (_) => _ModuleNotificationBadge(userUid: userUid),
        ),
      ];
    case CoCurriculumRole.lecturer:
      return [
        ModuleTabItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          content: _Dashboard(role: role, userName: userName, userUid: userUid),
        ),
        ModuleTabItem(
          label: 'Activities',
          icon: Icons.event_note_outlined,
          content: _ActivitiesPage(role: role, userUid: userUid),
        ),
        ModuleTabItem(
          label: 'Grading',
          icon: Icons.grading_outlined,
          content: _GradingPage(lecturerUid: userUid),
        ),
        ModuleTabItem(
          label: 'Notifications',
          icon: Icons.notifications_active_outlined,
          content: _NotificationArea(userUid: userUid, role: role),
          badgeBuilder: (_) => _ModuleNotificationBadge(userUid: userUid),
        ),
      ];
  }
}
