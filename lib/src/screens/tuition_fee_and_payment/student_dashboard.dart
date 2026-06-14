import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../theme/app_colors.dart';
import '../../controllers/tuition_fee_and_payment/payment_controller.dart';
import '../../models/tuition_fee_and_payment/tuition_fees.dart';

// Student dashboard for SRS REQ-301/REQ-304:
// summarizes outstanding amount, deadline, pending verification, and blocked access.
class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key, this.user});

  final AppUser? user;
  static final PaymentController _paymentController = PaymentController();

  @override
  Widget build(BuildContext context) {
    if (user == null) return const _LoadingPlaceholder();

    // Live Firestore stream keeps payment and access status updated after
    // Student payment submission or Treasury verification.
    return StreamBuilder<TuitionFees?>(
      stream: _paymentController.getTuitionFeeStream(
        user!.uid,
        matricId: user!.identifier,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingPlaceholder();
        }

        final data = snapshot.data;
        final outstanding = data?.outstandingAmount ?? 0.0;
        final paymentStatus = data?.paymentStatus ?? 'Unpaid';
        final isPendingVerification =
            paymentStatus.trim().toLowerCase() == 'pending';
        final dueDate = data?.dueDate ?? '';
        final dueWeek = data?.dueWeek ?? 5;
        final blockedReason = data?.blockedReason ?? '';
        final semester = data?.semester.isNotEmpty == true
            ? data!.semester
            : user!.semester;
        final isBlocked = data?.isAccessBlocked ?? (outstanding > 0);

        // Each banner maps to an SRS state: pending verification, academic
        // restriction, and Week 5 payment reminder.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, ${user!.fullName}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.studentBlue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current semester',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    semester,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ID: ${user!.identifier}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        user!.role.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (isPendingVerification) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.infoSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.studentBlue.withValues(alpha: 0.25),
                  ),
                ),
                child: const Text(
                  'Payment submitted. Pending Treasury verification. Your outstanding amount will be cleared after approval.',
                  style: TextStyle(
                    color: AppColors.studentBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (isBlocked) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  blockedReason.isEmpty
                      ? 'Your access has been blocked because payment was not completed before Week $dueWeek. Please settle your outstanding fee.'
                      : blockedReason,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (dueDate.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  'Week $dueWeek payment deadline: $dueDate. Please settle before the deadline.',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment status',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Outstanding amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      _StatusPill(status: paymentStatus),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RM ${outstanding.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: outstanding > 0
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Fee Detail tab ───────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Paid':
      case 'Verified':
        bg = AppColors.greenSoft;
        fg = AppColors.success;
        break;
      case 'Pending':
        bg = AppColors.warningSoft;
        fg = AppColors.warning;
        break;
      default:
        bg = AppColors.dangerSoft;
        fg = AppColors.danger;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
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
