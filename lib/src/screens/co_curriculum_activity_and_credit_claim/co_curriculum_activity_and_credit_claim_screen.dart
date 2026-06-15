import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../global/module_shell_screen.dart';

class CoCurriculumActivityAndCreditClaimScreen extends StatelessWidget {
  const CoCurriculumActivityAndCreditClaimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleShellScreen(
      title: 'Co Curriculum Activity and Credit Claim',
      subtitle:
          'Join approved activities, submit credit claims, and validate records with attendance-based checks.',
      icon: Icons.groups_rounded,
      accent: AppColors.treasuryTeal,
      softAccent: AppColors.tealSoft,
      tabs: const [
        ModuleTabItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          content: _ModuleBlock(
            title: 'Dashboard',
            description:
                'Show activity highlights, pending claims, approved credits, and quick actions for this module.',
          ),
        ),
        ModuleTabItem(
          label: 'Activities',
          icon: Icons.event_note_outlined,
          content: _ModuleBlock(
            title: 'Activities',
            description:
                'List approved activities, participation details, schedules, and join controls for students.',
          ),
        ),
        ModuleTabItem(
          label: 'Claims',
          icon: Icons.assignment_turned_in_outlined,
          content: _ModuleBlock(
            title: 'Claims',
            description:
                'Handle credit claim submission, review flow, validation rules, and claim history tracking.',
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
