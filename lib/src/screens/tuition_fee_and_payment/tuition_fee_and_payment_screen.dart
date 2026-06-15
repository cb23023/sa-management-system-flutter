import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../global/module_shell_screen.dart';

class TuitionFeeAndPaymentScreen extends StatelessWidget {
  const TuitionFeeAndPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleShellScreen(
      title: 'Tuition Fee and Payment',
      subtitle:
          'Review tuition fees, complete payments, and keep transaction records clear before academic deadlines.',
      icon: Icons.account_balance_wallet_rounded,
      accent: AppColors.sunsetOrange,
      softAccent: AppColors.yellowSoft,
      tabs: const [
        ModuleTabItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          content: _ModuleBlock(
            title: 'Dashboard',
            description:
                'Show fee status, payment reminders, due items, and quick access to current transactions.',
          ),
        ),
        ModuleTabItem(
          label: 'Fee',
          icon: Icons.payments_outlined,
          content: _ModuleBlock(
            title: 'Fee',
            description:
                'Display tuition breakdown, registered subject charges, due dates, and outstanding balances.',
          ),
        ),
        ModuleTabItem(
          label: 'Receipt',
          icon: Icons.receipt_long_outlined,
          content: _ModuleBlock(
            title: 'Receipt',
            description:
                'Store payment receipts, transaction history, verification details, and printable proof records.',
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
