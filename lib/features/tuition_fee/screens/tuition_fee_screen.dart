import 'package:flutter/material.dart';

import '../../../shared/widgets/module_shell_screen.dart';
import '../../../core/theme/app_colors.dart';

/// Tuition Fee and Payment module placeholder
/// To be fully implemented in Phase 2 of refactoring
class TuitionFeeAndPaymentScreen extends StatelessWidget {
  const TuitionFeeAndPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleShellScreen(
      title: 'Tuition Fee and Payment',
      subtitle:
          'Review tuition fees, complete payments, and keep transaction records clear before academic deadlines.',
      icon: Icons.account_balance_wallet_rounded,
      accent: AppColors.sunsetOrange,
      softAccent: AppColors.yellowSoft,
      tabs: [
        ModuleTabItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          content: _ComingSoon(),
        ),
        ModuleTabItem(
          label: 'Fee',
          icon: Icons.payments_outlined,
          content: _ComingSoon(),
        ),
        ModuleTabItem(
          label: 'Receipt',
          icon: Icons.receipt_long_outlined,
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
