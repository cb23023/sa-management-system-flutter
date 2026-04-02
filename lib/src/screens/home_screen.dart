import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/module_card.dart';
import '../widgets/phone_frame.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user, required this.onLogout});

  final AppUser user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final modules = [
      const ModuleCardData(
        code: 'M1',
        title: 'Open Registration',
        subtitle:
            'Register and manage subjects for the current semester in a wider, cleaner dashboard.',
        status: 'Live',
        foreground: AppColors.studentBlue,
        background: AppColors.infoSoft,
        enabled: true,
        icon: Icons.menu_book_rounded,
      ),
      const ModuleCardData(
        code: 'M2',
        title: 'Co-Curriculum',
        subtitle:
            'Activities, participation, and credit claim tools are grouped into one unified module card.',
        status: 'Live',
        foreground: AppColors.treasuryTeal,
        background: AppColors.tealSoft,
        enabled: true,
        icon: Icons.groups_rounded,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: PhoneFrame(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SummaryCard(
                      label: 'Quick Overview',
                      title: 'Modernized Home',
                      description:
                          'This fallback home screen follows the new SAMS visual system and responsive layout.',
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Welcome, ${user.fullName}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Main modules are presented in a broader and more standard card layout.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...modules.map(
                      (module) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ModuleCard(data: module, onTap: () {}),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout'),
                    ),
                  ],
                ),
              ),
              AppBottomNav(currentIndex: 0, onTap: (_) {}),
            ],
          ),
        ),
      ),
    );
  }
}
