import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../controllers/tuition_fee_and_payment/notification_controller.dart';
import '../../controllers/tuition_fee_and_payment/receipt_controller.dart';
import '../../models/tuition_fee_and_payment/payment_transactions.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final NotificationController _notificationController =
      NotificationController();
  late final Stream<List<PaymentTransaction>> _transactionsStream;
  Timer? _searchDebounce;
  String _filterStatus = 'All';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _transactionsStream = _notificationController.getAllTransactionsStream();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
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

  void _showTransactionDialog(PaymentTransaction transaction) {
    showDialog(
      context: context,
      builder: (ctx) => _TransactionRecordDialog(txnDoc: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase();

    return StreamBuilder<List<PaymentTransaction>>(
      stream: _transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingPlaceholder();
        }

        final allDocs = snapshot.data ?? [];
        final filtered = allDocs.where((transaction) {
          final name = transaction.studentName.toLowerCase();
          final id = transaction.matricId.toLowerCase();
          final status = transaction.status;
          final matchesSearch =
              query.isEmpty || name.contains(query) || id.contains(query);
          final matchesFilter =
              _filterStatus == 'All' || status == _filterStatus;
          return matchesSearch && matchesFilter;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionHeader(title: 'Transaction Records'),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by student name or ID',
                prefixIcon: const Icon(
                  Icons.search_outlined,
                  color: AppColors.textMuted,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(
                        Icons.close_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: _clearSearch,
                    );
                  },
                ),
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
                  borderSide:
                      const BorderSide(color: AppColors.treasuryTeal, width: 2),
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: ['All', 'Verified', 'Pending', 'Rejected']
                  .map(
                    (status) => Expanded(
                      child: _StatusFilterTab(
                        label: status,
                        selected: _filterStatus == status,
                        onTap: () => setState(() => _filterStatus = status),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offsetAnimation, child: child),
                );
              },
              child: filtered.isEmpty
                  ? Center(
                      key: ValueKey('empty-$_filterStatus-$query'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          query.isEmpty
                              ? 'No transactions found.'
                              : 'No transactions matching "$query"',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  : Column(
                      key: ValueKey('list-$_filterStatus-$query'),
                      children: filtered.map((transaction) {
                        return _TransactionItem(
                          name: transaction.studentName.isEmpty
                              ? '-'
                              : transaction.studentName,
                          amount:
                              'RM ${transaction.amount.toStringAsFixed(2)}',
                          reference: transaction.referenceNo,
                          method: transaction.paymentMethod,
                          status: transaction.status,
                          statusColor: transaction.statusColor,
                          onTap: () => _showTransactionDialog(transaction),
                        );
                      }).toList(),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusFilterTab extends StatelessWidget {
  const _StatusFilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: selected ? AppColors.treasuryTeal : AppColors.grayOne,
              borderRadius: borderRadius,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.treasuryTeal.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              splashColor: Colors.white.withValues(alpha: 0.18),
              highlightColor: AppColors.treasuryTeal.withValues(alpha: 0.08),
              hoverColor: AppColors.treasuryTeal.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  child: Text(label, textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionRecordDialog extends StatefulWidget {
  const _TransactionRecordDialog({required this.txnDoc});

  final PaymentTransaction txnDoc;

  @override
  State<_TransactionRecordDialog> createState() =>
      _TransactionRecordDialogState();
}

class _TransactionRecordDialogState extends State<_TransactionRecordDialog> {
  final ReceiptController _receiptController = ReceiptController();
  bool _isExporting = false;

  Future<void> _exportReceipt() async {
    setState(() => _isExporting = true);
    try {
      await _receiptController.exportReceiptPdf(widget.txnDoc);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt PDF exported successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to export receipt PDF: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final txnDoc = widget.txnDoc;
    final name = txnDoc.studentName.isEmpty ? '-' : txnDoc.studentName;
    final ref = txnDoc.referenceNo;
    final amount = 'RM ${txnDoc.amount.toStringAsFixed(2)}';
    final date = _formatDate(txnDoc.createdAt);
    final method = txnDoc.paymentMethod;
    final statusColor = txnDoc.statusColor;
    final isReceipt = txnDoc.isVerified;
    final isRejected = txnDoc.isRejected;
    final recordTitle = isReceipt ? '$name - Receipt' : '$name - Payment Record';
    final helperText = isReceipt
        ? 'Receipt details for the selected payment.'
        : isRejected
            ? 'This payment was rejected by treasury.'
            : 'This payment is still waiting for treasury verification.';
    final cardColor =
        isReceipt ? AppColors.greenSoft : statusColor.withValues(alpha: 0.08);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 390,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaction Record',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                helperText,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recordTitle,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isReceipt
                                ? Icons.receipt_long_outlined
                                : Icons.hourglass_top_rounded,
                            color: statusColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ref,
                            style: const TextStyle(
                              color: AppColors.studentBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _StatusPill(status: txnDoc.status, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Divider(
                      height: 1,
                      color: statusColor.withValues(alpha: 0.22),
                    ),
                    const SizedBox(height: 14),
                    _ReceiptRow(
                      label: isReceipt ? 'Reference no.' : 'Transaction no.',
                      value: ref,
                    ),
                    const SizedBox(height: 10),
                    _ReceiptRow(label: 'Amount', value: amount),
                    const SizedBox(height: 10),
                    _ReceiptRow(label: 'Date', value: date),
                    const SizedBox(height: 10),
                    _ReceiptRow(label: 'Method', value: method),
                    const SizedBox(height: 16),
                    if (isReceipt)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.studentBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isExporting ? null : _exportReceipt,
                          icon: _isExporting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.picture_as_pdf_outlined,
                                  size: 18,
                                ),
                          label: Text(
                            _isExporting
                                ? 'Generating PDF...'
                                : 'Export Receipt (PDF)',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          isRejected
                              ? 'Receipt is not available for rejected payment.'
                              : 'Receipt will be available after treasury verifies this payment.',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
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

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso);
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
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

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

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({
    required this.name,
    required this.amount,
    required this.reference,
    required this.method,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  final String name, amount, reference, method, status;
  final Color statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: borderRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              splashColor: AppColors.treasuryTeal.withValues(alpha: 0.12),
              highlightColor: AppColors.treasuryTeal.withValues(alpha: 0.06),
              hoverColor: AppColors.treasuryTeal.withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
            children: [
              Expanded(
                child: Text(
                  '$name - $amount',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              _StatusPill(status: status, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reference,
            style: const TextStyle(
              color: AppColors.studentBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            method,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});

  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
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
