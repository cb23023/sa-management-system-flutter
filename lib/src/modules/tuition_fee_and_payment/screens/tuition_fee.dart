import 'package:flutter/material.dart';

import '../../../models/app_user.dart';
import '../../../theme/app_colors.dart';
import '../controllers/payment_controller.dart';
import '../models/tuition_fees.dart';
import 'payment_form.dart';

class TuitionFee extends StatelessWidget {
  const TuitionFee({super.key, this.user});

  final AppUser? user;
  static final PaymentController _paymentController = PaymentController();

  @override
  Widget build(BuildContext context) {
    if (user == null) return const _LoadingPlaceholder();

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
        final programFee = data?.programFee ?? 0.0;
        final otherFee = data?.otherFee ?? 0.0;
        final totalFee = programFee + otherFee;
        final programme = data?.programme.isNotEmpty == true
            ? data!.programme
            : 'Not available';
        final semester = data?.semester.isNotEmpty == true
            ? data!.semester
            : user!.semester;
        final dueDate = data?.dueDate ?? '';
        final outstandingAmount = data?.outstandingAmount ?? totalFee;
        final paymentStatus = data?.paymentStatus.trim().toLowerCase() ?? '';
        final isPaid = outstandingAmount <= 0 ||
            paymentStatus == 'paid' ||
            paymentStatus == 'verified';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  const Text('Your Programme',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    programme,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Semester',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 3),
                          Text(
                            semester,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('ID',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 3),
                          Text(
                            user!.identifier,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Fee Breakdown',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _FeeBreakdownItem(
                label: programme,
                amount: 'RM ${programFee.toStringAsFixed(2)}'),
            _FeeBreakdownItem(
                label: 'Other Fees',
                amount: 'RM ${otherFee.toStringAsFixed(2)}'),
            const Divider(height: 22, thickness: 1.2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Tuition Fee',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                Text('RM ${totalFee.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.studentBlue)),
              ],
            ),
            const SizedBox(height: 16),
            if (isPaid)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.25)),
                ),
                child: const Text(
                  'Your tuition fee has been fully paid. Please refer to the Receipt tab for payment record.',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              )
            else if (dueDate.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.infoSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.studentBlue.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'Payment due on $dueDate. Please pay to avoid access block.',
                  style: const TextStyle(
                    color: AppColors.studentBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.studentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: isPaid
                    ? null
                    : () {
                        _showPaymentForm(context, totalFee, user);
                      },
                child: Text(
                  isPaid ? 'Payment Completed' : 'Pay Now',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentForm(
      BuildContext context, double amount, AppUser? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          PaymentFormSheet(amount: amount, user: user),
    );
  }
}

// ─── Receipt tab ──────────────────────────────────────────────────────────────

class _FeeBreakdownItem extends StatelessWidget {
  const _FeeBreakdownItem({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textDark))),
          Text(amount,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
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


