import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../modules/module_shell_screen.dart';

part '../../controllers/co_curriculum_activity_and_credit_claim/activity_controller.dart';
part '../../controllers/co_curriculum_activity_and_credit_claim/claim_controller.dart';
part '../../controllers/co_curriculum_activity_and_credit_claim/grading_controller.dart';
part 'dashboard.dart';
part 'activities_page.dart';
part 'claims_page.dart';
part 'review_page.dart';
part 'grading_page.dart';
part 'notification_area.dart';
part 'shared_components.dart';
part 'shared_models_and_utils.dart';

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

class CoCurriculumActivityAndCreditClaimScreen extends CoCurriculumModulePage {
  const CoCurriculumActivityAndCreditClaimScreen({
    super.key,
    super.role,
    super.userName,
    super.userUid,
  });
}

enum CoCurriculumRole { student, pusatAdab, lecturer }

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

String _roleLabel(CoCurriculumRole role) {
  switch (role) {
    case CoCurriculumRole.student:
      return 'Student';
    case CoCurriculumRole.pusatAdab:
      return 'Pusat Adab';
    case CoCurriculumRole.lecturer:
      return 'Lecturer';
  }
}

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
