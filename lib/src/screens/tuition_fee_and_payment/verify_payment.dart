import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../controllers/tuition_fee_and_payment/notification_controller.dart';
import '../../models/tuition_fee_and_payment/payment_transactions.dart';

// Treasury verification screen for SRS REQ-305:
// reviews pending payment transactions and records verify/reject decisions.
class VerifyPayment extends StatefulWidget {
  const VerifyPayment({super.key});

  @override
  State<VerifyPayment> createState() => _VerifyPaymentState();
}

class _VerifyPaymentState extends State<VerifyPayment> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final NotificationController _notificationController =
      NotificationController();
  late final Stream<List<PaymentTransaction>> _pendingTransactionsStream;
  Timer? _searchDebounce;
  String _query = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Only Pending records appear here; verified and rejected records move to
    // the transaction history after processing.
    _pendingTransactionsStream = _notificationController
        .getPendingTransactionsStream();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() => _query = value);
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _processVerification(
    PaymentTransaction transaction,
    String action,
  ) async {
    // SDD algorithm branch: verify clears fees and restores access, while
    // reject keeps the student unpaid and sends remarks back to the student.
    setState(() => _isProcessing = true);
    try {
      if (action == 'verify') {
        await _notificationController.verifyPayment(
          transaction,
          _remarksController.text,
        );
      } else {
        await _notificationController.rejectPayment(
          transaction,
          _remarksController.text,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'verify'
                ? 'Payment verified successfully.'
                : 'Payment rejected with remarks.',
          ),
          backgroundColor: action == 'verify'
              ? AppColors.success
              : AppColors.danger,
        ),
      );
      setState(() {
        _remarksController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showVerifyDialog(PaymentTransaction transaction) {
    // Dialog shows the submitted evidence before Treasury confirms the status.
    _remarksController.clear();
    showDialog(
      context: context,
      builder: (ctx) => _VerifyDetailDialog(
        txnDoc: transaction,
        remarksController: _remarksController,
        isProcessing: _isProcessing,
        onVerify: () async {
          await _processVerification(transaction, 'verify');
          if (ctx.mounted && Navigator.canPop(ctx)) Navigator.pop(ctx);
        },
        onReject: () async {
          await _processVerification(transaction, 'reject');
          if (ctx.mounted && Navigator.canPop(ctx)) Navigator.pop(ctx);
        },
      ),
    ).then((_) {
      _remarksController.clear();
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PaymentTransaction>>(
      stream: _pendingTransactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingPlaceholder();
        }

        final allDocs = snapshot.data ?? [];
        final query = _normalizeSearchText(_query);
        final queryWords = query.split(' ').where((word) => word.isNotEmpty);
        final filtered = query.isEmpty
            ? allDocs
            : allDocs.where((transaction) {
                final searchableText = _normalizeSearchText(
                  [
                    transaction.studentName,
                    transaction.matricId,
                    transaction.studentId,
                    transaction.referenceNo,
                    transaction.paymentMethod,
                  ].join(' '),
                );
                return queryWords.every(searchableText.contains);
              }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionHeader(title: 'Verify Payment'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search student name or matric ID',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      if (value.text.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        tooltip: 'Clear search',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pending payments',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${filtered.length} records',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No pending payments found.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  else
                    ...filtered.map((transaction) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PendingPaymentItem(
                          name: transaction.studentName.isEmpty
                              ? '-'
                              : transaction.studentName,
                          matricId: transaction.matricId.isEmpty
                              ? '-'
                              : transaction.matricId,
                          amount: 'RM ${transaction.amount.toStringAsFixed(2)}',
                          method: transaction.paymentMethod,
                          date: _formatDate(transaction.createdAt),
                          onTap: () => _showVerifyDialog(transaction),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')} ${_monthName(dt.month)} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _normalizeSearchText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String _monthName(int m) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m];
  }
}

class _VerifyDetailDialog extends StatelessWidget {
  const _VerifyDetailDialog({
    required this.txnDoc,
    required this.remarksController,
    required this.isProcessing,
    required this.onVerify,
    required this.onReject,
  });

  final PaymentTransaction txnDoc;
  final TextEditingController remarksController;
  final bool isProcessing;
  final VoidCallback onVerify;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final amount = 'RM ${txnDoc.amount.toStringAsFixed(2)}';
    final method = txnDoc.paymentMethod;
    final bank = txnDoc.bank.isEmpty ? '-' : txnDoc.bank;
    final accountOrCard = txnDoc.accountOrCard.isEmpty
        ? '-'
        : txnDoc.accountOrCard;
    final date = txnDoc.createdAt.isEmpty ? '-' : txnDoc.createdAt;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 390,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verify Payment',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${txnDoc.studentName.isEmpty ? 'Student' : txnDoc.studentName} - ${txnDoc.matricId.isEmpty ? '-' : txnDoc.matricId}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tealSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Outstanding amount',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _DetailRow(label: 'Payment date', value: date),
              _DetailRow(label: 'Payment method', value: method),
              if (method == 'Online Transfer') ...[
                _DetailRow(label: 'Bank', value: bank),
                _DetailRow(label: 'Account number', value: accountOrCard),
              ] else
                _DetailRow(label: 'Card number', value: accountOrCard),
              const SizedBox(height: 14),
              const Text(
                'Remarks',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: remarksController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add remarks for reason to verify or reject',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.treasuryTeal,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.grayOne,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isProcessing ? null : onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.danger,
                              ),
                            )
                          : const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : onVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.treasuryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Verified'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isProcessing ? null : () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(
              color: AppColors.studentBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.grayOne,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Access Control tab ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    );
  }
}

class _PendingPaymentItem extends StatelessWidget {
  const _PendingPaymentItem({
    required this.name,
    required this.matricId,
    required this.amount,
    required this.method,
    required this.date,
    required this.onTap,
  });

  final String name, matricId, amount, method, date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: AppColors.treasuryTeal.withValues(alpha: 0.12),
          highlightColor: AppColors.treasuryTeal.withValues(alpha: 0.06),
          hoverColor: AppColors.treasuryTeal.withValues(alpha: 0.04),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: borderRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      matricId,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Pending',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$method • $date',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
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
