import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../module_shell_screen.dart';

class OpenRegistrationAndSubjectRegistrationScreen extends StatelessWidget {
  const OpenRegistrationAndSubjectRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleShellScreen(
      title: 'Open Registration and Subject Registration',
      subtitle:
          'View subject offerings and register within programme rules, prerequisites, schedules, and credit limits.',
      icon: Icons.menu_book_rounded,
      accent: AppColors.studentBlue,
      softAccent: AppColors.infoSoft,
      tabs: const [
        ModuleTabItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          content: _ModuleBlock(
            title: 'Dashboard',
            description:
                'Show registration period, available credits, subject totals, and quick access to current actions.',
          ),
        ),
        ModuleTabItem(
          label: 'Subjects',
          icon: Icons.library_books_outlined,
          content: _ModuleBlock(
            title: 'Subjects',
            description:
                'List offered subjects, prerequisites, schedules, and available sections for each semester.',
          ),
        ),
        ModuleTabItem(
          label: 'Registration',
          icon: Icons.how_to_reg_outlined,
          content: _ModuleBlock(
            title: 'Registration',
            description:
                'Handle subject selection with conflict checks, prerequisite validation, and credit limit control.',
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
