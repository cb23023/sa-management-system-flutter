import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../theme/app_colors.dart';
import '../../controllers/tuition_fee_and_payment/receipt_controller.dart';
import '../../models/tuition_fee_and_payment/payment_transactions.dart';

class Receipt extends StatefulWidget {
  const Receipt({super.key, this.user});

  final AppUser? user;

  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  final ReceiptController _receiptController = ReceiptController();
  bool _isDownloading = false;

  Future<void> _downloadReceipt(PaymentTransaction transaction) async {
    setState(() => _isDownloading = true);
    try {
      await _receiptController.exportReceiptPdf(transaction);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt PDF downloaded successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to download receipt PDF: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    if (user == null) return const _LoadingPlaceholder();

    return StreamBuilder<PaymentTransaction?>(
      stream: _receiptController.getReceiptStream(
        user.uid,
        matricId: user.identifier,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingPlaceholder();
        }

        final transaction = snapshot.data;
        if (transaction == null) {
          return const _EmptyState(
            icon: Icons.receipt_long_outlined,
            message: 'No payment receipts found.\nComplete a payment to see your receipt here.',
          );
        }

        final reference = transaction.referenceNo;
        final amount = transaction.amount;
        final createdAt = transaction.createdAt;
        final method = transaction.paymentMethod;
        final bankRef = transaction.bankRef;
        final verifiedBy =
            transaction.verifiedBy.isEmpty ? 'Pending' : transaction.verifiedBy;
        final semester =
            transaction.semester.isEmpty ? user.semester : transaction.semester;

        final isSuccess = transaction.isVerified;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSuccess ? AppColors.greenSoft : AppColors.warningSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: (isSuccess ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Icon(
                    isSuccess
                        ? Icons.check_circle_outline
                        : Icons.hourglass_top_rounded,
                    color: isSuccess ? AppColors.success : AppColors.warning,
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isSuccess ? 'Payment Verified' : 'Payment Pending Verification',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isSuccess
                            ? AppColors.success
                            : AppColors.warning),
                  ),
                  const SizedBox(height: 6),
                  Text(createdAt,
                      style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 12),
                  Text(
                    'Reference no. $reference',
                    style: const TextStyle(
                        color: AppColors.studentBlue,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ReceiptRow(label: 'Student ID', value: user.identifier),
            _ReceiptRow(label: 'Name', value: user.fullName),
            _ReceiptRow(label: 'Semester', value: semester),
            _ReceiptRow(
                label: 'Amount paid',
                value: 'RM ${amount.toStringAsFixed(2)}'),
            _ReceiptRow(label: 'Payment method', value: method),
            _ReceiptRow(label: 'Bank ref', value: bankRef),
            _ReceiptRow(label: 'Verified by', value: verifiedBy),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.studentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed:
                    _isDownloading ? null : () => _downloadReceipt(transaction),
                icon: _isDownloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: Text(
                  _isDownloading
                      ? 'Generating PDF...'
                      : 'Download Receipt (PDF)',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Notices tab ──────────────────────────────────────────────────────────────

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textMuted)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w700)),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
