part of 'co_curriculum_module_page.dart';

class _ReviewPage extends StatelessWidget {
  const _ReviewPage();

  @override
  Widget build(BuildContext context) {
    return const _PusatAdabClaimsTab();
  }
}

class _ReviewClaimRecord {
  const _ReviewClaimRecord({
    required this.claimId,
    required this.sourceClaimIds,
    required this.studentName,
    required this.studentId,
    required this.matricId,
    required this.activityTitles,
    required this.activityIds,
    required this.activityItems,
    required this.claimStatus,
    required this.submittedAt,
    required this.totalHours,
    required this.totalCats,
    required this.averageMark,
    required this.allModulesPassed,
    required this.attendanceStatus,
    required this.claimNotes,
    required this.rejectionReason,
  });

  final String claimId;
  final List<String> sourceClaimIds;
  final String studentName;
  final String studentId;
  final String matricId;
  final List<String> activityTitles;
  final List<String> activityIds;
  final List<Map<String, dynamic>> activityItems;
  final String claimStatus;
  final DateTime? submittedAt;
  final int totalHours;
  final int totalCats;
  final int averageMark;
  final bool allModulesPassed;
  final String attendanceStatus;
  final String claimNotes;
  final String rejectionReason;
}

class _PusatAdabClaimsTab extends StatefulWidget {
  const _PusatAdabClaimsTab();

  @override
  State<_PusatAdabClaimsTab> createState() => _PusatAdabClaimsTabState();
}

class _ClaimReviewLoaderPage extends StatelessWidget {
  const _ClaimReviewLoaderPage({required this.claimId});

  final String claimId;

  Future<_ReviewClaimRecord?> _loadRecord() async {
    final snapshot = await _claimController.creditClaims
        .where(FieldPath.documentId, isEqualTo: claimId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    final records = await _claimController.buildClaimRecords(snapshot.docs);
    return records.isEmpty ? null : records.first;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ReviewClaimRecord?>(
      future: _loadRecord(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _PageShell(
            title: 'Claim Review',
            subtitle: 'Pusat Adab',
            child: _MessageCard(
              title: 'Loading claim',
              message: 'Preparing claim details for review.',
              color: AppColors.studentBlue,
              background: AppColors.infoSoft,
            ),
          );
        }
        final record = snapshot.data;
        if (record == null) {
          return const _PageShell(
            title: 'Claim Review',
            subtitle: 'Pusat Adab',
            child: _MessageCard(
              title: 'Claim not found',
              message: 'The selected claim is no longer available.',
              color: AppColors.warning,
              background: AppColors.warningSoft,
            ),
          );
        }
        return _ClaimReviewPage(
          claimId: record.claimId,
          sourceClaimIds: record.sourceClaimIds,
          studentId: record.studentId,
          studentName: record.studentName,
          activityTitles: record.activityTitles,
          initialAction: 'Approve',
          currentStatus: record.claimStatus,
          submittedAt: record.submittedAt,
          totalHours: record.totalHours,
          totalCats: record.totalCats,
          averageMark: record.averageMark,
          allModulesPassed: record.allModulesPassed,
          attendanceStatus: record.attendanceStatus,
          claimNotes: record.claimNotes,
        );
      },
    );
  }
}

class _PusatAdabClaimsTabState extends State<_PusatAdabClaimsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _claimStatusFilter = 'Pending';
  String _dateFilter = 'All dates';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openClaimReview(
    BuildContext context,
    _ReviewClaimRecord record,
    String action,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ClaimReviewPage(
          claimId: record.claimId,
          sourceClaimIds: record.sourceClaimIds,
          studentId: record.studentId,
          studentName: record.studentName,
          activityTitles: record.activityTitles,
          initialAction: action,
          submittedAt: record.submittedAt,
          currentStatus: record.claimStatus,
          totalHours: record.totalHours,
          totalCats: record.totalCats,
          averageMark: record.averageMark,
          allModulesPassed: record.allModulesPassed,
          attendanceStatus: record.attendanceStatus,
          claimNotes: action == 'Approve'
              ? record.claimNotes
              : 'Use rejection only if there is a policy issue, duplicate submission, or record inconsistency requiring correction.',
        ),
      ),
    );
  }

  bool _matchesDateFilter(DateTime? value) {
    if (_dateFilter == 'All dates' || value == null) {
      return true;
    }
    final now = DateTime.now();
    if (_dateFilter == 'Today') {
      return value.year == now.year &&
          value.month == now.month &&
          value.day == now.day;
    }
    if (_dateFilter == 'This month') {
      return value.year == now.year && value.month == now.month;
    }
    return value.year == now.year;
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
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
              const Text(
                'Review claims',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Review submitted claims.',
                style: TextStyle(
                  fontSize: 11.2,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              _RectSearchField(
                controller: _searchController,
                hintText: 'Search student or activity',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Pending', 'Approved', 'Rejected']
                    .map(
                      (filter) => _FilterChipButton(
                        label: filter,
                        selected: _claimStatusFilter == filter,
                        onTap: () {
                          setState(() {
                            _claimStatusFilter = filter;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All dates', 'Today', 'This month', 'This year']
                    .map(
                      (filter) => _FilterChipButton(
                        label: filter,
                        selected: _dateFilter == filter,
                        onTap: () {
                          setState(() {
                            _dateFilter = filter;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _claimController.creditClaims.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _MessageCard(
                      title: 'Loading claims',
                      message: 'Please wait a moment.',
                      color: AppColors.studentBlue,
                      background: AppColors.infoSoft,
                    );
                  }

                  final docs =
                      snapshot.data?.docs ??
                      <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                  return FutureBuilder<List<_ReviewClaimRecord>>(
                    future: _claimController.buildClaimRecords(docs),
                    builder: (context, recordsSnapshot) {
                      if (recordsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const _MessageCard(
                          title: 'Preparing review list',
                          message: 'Getting everything ready.',
                          color: AppColors.studentBlue,
                          background: AppColors.infoSoft,
                        );
                      }

                      final allRecords =
                          recordsSnapshot.data ?? <_ReviewClaimRecord>[];
                      final records =
                          allRecords.where((record) {
                            final matchesStatus =
                                _claimStatusFilter == 'All' ||
                                _safeLower(record.claimStatus) ==
                                    _safeLower(_claimStatusFilter);
                            final matchesDate = _matchesDateFilter(
                              record.submittedAt,
                            );
                            final matchesQuery =
                                query.isEmpty ||
                                _safeLower(
                                  record.studentName,
                                ).contains(query) ||
                                _safeLower(record.matricId).contains(query) ||
                                record.activityTitles.any(
                                  (title) => _safeLower(title).contains(query),
                                );
                            return matchesStatus && matchesDate && matchesQuery;
                          }).toList()..sort((a, b) {
                            final aTime =
                                a.submittedAt?.millisecondsSinceEpoch ?? 0;
                            final bTime =
                                b.submittedAt?.millisecondsSinceEpoch ?? 0;
                            return bTime.compareTo(aTime);
                          });

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Claim records',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${records.length} records',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (records.isEmpty)
                            const _MessageCard(
                              title: 'No claim found',
                              message:
                                  'Try another keyword or filter to see matching claim submissions.',
                              color: AppColors.warning,
                              background: AppColors.warningSoft,
                            )
                          else
                            ...records.map(
                              (record) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ReviewClaimCard(
                                  studentName: record.studentName,
                                  matricId: record.matricId,
                                  activityTitles: record.activityTitles,
                                  activityItems: record.activityItems,
                                  claimStatus: record.claimStatus,
                                  totalHours: record.totalHours,
                                  totalCats: record.totalCats,
                                  averageMark: record.averageMark,
                                  allModulesPassed: record.allModulesPassed,
                                  submittedAt: record.submittedAt,
                                  attendanceStatus: record.attendanceStatus,
                                  rejectionReason: record.rejectionReason,
                                  onOpenActivityTap: (activityId, title) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => _ActivityDetailsPage(
                                          activityId: activityId,
                                          titleFallback: title,
                                        ),
                                      ),
                                    );
                                  },
                                  onApproveTap: () => _openClaimReview(
                                    context,
                                    record,
                                    'Approve',
                                  ),
                                  onRejectTap: () => _openClaimReview(
                                    context,
                                    record,
                                    'Reject',
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const _MessageCard(
          title: 'Decision result',
          message:
              'After review, the student receives a notification showing whether the claim is approved, pending, or rejected.',
          color: AppColors.studentBlue,
          background: AppColors.infoSoft,
        ),
      ],
    );
  }
}

class _ClaimReviewPage extends StatefulWidget {
  const _ClaimReviewPage({
    required this.claimId,
    required this.sourceClaimIds,
    required this.studentId,
    required this.studentName,
    required this.activityTitles,
    required this.initialAction,
    required this.currentStatus,
    required this.submittedAt,
    required this.totalHours,
    required this.totalCats,
    required this.averageMark,
    required this.allModulesPassed,
    required this.attendanceStatus,
    required this.claimNotes,
  });

  final String claimId;
  final List<String> sourceClaimIds;
  final String studentId;
  final String studentName;
  final List<String> activityTitles;
  final String initialAction;
  final String currentStatus;
  final DateTime? submittedAt;
  final int totalHours;
  final int totalCats;
  final int averageMark;
  final bool allModulesPassed;
  final String attendanceStatus;
  final String claimNotes;

  @override
  State<_ClaimReviewPage> createState() => _ClaimReviewPageState();
}

class _ClaimReviewPageState extends State<_ClaimReviewPage> {
  late final TextEditingController _rejectionReasonController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _rejectionReasonController = TextEditingController();
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isApprove = widget.initialAction == 'Approve';
    final rejectionReason = _rejectionReasonController.text.trim();

    return _PageShell(
      title: 'Claim Review',
      subtitle: 'Pusat Adab',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.activityTitles.length} completed activities',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.activityTitles
                      .map(
                        (title) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.grayOne,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 10.2,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                if (widget.submittedAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Submitted ${_displayDate(widget.submittedAt!)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  '${widget.totalHours} hours  |  ${widget.totalCats} CATS  |  Avg mark ${widget.averageMark}%',
                  style: const TextStyle(
                    fontSize: 11.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                _MessageCard(
                  title: 'Marks',
                  message: widget.allModulesPassed
                      ? 'All selected activities are ready for review.'
                      : 'Some selected activities are below the passing mark.',
                  color: widget.allModulesPassed
                      ? AppColors.success
                      : AppColors.warning,
                  background: widget.allModulesPassed
                      ? AppColors.successSoft
                      : AppColors.warningSoft,
                  compact: true,
                ),
                const SizedBox(height: 12),
                _StatusBadge(
                  label: widget.currentStatus.isEmpty
                      ? (isApprove ? 'Pending' : 'Pending')
                      : '${widget.currentStatus[0].toUpperCase()}${widget.currentStatus.substring(1)}',
                  color: isApprove ? AppColors.success : AppColors.danger,
                  background: isApprove
                      ? AppColors.successSoft
                      : AppColors.dangerSoft,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _MessageCard(
            title: 'Attendance validation',
            message: widget.attendanceStatus,
            color: AppColors.studentBlue,
            background: AppColors.infoSoft,
          ),
          const SizedBox(height: 10),
          _MessageCard(
            title: 'Decision notes',
            message: widget.claimNotes,
            color: AppColors.treasuryTeal,
            background: AppColors.tealSoft,
          ),
          const SizedBox(height: 14),
          if (isApprove)
            const _FormFieldCard(
              label: 'Reviewer remarks',
              value:
                  'Attendance cross-check completed. Decision will be recorded and sent to the student as a notification.',
              multiline: true,
            )
          else
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
                    'Rejection reason',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _rejectionReasonController,
                    maxLines: 4,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'State the reason for rejection',
                      filled: true,
                      fillColor: AppColors.grayOne,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
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
                        borderSide: const BorderSide(
                          color: AppColors.danger,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This reason will be stored and shown in the claim record.',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          _SubmitBar(
            primaryLabel: _saving
                ? 'Saving...'
                : isApprove
                ? 'Confirm Approval'
                : 'Confirm Rejection',
            secondaryLabel: 'Back',
            primaryColor: isApprove ? AppColors.success : AppColors.danger,
            onPrimaryTap: () {
              if (_saving) {
                return;
              }
              () async {
                if (!isApprove && rejectionReason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a reason before rejecting this claim.',
                      ),
                    ),
                  );
                  return;
                }
                if (isApprove &&
                    (!widget.allModulesPassed ||
                        !_safeLower(
                          widget.attendanceStatus,
                        ).contains('confirmed'))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Claim approval cannot proceed because attendance or marks validation failed.',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  _saving = true;
                });

                try {
                  final targetIds = widget.sourceClaimIds.isEmpty
                      ? [widget.claimId]
                      : widget.sourceClaimIds;
                  Map<String, dynamic> result = {
                    'success': true,
                    'message': '',
                  };
                  for (final id in targetIds) {
                    result = isApprove
                        ? await _claimController.approveClaim(id, 'pad-001')
                        : await _claimController.rejectClaim(
                            id,
                            'pad-001',
                            rejectionReason,
                          );
                    if (result['success'] != true) {
                      break;
                    }
                  }
                  if (!context.mounted) return;
                  if (result['success'] != true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          (result['message'] ??
                                  'Unable to update this claim right now.')
                              .toString(),
                        ),
                      ),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${result['message']} for ${widget.studentName}.',
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                } finally {
                  if (mounted) {
                    setState(() {
                      _saving = false;
                    });
                  }
                }
              }();
            },
            onSecondaryTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _FormFieldCard extends StatelessWidget {
  const _FormFieldCard({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: multiline ? 11.3 : 12.2,
              color: AppColors.textDark,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListInfoCard extends StatelessWidget {
  const _ListInfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

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
            title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10.8,
              color: AppColors.textMuted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.primaryColor,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final String primaryLabel;
  final String secondaryLabel;
  final Color primaryColor;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionChip(
            label: primaryLabel,
            background: primaryColor,
            color: Colors.white,
            onTap: onPrimaryTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionChip(
            label: secondaryLabel,
            background: AppColors.grayOne,
            color: AppColors.textDark,
            onTap: onSecondaryTap,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
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
        label,
        style: TextStyle(
          fontSize: 9.8,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
