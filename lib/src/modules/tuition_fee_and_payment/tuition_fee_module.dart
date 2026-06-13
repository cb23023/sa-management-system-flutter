import 'package:flutter/material.dart';

// This file is a module navigation wrapper, not a functional screen listed in the SDD.
import '../../models/app_user.dart';
import '../../theme/app_colors.dart';
import '../module_shell_screen.dart';
import 'screens/access_control.dart';
import 'screens/notification.dart';
import 'screens/receipt.dart';
import 'screens/student_dashboard.dart';
import 'screens/transaction.dart';
import 'screens/treasury_dashboard.dart';
import 'screens/tuition_fee.dart';
import 'screens/verify_payment.dart';

class TuitionFeeModule extends StatelessWidget {
  const TuitionFeeModule({super.key, this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    if (user?.role == 'treasury') {
      return const ModuleShellScreen(
        title: 'TREASURY - TUITION FEE MANAGEMENT',
        subtitle:
            'Verify student payments, manage access control, and review transaction records.',
        icon: Icons.account_balance_wallet_rounded,
        accent: AppColors.treasuryTeal,
        softAccent: AppColors.tealSoft,
        tabs: [
          ModuleTabItem(
            label: 'Dashboard',
            icon: Icons.dashboard_outlined,
            content: TreasuryDashboard(),
          ),
          ModuleTabItem(
            label: 'Verify',
            icon: Icons.verified_outlined,
            content: VerifyPayment(),
          ),
          ModuleTabItem(
            label: 'Access',
            icon: Icons.lock_outline,
            content: AccessControl(),
          ),
          ModuleTabItem(
            label: 'Records',
            icon: Icons.receipt_long_outlined,
            content: TransactionScreen(),
          ),
        ],
      );
    }

    return ModuleShellScreen(
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
          content: StudentDashboard(user: user),
        ),
        ModuleTabItem(
          label: 'Fee',
          icon: Icons.payments_outlined,
          content: TuitionFee(user: user),
        ),
        ModuleTabItem(
          label: 'Receipt',
          icon: Icons.receipt_long_outlined,
          content: Receipt(user: user),
        ),
        ModuleTabItem(
          label: 'Notices',
          icon: Icons.notifications_none,
          content: NotificationScreen(user: user),
        ),
      ],
    );
  }
}
