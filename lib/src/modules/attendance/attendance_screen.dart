import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../module_shell_screen.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleShellScreen(
      title: 'Attendance',
      subtitle:
          'Manage attendance sessions, student check-ins, and reliable records for academic activities.',
      icon: Icons.fact_check_rounded,
      accent: AppColors.violet,
      softAccent: AppColors.purpleSoft,
      tabs: const [
        ModuleTabItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          content: _ModuleBlock(
            title: 'Dashboard',
            description:
                'Show current sessions, attendance summaries, missed check-ins, and module shortcuts.',
          ),
        ),
        ModuleTabItem(
          label: 'Attendance',
          icon: Icons.fact_check_outlined,
          content: _ModuleBlock(
            title: 'Attendance',
            description:
                'Handle session creation, check-in controls, verification rules, and attendance records.',
          ),
        ),
        ModuleTabItem(
          label: 'Reports',
          icon: Icons.bar_chart_rounded,
          content: _ModuleBlock(
            title: 'Reports',
            description:
                'Generate attendance summaries, analytics, exports, and supporting records for review.',
          ),
        ),
        ModuleTabItem(
          label: 'Exit',
          icon: Icons.logout_rounded,
          content: _ModuleBlock(
            title: 'Exit',
            description:
                'Leave this module and return to the main application home.',
          ),
        ),
      ],
    );
  }
}

class _ModuleBlock extends StatelessWidget {
  const _ModuleBlock({required this.title, required this.description});

  final String title;
  final String description;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
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
