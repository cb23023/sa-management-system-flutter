import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../controllers/notification_controller.dart';
import '../models/payment_transactions.dart';
import '../models/tuition_fees.dart';

class TreasuryDashboard extends StatelessWidget {
  const TreasuryDashboard({super.key});

  static final NotificationController _notificationController =
      NotificationController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TuitionFees>>(
      stream: _notificationController.getAllTuitionFeesStream(),
      builder: (context, feeSnap) {
        return StreamBuilder<List<PaymentTransaction>>(
          stream: _notificationController.getPendingTransactionsStream(),
          builder: (context, txnSnap) {
            if (feeSnap.connectionState == ConnectionState.waiting ||
                txnSnap.connectionState == ConnectionState.waiting) {
              return const _LoadingPlaceholder();
            }

            final fees = feeSnap.data ?? [];
            final underReview = txnSnap.data ?? [];

            int paid = 0, unpaid = 0, pending = 0, blocked = 0;
            for (final fee in fees) {
              final status = fee.paymentStatus;
              final isBlocked = fee.isBlocked;
              if (isBlocked) {
                blocked++;
              }
              if (status == 'Paid' || status == 'Verified') {
                paid++;
              } else if (status == 'Pending') {
                pending++;
              } else {
                unpaid++;
              }
            }

            pending = underReview.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'Treasury Dashboard'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _MetricCard(
                        label: 'Paid',
                        value: '$paid',
                        color: AppColors.success,
                        background: AppColors.greenSoft),
                    _MetricCard(
                        label: 'Unpaid',
                        value: '$unpaid',
                        color: AppColors.danger,
                        background: AppColors.coralSoft),
                    _MetricCard(
                        label: 'Pending verify',
                        value: '$pending',
                        color: AppColors.warning,
                        background: AppColors.warningSoft),
                    _MetricCard(
                        label: 'Blocked',
                        value: '$blocked',
                        color: AppColors.treasuryTeal,
                        background: AppColors.tealSoft),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('Students under review',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (underReview.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('No students pending review.',
                        style: TextStyle(color: AppColors.textMuted)),
                  )
                else
                  ...underReview.take(5).map((txn) {
                    final name = txn.studentName.isEmpty ? '-' : txn.studentName;
                    final id = txn.matricId.isEmpty ? '-' : txn.matricId;
                    final status = txn.status;
                    return _StudentStatusCard(
                      name: name,
                      id: id,
                      subtitle: txn.semester.isEmpty ? '-' : txn.semester,
                      status: status,
                      statusColor: status == 'Verified'
                          ? AppColors.success
                          : status == 'Pending'
                              ? AppColors.warning
                              : AppColors.danger,
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }
}

// ─── Verify tab ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark));
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final String label;
  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: color.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: CircularProgressIndicator(),
      ),
    );
  }
}


class _StudentStatusCard extends StatelessWidget {
  const _StudentStatusCard({
    required this.name,
    required this.id,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  final String name;
  final String id;
  final String subtitle;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.studentBlue,
            child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(id, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

