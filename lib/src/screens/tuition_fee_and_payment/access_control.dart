import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../controllers/tuition_fee_and_payment/notification_controller.dart';
import '../../models/tuition_fee_and_payment/tuition_fees.dart';

class AccessControl extends StatefulWidget {
  const AccessControl({super.key});

  @override
  State<AccessControl> createState() =>
      _AccessControlState();
}

class _AccessControlState
    extends State<AccessControl> {
  final TextEditingController _searchController = TextEditingController();
  final NotificationController _notificationController =
      NotificationController();
  late final Stream<List<TuitionFees>> _unpaidStudentsStream;
  Timer? _searchDebounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _unpaidStudentsStream = _notificationController.getUnpaidStudentsStream();
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

  Future<void> _toggleBlock(TuitionFees fee, bool currentlyBlocked) async {
    final studentName = fee.studentName.isEmpty ? 'Student' : fee.studentName;
    final newBlocked = !currentlyBlocked;

    try {
      if (newBlocked) {
        await _notificationController.blockStudent(fee);
      } else {
        await _notificationController.unblockStudent(fee);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newBlocked
              ? '$studentName has been blocked.'
              : '$studentName has been unblocked.'),
          backgroundColor:
              newBlocked ? AppColors.danger : AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger),
      );
    }
  }

  void _showConfirmDialog(
      BuildContext context, TuitionFees fee, bool isBlocked) {
    final name = fee.studentName.isEmpty ? 'Student' : fee.studentName;
    final isBlocking = !isBlocked;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isBlocking ? 'Block Student?' : 'Unblock Student?',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isBlocking
                ? 'Are you sure you want to block $name?'
                : 'Are you sure you want to unblock $name?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$name (${fee.matricId.isEmpty ? '-' : fee.matricId})',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(fee.semester.isEmpty ? '-' : fee.semester,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isBlocking
                    ? AppColors.coralSoft.withValues(alpha: 0.2)
                    : AppColors.successSoft.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: (isBlocking
                            ? AppColors.danger
                            : AppColors.success)
                        .withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBlocking
                        ? 'Blocked activities'
                        : 'Restored activities',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: isBlocking
                            ? AppColors.danger
                            : AppColors.success),
                  ),
                  const SizedBox(height: 10),
                  ...['Class registration', 'Exam entry',
                          'Results & academic records',
                          'Transcript request']
                      .map((item) => _ActivityBullet(
                          text: item,
                          color: isBlocking
                              ? AppColors.danger
                              : AppColors.success)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _toggleBlock(fee, isBlocked);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isBlocking ? AppColors.danger : AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: Text(isBlocking ? 'Block' : 'Unblock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TuitionFees>>(
      stream: _unpaidStudentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingPlaceholder();
        }

        final allDocs = snapshot.data ?? [];
        final filtered = _query.isEmpty
            ? allDocs
            : allDocs.where((fee) {
                final name = fee.studentName.toLowerCase();
                final id = fee.matricId.toLowerCase();
                return name.contains(_query.toLowerCase()) ||
                    id.contains(_query.toLowerCase());
              }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionHeader(title: 'Access Control'),
              const SizedBox(height: 6),
              const Text('Students with unpaid or pending fees',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.25)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Access control active',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 10),
                    Text(
                        'Students below have not settled their fees. Block or unblock academic access accordingly.',
                        style:
                            TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        color: AppColors.textMuted, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText:
                              'Search student name or ID',
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
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Students with unpaid fees',
                            style: TextStyle(
                                fontWeight: FontWeight.w700)),
                        Text('${filtered.length} students',
                            style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('No students found.',
                            style: TextStyle(
                                color: AppColors.textMuted)),
                      )
                    else
                      ...filtered.map((fee) {
                        final isBlocked = fee.isBlocked;
                        final status = fee.paymentStatus;
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: 10),
                          child: _BlockListItem(
                            name: fee.studentName.isEmpty
                                ? '-'
                                : fee.studentName,
                            id: fee.matricId.isEmpty ? '-' : fee.matricId,
                            semester:
                                fee.semester.isEmpty ? '-' : fee.semester,
                            amount:
                                'RM ${fee.outstandingAmount.toStringAsFixed(2)}',
                            paymentStatus: status,
                            blocked: isBlocked,
                            actionLabel:
                                isBlocked ? 'Unblock' : 'Block',
                            actionColor: isBlocked
                                ? AppColors.success
                                : AppColors.danger,
                            onActionTap: () => _showConfirmDialog(
                                context, fee, isBlocked),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Transactions tab ─────────────────────────────────────────────────────────

class _BlockListItem extends StatelessWidget {
  const _BlockListItem({
    required this.name,
    required this.id,
    required this.semester,
    required this.amount,
    required this.paymentStatus,
    required this.blocked,
    this.actionLabel,
    this.actionColor,
    this.onActionTap,
  });

  final String name, id, semester, amount, paymentStatus;
  final bool blocked;
  final String? actionLabel;
  final Color? actionColor;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(id,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(width: 8),
                    _StatusBadge(status: paymentStatus),
                  ],
                ),
                const SizedBox(height: 4),
                Text(semester,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
                Text(amount,
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (onActionTap != null && actionLabel != null)
            ConstrainedBox(
              constraints: const BoxConstraints(
                  minWidth: 80, maxWidth: 110),
              child: ElevatedButton(
                onPressed: onActionTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor ?? AppColors.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(actionLabel!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status,
          style: TextStyle(
              color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _ActivityBullet extends StatelessWidget {
  const _ActivityBullet({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textDark))),
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


class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
    );
  }
}
