part of 'co_curriculum_module_page.dart';

class _ClaimsPage extends StatelessWidget {
  const _ClaimsPage({required this.studentUid});

  final String studentUid;

  @override
  Widget build(BuildContext context) {
    return _StudentClaimsTab(studentUid: studentUid);
  }
}

class _StudentClaimsTab extends StatefulWidget {
  const _StudentClaimsTab({required this.studentUid});

  final String studentUid;

  @override
  State<_StudentClaimsTab> createState() => _StudentClaimsTabState();
}

class _ClaimResultPage extends StatelessWidget {
  const _ClaimResultPage({required this.claimId});

  final String claimId;

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: 'Claim Result',
      subtitle: 'Student',
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _claimController.creditClaims.doc(claimId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _MessageCard(
              title: 'Loading claim result',
              message: 'Retrieving the latest review decision.',
              color: AppColors.studentBlue,
              background: AppColors.infoSoft,
            );
          }
          final data = snapshot.data?.data();
          if (data == null) {
            return const _MessageCard(
              title: 'Claim not found',
              message: 'The selected claim result is no longer available.',
              color: AppColors.warning,
              background: AppColors.warningSoft,
            );
          }
          final status = (data['claimStatus'] ?? 'pending').toString();
          final statusLower = _safeLower(status);
          final reviewedAt = _parseDynamicDate(data['reviewedAt']);
          final remarks = (data['remarks'] ?? 'Pending staff review.')
              .toString();
          final rejectionReason = (data['rejectionReason'] ?? '')
              .toString()
              .trim();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HistoryCard(
                title: 'Co-curriculum claim result',
                detail:
                    '${data['totalHours'] ?? 0} hours  |  ${data['totalCats'] ?? 0} CATS  |  Avg ${data['averageMark'] ?? 0}%',
                statusLabel: status.isEmpty
                    ? 'Pending'
                    : '${status[0].toUpperCase()}${status.substring(1)}',
                statusColor: statusLower == 'approved'
                    ? AppColors.success
                    : statusLower == 'rejected'
                    ? AppColors.danger
                    : AppColors.warning,
                statusBackground: statusLower == 'approved'
                    ? AppColors.successSoft
                    : statusLower == 'rejected'
                    ? AppColors.dangerSoft
                    : AppColors.warningSoft,
              ),
              const SizedBox(height: 12),
              _MessageCard(
                title: 'Reviewed date',
                message: reviewedAt == null
                    ? 'This claim has not been reviewed yet.'
                    : _displayDate(reviewedAt),
                color: AppColors.studentBlue,
                background: AppColors.infoSoft,
              ),
              const SizedBox(height: 12),
              _MessageCard(
                title: 'Remarks',
                message: remarks,
                color: AppColors.treasuryTeal,
                background: AppColors.tealSoft,
              ),
              if (statusLower == 'rejected' && rejectionReason.isNotEmpty) ...[
                const SizedBox(height: 12),
                _MessageCard(
                  title: 'Rejection reason',
                  message: rejectionReason,
                  color: AppColors.danger,
                  background: AppColors.dangerSoft,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StudentClaimsTabState extends State<_StudentClaimsTab> {
  final Set<String> _selectedActivityIds = <String>{};
  bool _submitting = false;

  Future<void> _submitClaim(
    BuildContext context,
    List<Map<String, dynamic>> eligibleActivities,
  ) async {
    if (_selectedActivityIds.length != 4 || _submitting) {
      return;
    }

    try {
      final selected = eligibleActivities
          .where((item) => _selectedActivityIds.contains(item['activityId']))
          .toList();
      final invalidSelection =
          selected.length != 4 ||
          selected.any(
            (item) =>
                ((item['totalMarks'] as num?)?.toInt() ?? 0) <= 0 ||
                _safeLower(item['registrationStatus']) != 'completed' ||
                _safeLower(item['attendanceStatus']) != 'present',
          );
      if (invalidSelection) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Credit claim cannot proceed. Select exactly four completed activities with present attendance and marks.',
            ),
          ),
        );
        return;
      }
      final shouldSubmit = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Submit Credit Claim'),
            content: Text(
              'Submit claim for ${selected.length} completed activities?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
      if (shouldSubmit != true) {
        return;
      }
      if (!context.mounted) {
        return;
      }
      setState(() {
        _submitting = true;
      });
      final claimId = 'claim-${widget.studentUid}';
      final result = await _claimController.submitClaim({
        'id': claimId,
        'studentId': widget.studentUid,
        'activityIds': selected
            .map((item) => item['activityId'].toString())
            .toList(),
        'remarks': 'Submitted by student for Pusat Adab review.',
      });

      if (!context.mounted) return;
      if (result['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (result['message'] ?? 'Unable to submit claim right now.')
                  .toString(),
            ),
          ),
        );
        return;
      }
      setState(() {
        _selectedActivityIds.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (result['message'] ?? 'Credit claim submitted successfully.')
                .toString(),
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to submit claim right now.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.studentUid.trim().isEmpty) {
      return const _MessageCard(
        title: 'Student profile unavailable',
        message: 'No student identifier was found for this session.',
        color: AppColors.warning,
        background: AppColors.warningSoft,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _claimController.activityRegistrations
          .where('studentId', isEqualTo: widget.studentUid)
          .snapshots(),
      builder: (context, registrationSnapshot) {
        final registrationDocs =
            registrationSnapshot.data?.docs ??
            <QueryDocumentSnapshot<Map<String, dynamic>>>[];

        return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: _claimController.attendanceRecords
              .where('studentId', isEqualTo: widget.studentUid)
              .get(),
          builder: (context, attendanceSnapshot) {
            final attendanceDocs =
                attendanceSnapshot.data?.docs ??
                <QueryDocumentSnapshot<Map<String, dynamic>>>[];
            final attendanceReadyIds = attendanceDocs
                .where((doc) {
                  final data = doc.data();
                  return _isAttendancePresent(data);
                })
                .map((doc) => _attendanceActivityId(doc.data()))
                .toSet();

            return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: _claimController.activities.get(),
              builder: (context, activitySnapshot) {
                final activityDocs =
                    activitySnapshot.data?.docs ??
                    <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                final activitiesById = {
                  for (final doc in activityDocs) doc.id: doc.data(),
                };

                final eligibleActivities = registrationDocs
                    .where(
                      (doc) =>
                          _safeLower(doc.data()['status']) == 'completed' &&
                          attendanceReadyIds.contains(
                            (doc.data()['activityId'] ?? '').toString(),
                          ) &&
                          ((doc.data()['totalMarks'] as num?)?.toInt() ?? 0) >
                              0,
                    )
                    .map((doc) {
                      final data = doc.data();
                      final activityId = (data['activityId'] ?? '').toString();
                      final activityData =
                          activitiesById[activityId] ?? <String, dynamic>{};
                      return <String, dynamic>{
                        'activityId': activityId,
                        'title':
                            (activityData['title'] ??
                                    activityData['name'] ??
                                    activityId)
                                .toString(),
                        'date': (activityData['date'] ?? '').toString(),
                        'venue': (activityData['venue'] ?? '').toString(),
                        'hours':
                            ((activityData['hours'] as num?)?.toInt() ?? 0),
                        'cats':
                            ((activityData['cats'] ??
                                        activityData['creditValue'])
                                    as num?)
                                ?.toInt() ??
                            0,
                        'registrationStatus': (data['status'] ?? '').toString(),
                        'attendanceStatus': 'present',
                        'totalMarks':
                            ((data['totalMarks'] as num?)?.toInt() ?? 0),
                      };
                    })
                    .toList();

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _claimController.creditClaims
                      .where('studentId', isEqualTo: widget.studentUid)
                      .snapshots(),
                  builder: (context, claimSnapshot) {
                    final claimDocs =
                        claimSnapshot.data?.docs ??
                        <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                    final hasLockedClaim = claimDocs.any((doc) {
                      final status = _safeLower(doc.data()['claimStatus']);
                      return status == 'pending' || status == 'approved';
                    });
                    final selectedActivities = eligibleActivities
                        .where(
                          (item) => _selectedActivityIds.contains(
                            (item['activityId'] ?? '').toString(),
                          ),
                        )
                        .toList();
                    final selectedTotalMarks = selectedActivities.fold<int>(
                      0,
                      (acc, item) =>
                          acc + (((item['totalMarks'] as num?)?.toInt()) ?? 0),
                    );
                    final selectedAverageMark = selectedActivities.isEmpty
                        ? 0
                        : (selectedTotalMarks / selectedActivities.length)
                              .round();
                    final selectedTotalHours = selectedActivities.fold<int>(
                      0,
                      (acc, item) =>
                          acc + (((item['hours'] as num?)?.toInt()) ?? 0),
                    );
                    final selectedTotalCats = selectedActivities.fold<int>(
                      0,
                      (acc, item) =>
                          acc + (((item['cats'] as num?)?.toInt()) ?? 0),
                    );
                    final sortedClaimDocs = [...claimDocs]
                      ..sort((a, b) {
                        final aDate = _parseDynamicDate(
                          a.data()['submittedAt'],
                        );
                        final bDate = _parseDynamicDate(
                          b.data()['submittedAt'],
                        );
                        return (bDate?.millisecondsSinceEpoch ?? 0).compareTo(
                          aDate?.millisecondsSinceEpoch ?? 0,
                        );
                      });

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
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: AppColors.infoSoft,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.assignment_turned_in_outlined,
                                      color: AppColors.studentBlue,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Prepare claim',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          hasLockedClaim
                                              ? 'You already have an active claim.'
                                              : 'Choose 4 completed activities.',
                                          style: const TextStyle(
                                            fontSize: 11.2,
                                            color: AppColors.textMuted,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _StatusBadge(
                                    label: hasLockedClaim ? 'Locked' : 'Open',
                                    background: hasLockedClaim
                                        ? AppColors.warningSoft
                                        : AppColors.tealSoft,
                                    color: hasLockedClaim
                                        ? AppColors.warning
                                        : AppColors.treasuryTeal,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _InfoPill(
                                    icon: Icons.checklist_rounded,
                                    text:
                                        '${_selectedActivityIds.length} / 4 selected',
                                  ),
                                  _InfoPill(
                                    icon: Icons.schedule_rounded,
                                    text: '$selectedTotalHours hours',
                                  ),
                                  _InfoPill(
                                    icon: Icons.workspace_premium_outlined,
                                    text: '$selectedTotalCats CATS',
                                  ),
                                  _InfoPill(
                                    icon: Icons.bar_chart_rounded,
                                    text: 'Avg $selectedAverageMark%',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (eligibleActivities.isEmpty)
                                const _MessageCard(
                                  title: 'No eligible activity',
                                  message:
                                      'Complete 4 activities before submitting your claim.',
                                  color: AppColors.warning,
                                  background: AppColors.warningSoft,
                                  compact: true,
                                )
                              else ...[
                                ...eligibleActivities.map((item) {
                                  final activityId = (item['activityId'] ?? '')
                                      .toString();
                                  final isSelected = _selectedActivityIds
                                      .contains(activityId);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: InkWell(
                                      onTap: hasLockedClaim
                                          ? null
                                          : () {
                                              setState(() {
                                                if (isSelected) {
                                                  _selectedActivityIds.remove(
                                                    activityId,
                                                  );
                                                } else if (_selectedActivityIds
                                                        .length <
                                                    4) {
                                                  _selectedActivityIds.add(
                                                    activityId,
                                                  );
                                                }
                                              });
                                            },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 11,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.infoSoft
                                              : AppColors.grayOne,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.studentBlue
                                                : AppColors.border,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isSelected
                                                  ? Icons.check_circle_rounded
                                                  : Icons
                                                        .radio_button_unchecked,
                                              color: isSelected
                                                  ? AppColors.studentBlue
                                                  : AppColors.textMuted,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    (item['title'] ?? '')
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors.textDark,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Wrap(
                                                    spacing: 6,
                                                    runSpacing: 6,
                                                    children: [
                                                      _MiniMetaChip(
                                                        icon: Icons
                                                            .calendar_today_outlined,
                                                        text:
                                                            (item['date'] ?? '')
                                                                .toString(),
                                                      ),
                                                      _MiniMetaChip(
                                                        icon: Icons
                                                            .location_on_outlined,
                                                        text:
                                                            (item['venue'] ??
                                                                    '')
                                                                .toString(),
                                                      ),
                                                      _MiniMetaChip(
                                                        icon: Icons
                                                            .grading_outlined,
                                                        text:
                                                            '${item['totalMarks']}%',
                                                      ),
                                                      _MiniMetaChip(
                                                        icon: Icons
                                                            .schedule_rounded,
                                                        text:
                                                            '${item['hours']} hours',
                                                      ),
                                                      _MiniMetaChip(
                                                        icon: Icons
                                                            .workspace_premium_outlined,
                                                        text:
                                                            '${item['cats']} CATS',
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 8),
                                _ActionChip(
                                  label: hasLockedClaim
                                      ? 'Claim already submitted'
                                      : _submitting
                                      ? 'Submitting...'
                                      : 'Submit Credit Claim',
                                  background:
                                      hasLockedClaim ||
                                          _selectedActivityIds.length != 4
                                      ? AppColors.grayOne
                                      : AppColors.studentBlue,
                                  color:
                                      hasLockedClaim ||
                                          _selectedActivityIds.length != 4
                                      ? AppColors.textMuted
                                      : Colors.white,
                                  icon: Icons.assignment_turned_in_outlined,
                                  onTap:
                                      hasLockedClaim ||
                                          _selectedActivityIds.length != 4
                                      ? null
                                      : () => _submitClaim(
                                          context,
                                          eligibleActivities,
                                        ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Claim history',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (sortedClaimDocs.isEmpty)
                                const Text(
                                  'No claim submitted yet.',
                                  style: TextStyle(
                                    fontSize: 11.2,
                                    color: AppColors.textMuted,
                                  ),
                                )
                              else
                                ...sortedClaimDocs.map((doc) {
                                  final data = doc.data();
                                  final status =
                                      (data['claimStatus'] ?? 'pending')
                                          .toString();
                                  final statusLower = _safeLower(status);
                                  final activityIds =
                                      ((data['activityIds']
                                                  as List<dynamic>?) ??
                                              <dynamic>[])
                                          .map((item) => item.toString())
                                          .toList();
                                  final submittedAt = _parseDynamicDate(
                                    data['submittedAt'],
                                  );
                                  final reviewedAt = _parseDynamicDate(
                                    data['reviewedAt'],
                                  );
                                  final remarks =
                                      (data['remarks'] ??
                                              'Pending staff review.')
                                          .toString()
                                          .trim();
                                  final rejectionReason =
                                      (data['rejectionReason'] ?? '')
                                          .toString()
                                          .trim();
                                  final detail =
                                      '${activityIds.length} activities  |  ${data['totalHours'] ?? 0} hours  |  ${data['totalCats'] ?? 0} CATS';
                                  final footer = submittedAt == null
                                      ? 'Submitted date unavailable'
                                      : 'Submitted ${_displayDate(submittedAt)}';
                                  final reviewedSuffix = reviewedAt == null
                                      ? ''
                                      : '\nReviewed ${_displayDate(reviewedAt)}';
                                  final remarksSuffix = remarks.isEmpty
                                      ? ''
                                      : '\nRemarks: $remarks';
                                  final reasonSuffix =
                                      statusLower == 'rejected' &&
                                          rejectionReason.isNotEmpty
                                      ? '\nReason: $rejectionReason'
                                      : '';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _HistoryCard(
                                      title: 'Co-curriculum claim set',
                                      detail:
                                          '$detail  |  $footer$reviewedSuffix$remarksSuffix$reasonSuffix',
                                      statusLabel:
                                          status[0].toUpperCase() +
                                          status.substring(1),
                                      statusColor: statusLower == 'approved'
                                          ? AppColors.success
                                          : statusLower == 'rejected'
                                          ? AppColors.danger
                                          : AppColors.warning,
                                      statusBackground:
                                          statusLower == 'approved'
                                          ? AppColors.successSoft
                                          : statusLower == 'rejected'
                                          ? AppColors.dangerSoft
                                          : AppColors.warningSoft,
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
              },
            );
          },
        );
      },
    );
  }
}
