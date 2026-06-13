part of 'co_curriculum_module_page.dart';

class _ExitBlock extends StatelessWidget {
  const _ExitBlock();

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
            'Exit Module',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Use the back button in the module header to return to the main dashboard.',
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

class _RoleBanner extends StatelessWidget {
  const _RoleBanner({
    required this.role,
    required this.title,
    required this.subtitle,
  });

  final CoCurriculumRole role;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _softAccentForRole(role),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.verified_user_outlined,
                  color: _accentForRole(role),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _roleLabel(role),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _DashboardProfileCard extends StatelessWidget {
  const _DashboardProfileCard({
    required this.name,
    required this.roleLabel,
    required this.icon,
    required this.color,
    required this.background,
    required this.subtitle,
  });

  final String name;
  final String roleLabel;
  final IconData icon;
  final Color color;
  final Color background;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusBadge(
                  label: roleLabel,
                  background: background,
                  color: color,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.2,
                    color: AppColors.textMuted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetricData {
  const _DashboardMetricData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color background;
}

class _DashboardSummaryCard extends StatelessWidget {
  const _DashboardSummaryCard({required this.title, required this.metrics});

  final String title;
  final List<_DashboardMetricData> metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              final itemWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: metrics
                    .map(
                      (item) => SizedBox(
                        width: itemWidth,
                        child: _MetricCard(
                          icon: item.icon,
                          label: item.label,
                          value: item.value,
                          color: item.color,
                          background: item.background,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardStatusCard extends StatelessWidget {
  const _DashboardStatusCard({required this.ready});

  final bool ready;

  @override
  Widget build(BuildContext context) {
    final readinessColor = ready ? AppColors.success : AppColors.warning;
    final readinessBackground = ready
        ? AppColors.successSoft
        : AppColors.warningSoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: readinessBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  ready
                      ? Icons.check_circle_outline_rounded
                      : Icons.schedule_outlined,
                  size: 18,
                  color: readinessColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ready
                        ? 'You can prepare your claim now.'
                        : 'Complete 4 activities before submitting your claim.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: readinessColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.studentBlue,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hours and CATS update after attendance is confirmed.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.studentBlue,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.title,
    required this.meta,
    this.lecturer,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBackground,
    required this.note,
    required this.primaryAction,
    required this.secondaryAction,
    this.tertiaryAction,
    this.onPrimaryTap,
    this.onSecondaryTap,
    this.onTertiaryTap,
  });

  final String title;
  final String meta;
  final String? lecturer;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackground;
  final String note;
  final String primaryAction;
  final String secondaryAction;
  final String? tertiaryAction;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onTertiaryTap;

  IconData get _primaryIcon {
    final action = _safeLower(primaryAction);
    if (action.contains('view')) {
      return Icons.visibility_outlined;
    }
    if (action.contains('cancel')) {
      return Icons.cancel_outlined;
    }
    if (action.contains('register')) {
      return Icons.how_to_reg_rounded;
    }
    return Icons.edit_outlined;
  }

  IconData get _secondaryIcon {
    final action = _safeLower(secondaryAction);
    if (action.contains('grade')) {
      return Icons.grading_outlined;
    }
    if (action.contains('detail')) {
      return Icons.visibility_outlined;
    }
    return Icons.groups_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              _StatusBadge(
                label: statusLabel,
                color: statusColor,
                background: statusBackground,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ActivityMetaWrap(meta: meta),
          if (lecturer != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.school_outlined,
                  size: 15,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    lecturer!,
                    style: const TextStyle(
                      fontSize: 10.8,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            note,
            style: const TextStyle(
              fontSize: 10.8,
              color: AppColors.textDark,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionChip(
                  label: primaryAction,
                  background:
                      onPrimaryTap == null &&
                          _safeLower(primaryAction).contains('register')
                      ? AppColors.grayOne
                      : statusColor,
                  color:
                      onPrimaryTap == null &&
                          _safeLower(primaryAction).contains('register')
                      ? AppColors.textMuted
                      : Colors.white,
                  icon: _primaryIcon,
                  onTap: onPrimaryTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionChip(
                  label: secondaryAction,
                  background: AppColors.grayOne,
                  color: AppColors.textDark,
                  icon: _secondaryIcon,
                  onTap: onSecondaryTap,
                ),
              ),
              if (tertiaryAction != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionChip(
                    label: tertiaryAction!,
                    background: AppColors.danger,
                    color: Colors.white,
                    icon: Icons.delete_outline_rounded,
                    onTap: onTertiaryTap,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ClaimCard extends StatelessWidget {
  const _ClaimCard({
    required this.title,
    required this.detail,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBackground,
    required this.actionLabel,
    this.enabled = true,
  });

  final String title;
  final String detail;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackground;
  final String actionLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              _StatusBadge(
                label: statusLabel,
                color: statusColor,
                background: statusBackground,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 10.8,
              color: AppColors.textMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _ActionChip(
            label: actionLabel,
            background: enabled ? statusColor : AppColors.grayOne,
            color: enabled ? Colors.white : AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.title,
    required this.detail,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBackground,
  });

  final String title;
  final String detail;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusBadge(
            label: statusLabel,
            color: statusColor,
            background: statusBackground,
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.color,
    required this.background,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String message;
  final String actionLabel;
  final Color color;
  final Color background;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              fontSize: 10.8,
              color: AppColors.textMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          _ActionChip(
            label: actionLabel,
            background: color,
            color: Colors.white,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _ReviewClaimCard extends StatelessWidget {
  const _ReviewClaimCard({
    required this.studentName,
    required this.matricId,
    required this.activityTitles,
    required this.activityItems,
    required this.claimStatus,
    required this.totalHours,
    required this.totalCats,
    required this.averageMark,
    required this.allModulesPassed,
    required this.submittedAt,
    required this.attendanceStatus,
    required this.rejectionReason,
    required this.onOpenActivityTap,
    this.onApproveTap,
    this.onRejectTap,
  });

  final String studentName;
  final String matricId;
  final List<String> activityTitles;
  final List<Map<String, dynamic>> activityItems;
  final String claimStatus;
  final int totalHours;
  final int totalCats;
  final int averageMark;
  final bool allModulesPassed;
  final DateTime? submittedAt;
  final String attendanceStatus;
  final String rejectionReason;
  final void Function(String activityId, String title) onOpenActivityTap;
  final VoidCallback? onApproveTap;
  final VoidCallback? onRejectTap;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = _safeLower(claimStatus);
    final canReview = normalizedStatus == 'pending';
    final statusColor = normalizedStatus == 'approved'
        ? AppColors.success
        : normalizedStatus == 'rejected'
        ? AppColors.danger
        : AppColors.warning;
    final statusBackground = normalizedStatus == 'approved'
        ? AppColors.successSoft
        : normalizedStatus == 'rejected'
        ? AppColors.dangerSoft
        : AppColors.warningSoft;
    final statusLabel = normalizedStatus.isEmpty
        ? 'Pending'
        : '${normalizedStatus[0].toUpperCase()}${normalizedStatus.substring(1)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (matricId.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        matricId,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusBadge(
                label: statusLabel,
                color: statusColor,
                background: statusBackground,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (submittedAt != null)
                _ReviewMetaChip(
                  icon: Icons.calendar_today_outlined,
                  label: _displayDate(submittedAt!),
                ),
              _ReviewMetaChip(
                icon: Icons.schedule_outlined,
                label: '$totalHours hours',
              ),
              _ReviewMetaChip(
                icon: Icons.workspace_premium_outlined,
                label: '$totalCats CATS',
              ),
              _ReviewMetaChip(
                icon: Icons.bar_chart_rounded,
                label: 'Avg $averageMark%',
              ),
              _ReviewMetaChip(
                icon: allModulesPassed
                    ? Icons.check_circle_outline_rounded
                    : Icons.warning_amber_rounded,
                label: allModulesPassed ? 'Pass >= 40%' : 'Below 40%',
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...activityItems.map((item) {
            final attendanceStatus = _safeLower(item['attendanceStatus']);
            final attendanceLabel = attendanceStatus.isEmpty
                ? 'Present'
                : '${attendanceStatus[0].toUpperCase()}${attendanceStatus.substring(1)}';
            final marks = (item['marks'] ?? 0).toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grayOne,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: InkWell(
                  onTap: () => onOpenActivityTap(
                    (item['id'] ?? '').toString(),
                    (item['title'] ?? '').toString(),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          (item['title'] ?? '').toString(),
                          style: const TextStyle(
                            fontSize: 10.8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.studentBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        attendanceLabel,
                        style: const TextStyle(
                          fontSize: 10.2,
                          color: AppColors.studentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$marks%',
                        style: const TextStyle(
                          fontSize: 10.4,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (normalizedStatus == 'rejected' &&
              rejectionReason.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rejection reason',
                    style: TextStyle(
                      fontSize: 10.8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rejectionReason,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textDark,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (canReview) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ActionChip(
                    label: 'Approve',
                    background: AppColors.success,
                    color: Colors.white,
                    icon: Icons.check_circle_outline_rounded,
                    onTap: onApproveTap,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionChip(
                    label: 'Reject',
                    background: AppColors.danger,
                    color: Colors.white,
                    icon: Icons.close_rounded,
                    onTap: onRejectTap,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RosterCard extends StatelessWidget {
  const _RosterCard({
    required this.activityTitle,
    required this.countLabel,
    required this.students,
  });

  final String activityTitle;
  final String countLabel;
  final List<String> students;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activityTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            countLabel,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          ...students.map(
            (student) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.infoSoft,
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 12,
                      color: AppColors.studentBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      student,
                      style: const TextStyle(
                        fontSize: 10.8,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.title,
    required this.message,
    required this.color,
    required this.background,
    this.compact = false,
  });

  final String title;
  final String message;
  final Color color;
  final Color background;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: compact ? 10.8 : 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              fontSize: compact ? 10.2 : 10.8,
              color: color.withValues(alpha: 0.92),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityMetaWrap extends StatelessWidget {
  const _ActivityMetaWrap({required this.meta});

  final String meta;

  @override
  Widget build(BuildContext context) {
    final parts = meta
        .split('|')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final icons = <IconData>[
      Icons.category_outlined,
      Icons.calendar_today_outlined,
      Icons.location_on_outlined,
      Icons.schedule_outlined,
      Icons.workspace_premium_outlined,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(parts.length, (index) {
        final icon = index < icons.length ? icons[index] : Icons.info_outline;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.grayOne,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(
                parts[index],
                style: const TextStyle(
                  fontSize: 10.4,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.background,
    required this.color,
    this.icon,
    this.onTap,
  });

  final String label;
  final Color background;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: color),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.8,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
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

class _ReviewMetaChip extends StatelessWidget {
  const _ReviewMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.grayOne,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 10.4, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.grayOne,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 10.4, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}

class _InlineBadge extends StatelessWidget {
  const _InlineBadge({
    required this.text,
    required this.color,
    required this.background,
  });

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.8,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MiniMetaChip extends StatelessWidget {
  const _MiniMetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 9.8, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}

class _PageShell extends StatelessWidget {
  const _PageShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        toolbarHeight: 76,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.darkSurface,
                AppColors.studentBlue,
                AppColors.treasuryTeal,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo-sams.png', width: 30, height: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
