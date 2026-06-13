import 'package:flutter/material.dart';

import '../../../shared/widgets/module_shell_screen.dart';
import '../../../core/theme/app_colors.dart';

/// Attendance module placeholder
/// To be fully implemented in Phase 2 of refactoring
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleShellScreen(
      title: 'Attendance',
      subtitle:
          'Manage attendance sessions, student check-ins, and reliable records for academic activities.',
      icon: Icons.fact_check_rounded,
      accent: AppColors.violet,
      softAccent: AppColors.purpleSoft,
      tabs: [
        ModuleTabItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          content: _ComingSoon(),
        ),
        ModuleTabItem(
          label: 'Attendance',
          icon: Icons.fact_check_outlined,
          content: _ComingSoon(),
        ),
        ModuleTabItem(
          label: 'Reports',
          icon: Icons.bar_chart_rounded,
          content: _ComingSoon(),
        ),
      ],
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This module is being refactored as part of the architecture upgrade. It will be fully functional soon.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
