part of 'co_curriculum_module_page.dart';

class _ActivitiesPage extends StatelessWidget {
  const _ActivitiesPage({required this.role, required this.userUid});

  final CoCurriculumRole role;
  final String userUid;

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case CoCurriculumRole.student:
        return _StudentActivitiesTab(studentUid: userUid);
      case CoCurriculumRole.pusatAdab:
        return const _PusatAdabActivitiesTab();
      case CoCurriculumRole.lecturer:
        return _LecturerActivitiesTab(lecturerUid: userUid);
    }
  }
}

class _StudentActivitiesTab extends StatefulWidget {
  const _StudentActivitiesTab({required this.studentUid});

  final String studentUid;

  @override
  State<_StudentActivitiesTab> createState() => _StudentActivitiesTabState();
}

class _StudentActivitiesTabState extends State<_StudentActivitiesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _registerActivity(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> activityDoc,
  ) async {
    final data = activityDoc.data();
    final title = (data['title'] ?? data['name'] ?? activityDoc.id).toString();
    final status = _safeLower(data['status']);
    final capacity = ((data['capacity'] as num?)?.toInt() ?? 0);
    final participantsCount =
        ((data['participantsCount'] as num?)?.toInt() ?? 0);
    final availableSlots =
        ((data['availableSlots'] as num?)?.toInt() ??
        (capacity - participantsCount));
    final activityDate = _parseStoredDate(
      data['session_date']?.toString(),
      data['date']?.toString(),
    );
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (status != 'active' ||
        availableSlots <= 0 ||
        activityDate == null ||
        activityDate.isBefore(todayOnly)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration is not allowed for this activity.'),
        ),
      );
      return;
    }

    final shouldRegister = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Register Activity'),
          content: Text('Register for $title?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Register'),
            ),
          ],
        );
      },
    );

    if (shouldRegister != true) return;

    final result = await _activityController.registerActivity(
      activityId: activityDoc.id,
      studentUid: widget.studentUid,
      activityData: data,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          (result['message'] ?? 'Unable to register this activity.').toString(),
        ),
      ),
    );
  }

  Future<void> _cancelRegistration(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> activityDoc,
    QueryDocumentSnapshot<Map<String, dynamic>> registrationDoc,
  ) async {
    final activityData = activityDoc.data();
    final title =
        (activityData['title'] ?? activityData['name'] ?? activityDoc.id)
            .toString();
    final activityDate = _parseStoredDate(
      activityData['session_date']?.toString(),
      activityData['date']?.toString(),
    );
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (activityDate == null || !activityDate.isAfter(todayOnly)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration can only be cancelled before the activity date.',
          ),
        ),
      );
      return;
    }

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Registration'),
          content: Text('Cancel your registration for $title?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Back'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cancel Registration'),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) {
      return;
    }

    final result = await _activityController.cancelRegistration(
      activityId: activityDoc.id,
      studentUid: widget.studentUid,
      registrationId: registrationDoc.id,
      activityData: activityData,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          (result['message'] ?? 'Unable to cancel this registration.')
              .toString(),
        ),
      ),
    );
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

    final query = _safeLower(_searchController.text.trim());

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
                'Activity registration',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Browse approved activities, register, and track your own participation records.',
                style: TextStyle(
                  fontSize: 11.2,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              _RectSearchField(
                controller: _searchController,
                hintText: 'Search activity, category, venue',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Active', 'Registered', 'Closed']
                    .map(
                      (filter) => _FilterChipButton(
                        label: filter,
                        selected: _statusFilter == filter,
                        onTap: () {
                          setState(() {
                            _statusFilter = filter;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _activityController.activityRegistrations
                    .where('studentId', isEqualTo: widget.studentUid)
                    .snapshots(),
                builder: (context, registrationSnapshot) {
                  final allRegistrationDocs =
                      registrationSnapshot.data?.docs ??
                      <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                  final registrationDocs = allRegistrationDocs
                      .where(
                        (doc) =>
                            _safeLower(doc.data()['status']) != 'cancelled',
                      )
                      .toList();
                  final registrationsByActivityId = {
                    for (final doc in registrationDocs)
                      (doc.data()['activityId'] ?? '').toString(): doc,
                  };

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _activityController.attendanceRecords
                        .where('studentId', isEqualTo: widget.studentUid)
                        .snapshots(),
                    builder: (context, attendanceSnapshot) {
                      final attendanceDocs =
                          attendanceSnapshot.data?.docs ??
                          <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                      final attendanceByActivityId = {
                        for (final doc in attendanceDocs)
                          _attendanceActivityId(doc.data()): doc.data(),
                      };

                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _activityController.activities.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const _MessageCard(
                              title: 'Loading activities',
                              message: 'Please wait a moment.',
                              color: AppColors.studentBlue,
                              background: AppColors.infoSoft,
                            );
                          }

                          final docs =
                              snapshot.data?.docs ??
                              <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                          final activitiesById = {
                            for (final doc in docs) doc.id: doc.data(),
                          };
                          final filtered = docs.where((doc) {
                            final data = doc.data();
                            final title = (data['title'] ?? data['name'] ?? '')
                                .toString();
                            final category = (data['category'] ?? '')
                                .toString();
                            final venue = (data['venue'] ?? '').toString();
                            final activityStatus = (data['status'] ?? 'Draft')
                                .toString();
                            final isRegistered = registrationsByActivityId
                                .containsKey(doc.id);
                            final derivedStatus = isRegistered
                                ? 'Registered'
                                : (_safeLower(activityStatus) == 'active'
                                      ? 'Active'
                                      : 'Closed');
                            final matchesFilter =
                                _statusFilter == 'All' ||
                                derivedStatus == _statusFilter;
                            final matchesQuery =
                                query.isEmpty ||
                                _safeLower(title).contains(query) ||
                                _safeLower(category).contains(query) ||
                                _safeLower(venue).contains(query);
                            return matchesFilter && matchesQuery;
                          }).toList();

                          if (filtered.isEmpty) {
                            return const _MessageCard(
                              title: 'No activity found',
                              message:
                                  'Try another keyword or filter to see available activities.',
                              color: AppColors.warning,
                              background: AppColors.warningSoft,
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Available activities',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...filtered.map((doc) {
                                final data = doc.data();
                                final title =
                                    (data['title'] ?? data['name'] ?? doc.id)
                                        .toString();
                                final category =
                                    (data['category'] ?? 'Co-Curriculum')
                                        .toString();
                                final date = (data['date'] ?? '').toString();
                                final venue = (data['venue'] ?? '').toString();
                                final hours = (data['hours'] ?? 8).toString();
                                final cats =
                                    (data['cats'] ?? data['creditValue'] ?? 2)
                                        .toString();
                                final capacity =
                                    ((data['capacity'] as num?)?.toInt() ?? 0);
                                final availableSlots =
                                    ((data['availableSlots'] as num?)
                                        ?.toInt() ??
                                    0);
                                final isRegistered = registrationsByActivityId
                                    .containsKey(doc.id);
                                final registrationDoc =
                                    registrationsByActivityId[doc.id];
                                final attendanceData =
                                    attendanceByActivityId[doc.id];
                                final activityDate = _parseStoredDate(
                                  data['session_date']?.toString(),
                                  data['date']?.toString(),
                                );
                                final today = DateTime.now();
                                final todayOnly = DateTime(
                                  today.year,
                                  today.month,
                                  today.day,
                                );
                                final hasAttendanceRecord =
                                    attendanceData != null &&
                                    _isAttendancePresent(attendanceData);
                                final canCancel =
                                    isRegistered &&
                                    activityDate != null &&
                                    !hasAttendanceRecord &&
                                    activityDate.isAfter(todayOnly);
                                final statusLabel = isRegistered
                                    ? 'Registered'
                                    : (_safeLower(data['status']) == 'active'
                                          ? 'Open'
                                          : 'Closed');
                                final statusColor = isRegistered
                                    ? (canCancel
                                          ? AppColors.danger
                                          : AppColors.treasuryTeal)
                                    : statusLabel == 'Open'
                                    ? AppColors.studentBlue
                                    : AppColors.warning;
                                final statusBackground = isRegistered
                                    ? (canCancel
                                          ? AppColors.dangerSoft
                                          : AppColors.tealSoft)
                                    : statusLabel == 'Open'
                                    ? AppColors.infoSoft
                                    : AppColors.warningSoft;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _ActivityCard(
                                    title: title,
                                    meta:
                                        '$category  |  $date  |  $venue  |  $hours hours  |  $cats CATS  |  ${capacity - availableSlots}/$capacity seats',
                                    lecturer: availableSlots > 0
                                        ? '$availableSlots slots available'
                                        : 'No slot available',
                                    statusLabel: statusLabel,
                                    statusColor: statusColor,
                                    statusBackground: statusBackground,
                                    note: isRegistered
                                        ? canCancel
                                              ? 'Your registration is stored. You can cancel before the activity date.'
                                              : hasAttendanceRecord
                                              ? 'Your registration is stored. Cancellation is not allowed after attendance has been recorded.'
                                              : 'Your registration is stored. Cancellation is closed because the activity date has passed.'
                                        : 'Register only when the activity is active and slot capacity is still available.',
                                    primaryAction: isRegistered
                                        ? (canCancel
                                              ? 'Cancel Registration'
                                              : 'Registered')
                                        : 'Register Activity',
                                    secondaryAction: 'View Details',
                                    onPrimaryTap: isRegistered
                                        ? (canCancel && registrationDoc != null
                                              ? () => _cancelRegistration(
                                                  context,
                                                  doc,
                                                  registrationDoc,
                                                )
                                              : null)
                                        : () => _registerActivity(context, doc),
                                    onSecondaryTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => _ActivityDetailsPage(
                                            activityId: doc.id,
                                            titleFallback: title,
                                            subtitle: 'Student',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                              const SizedBox(height: 14),
                              const Text(
                                'My registrations',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (registrationDocs.isEmpty)
                                const _MessageCard(
                                  title: 'No registration yet',
                                  message:
                                      'Register for an active activity to start building your co-curriculum record.',
                                  color: AppColors.warning,
                                  background: AppColors.warningSoft,
                                )
                              else
                                ...registrationDocs.map((regDoc) {
                                  final regData = regDoc.data();
                                  final activityId =
                                      (regData['activityId'] ?? '').toString();
                                  final activityData =
                                      activitiesById[activityId] ??
                                      <String, dynamic>{};
                                  final activityTitle =
                                      (activityData['title'] ??
                                              activityData['name'] ??
                                              activityId)
                                          .toString();
                                  final regStatus =
                                      (regData['status'] ?? 'registered')
                                          .toString();
                                  final attendanceStatus =
                                      (regData['attendanceStatus'] ?? 'pending')
                                          .toString();
                                  final detail =
                                      'Registration status: $regStatus. Attendance: $attendanceStatus.';
                                  final normalized = _safeLower(regStatus);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _HistoryCard(
                                      title: activityTitle,
                                      detail: detail,
                                      statusLabel: regStatus.isEmpty
                                          ? 'Registered'
                                          : '${regStatus[0].toUpperCase()}${regStatus.substring(1)}',
                                      statusColor: normalized == 'completed'
                                          ? AppColors.success
                                          : AppColors.treasuryTeal,
                                      statusBackground:
                                          normalized == 'completed'
                                          ? AppColors.successSoft
                                          : AppColors.tealSoft,
                                    ),
                                  );
                                }),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PusatAdabActivityRecord {
  const _PusatAdabActivityRecord({
    required this.documentId,
    required this.title,
    required this.meta,
    required this.lecturer,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBackground,
    required this.note,
    required this.primaryAction,
    required this.secondaryAction,
    required this.tertiaryAction,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
    required this.onTertiaryTap,
  });

  final String documentId;
  final String title;
  final String meta;
  final String lecturer;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackground;
  final String note;
  final String primaryAction;
  final String secondaryAction;
  final String tertiaryAction;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;
  final VoidCallback onTertiaryTap;
}

class _PusatAdabActivitiesTab extends StatefulWidget {
  const _PusatAdabActivitiesTab();

  @override
  State<_PusatAdabActivitiesTab> createState() =>
      _PusatAdabActivitiesTabState();
}

class _PusatAdabActivitiesTabState extends State<_PusatAdabActivitiesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _nextActivityDocumentId() async {
    final snapshot = await _activityController.activities.get();
    var maxNumber = 0;
    for (final doc in snapshot.docs) {
      final match = RegExp(r'^act-(\d+)$').firstMatch(doc.id);
      if (match == null) {
        continue;
      }
      final value = int.tryParse(match.group(1) ?? '') ?? 0;
      if (value > maxNumber) {
        maxNumber = value;
      }
    }
    final next = (maxNumber + 1).toString().padLeft(3, '0');
    return 'act-$next';
  }

  Future<void> _confirmDeleteActivity(
    BuildContext context,
    String documentId,
    String activityTitle,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Delete Activity'),
          content: Text(
            'Are you sure you want to delete $activityTitle? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    try {
      final result = await _activityController.deleteActivity(documentId);
      if (!context.mounted) return;
      if (result['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (result['message'] ?? 'Unable to delete this activity right now.')
                  .toString(),
            ),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$activityTitle deleted successfully.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete this activity right now.'),
        ),
      );
    }
  }

  _PusatAdabActivityRecord _recordFromDoc(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, String> lecturerNamesByUid,
  ) {
    final data = doc.data();
    final title = (data['title'] ?? data['name'] ?? doc.id).toString();
    final category = (data['category'] ?? 'Co-Curriculum').toString();
    final date = (data['date'] ?? '').toString();
    final venue = (data['venue'] ?? '').toString();
    final hours = (data['hours'] ?? 8).toString();
    final cats = (data['cats'] ?? data['creditValue'] ?? 2).toString();
    final lecturerId =
        (data['supervisorLecturerId'] ?? data['lecturerId'] ?? '').toString();
    final lecturer =
        lecturerNamesByUid[lecturerId] ??
        (data['supervisor'] ?? data['lecturer'] ?? 'Lecturer not assigned')
            .toString();
    final rawStatus = (data['status'] ?? 'Draft').toString();
    final normalizedStatus = rawStatus.toLowerCase();
    final isClosed = normalizedStatus == 'closed';
    final statusLabel = isClosed
        ? 'Closed'
        : normalizedStatus == 'active'
        ? 'Active'
        : 'Draft';

    return _PusatAdabActivityRecord(
      documentId: doc.id,
      title: title,
      meta: '$category  |  $date  |  $venue  |  $hours hours  |  $cats CATS',
      lecturer: lecturer,
      statusLabel: statusLabel,
      statusColor: isClosed
          ? AppColors.warning
          : statusLabel == 'Draft'
          ? AppColors.studentBlue
          : AppColors.treasuryTeal,
      statusBackground: isClosed
          ? AppColors.warningSoft
          : statusLabel == 'Draft'
          ? AppColors.infoSoft
          : AppColors.tealSoft,
      note: isClosed
          ? 'Registration has ended. Staff can still review registration records.'
          : statusLabel == 'Draft'
          ? 'This activity is still in draft and can be updated before publication.'
          : 'Registration is open and participant monitoring is active.',
      primaryAction: isClosed ? 'Update Record' : 'Edit Details',
      secondaryAction: isClosed
          ? 'View Registrations'
          : 'Monitor Participation',
      tertiaryAction: 'Delete',
      onPrimaryTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _ActivityFormPage(
              pageTitle: isClosed
                  ? 'Update Activity Record'
                  : 'Edit Activity Details',
              documentId: doc.id,
              initialActivityTitle: title,
              submitLabel: isClosed ? 'Update Record' : 'Save Changes',
              infoMessage:
                  'Update official activity information such as title, venue, session date, hours, CATS, and supervising lecturer.',
            ),
          ),
        );
      },
      onSecondaryTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                _ActivityDetailsPage(activityId: doc.id, titleFallback: title),
          ),
        );
      },
      onTertiaryTap: () => _confirmDeleteActivity(context, doc.id, title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _safeLower(_searchController.text.trim());

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
                'Manage activities',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Create and update activity details.',
                style: TextStyle(
                  fontSize: 11.2,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              _PrimaryActionCard(
                title: 'Create activity',
                message: 'Add a new activity with the required details.',
                actionLabel: 'Create Activity',
                color: AppColors.treasuryTeal,
                background: AppColors.tealSoft,
                icon: Icons.add_circle_outline_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _CreateActivityPage(
                        nextDocumentIdLoader: _nextActivityDocumentId,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              _RectSearchField(
                controller: _searchController,
                hintText: 'Search activity, category, venue, lecturer',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Active', 'Closed']
                    .map(
                      (filter) => _FilterChipButton(
                        label: filter,
                        selected: _statusFilter == filter,
                        onTap: () {
                          setState(() {
                            _statusFilter = filter;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    'Activities',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Updated live',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _activityController.activities.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _MessageCard(
                      title: 'Loading activities',
                      message: 'Please wait a moment.',
                      color: AppColors.studentBlue,
                      background: AppColors.infoSoft,
                    );
                  }

                  final docs =
                      snapshot.data?.docs ??
                      <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                  return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: _activityController.users
                        .where('role', isEqualTo: 'lecturer')
                        .get(),
                    builder: (context, usersSnapshot) {
                      final lecturerDocs =
                          usersSnapshot.data?.docs ??
                          <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                      final lecturerNamesByUid = <String, String>{};
                      for (final doc in lecturerDocs) {
                        final data = doc.data();
                        final uid = (data['uid'] ?? '').toString();
                        if (uid.isEmpty) {
                          continue;
                        }
                        lecturerNamesByUid[uid] = _userDisplayName(
                          data,
                          fallback: 'Lecturer not assigned',
                        );
                      }

                      final records = docs
                          .map(
                            (doc) => _recordFromDoc(
                              context,
                              doc,
                              lecturerNamesByUid,
                            ),
                          )
                          .where((record) {
                            final matchesFilter =
                                _statusFilter == 'All' ||
                                record.statusLabel == _statusFilter;
                            final matchesQuery =
                                query.isEmpty ||
                                _safeLower(record.title).contains(query) ||
                                _safeLower(record.meta).contains(query) ||
                                _safeLower(record.lecturer).contains(query);
                            return matchesFilter && matchesQuery;
                          })
                          .toList();

                      if (records.isEmpty) {
                        return const _MessageCard(
                          title: 'No activity found',
                          message:
                              'Try another keyword or create a new activity to get started.',
                          color: AppColors.warning,
                          background: AppColors.warningSoft,
                        );
                      }

                      return Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${records.length} activities found',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...records.map(
                            (record) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ActivityCard(
                                title: record.title,
                                meta: record.meta,
                                lecturer: record.lecturer,
                                statusLabel: record.statusLabel,
                                statusColor: record.statusColor,
                                statusBackground: record.statusBackground,
                                note: record.note,
                                primaryAction: record.primaryAction,
                                secondaryAction: record.secondaryAction,
                                tertiaryAction: record.tertiaryAction,
                                onPrimaryTap: record.onPrimaryTap,
                                onSecondaryTap: record.onSecondaryTap,
                                onTertiaryTap: record.onTertiaryTap,
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
          title: 'Staff-only access',
          message:
              'Only Pusat Adab can create activities, update activity details, and maintain official activity records in this module.',
          color: AppColors.treasuryTeal,
          background: AppColors.tealSoft,
        ),
      ],
    );
  }
}

class _LecturerActivitiesTab extends StatefulWidget {
  const _LecturerActivitiesTab({required this.lecturerUid});

  final String lecturerUid;

  @override
  State<_LecturerActivitiesTab> createState() => _LecturerActivitiesTabState();
}

class _LecturerActivitiesTabState extends State<_LecturerActivitiesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';
  DateTime? _selectedDateFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateFilter() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateFilter ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDateFilter = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  bool _matchesSelectedDate(String sessionDate, String displayDate) {
    if (_selectedDateFilter == null) {
      return true;
    }
    final parsed = _parseStoredDate(sessionDate, displayDate);
    if (parsed == null) {
      return false;
    }
    return parsed.year == _selectedDateFilter!.year &&
        parsed.month == _selectedDateFilter!.month &&
        parsed.day == _selectedDateFilter!.day;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lecturerUid.trim().isEmpty) {
      return const _MessageCard(
        title: 'Lecturer profile unavailable',
        message:
            'No lecturer identifier was found for this session. Please sign in again.',
        color: AppColors.warning,
        background: AppColors.warningSoft,
      );
    }

    final query = _safeLower(_searchController.text.trim());

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
                'Supervised activities',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'View your activities and open grading.',
                style: TextStyle(
                  fontSize: 11.2,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              _RectSearchField(
                controller: _searchController,
                hintText: 'Search activity, category, venue',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Active', 'Closed', 'Draft']
                    .map(
                      (filter) => _FilterChipButton(
                        label: filter,
                        selected: _statusFilter == filter,
                        onTap: () {
                          setState(() {
                            _statusFilter = filter;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ActionChip(
                      label: _selectedDateFilter == null
                          ? 'Select date'
                          : _displayDate(_selectedDateFilter!),
                      background: AppColors.grayOne,
                      color: AppColors.textDark,
                      icon: Icons.calendar_today_outlined,
                      onTap: _pickDateFilter,
                    ),
                  ),
                  if (_selectedDateFilter != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionChip(
                        label: 'Clear date',
                        background: AppColors.infoSoft,
                        color: AppColors.studentBlue,
                        icon: Icons.close_rounded,
                        onTap: () {
                          setState(() {
                            _selectedDateFilter = null;
                          });
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _activityController.activities
                    .where(
                      'supervisorLecturerId',
                      isEqualTo: widget.lecturerUid,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _MessageCard(
                      title: 'Loading activities',
                      message: 'Please wait a moment.',
                      color: AppColors.studentBlue,
                      background: AppColors.infoSoft,
                    );
                  }

                  final docs =
                      snapshot.data?.docs ??
                      <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                  final activityIds = docs.map((doc) => doc.id).toList();

                  return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: activityIds.isEmpty
                        ? null
                        : _activityController.activityRegistrations
                              .where('activityId', whereIn: activityIds)
                              .get(),
                    builder: (context, registrationSnapshot) {
                      final registrationDocs =
                          registrationSnapshot.data?.docs ??
                          <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                      return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        future: activityIds.isEmpty
                            ? null
                            : _activityController.attendanceRecords
                                  .where('activityId', whereIn: activityIds)
                                  .get(),
                        builder: (context, attendanceSnapshot) {
                          final attendanceDocs =
                              attendanceSnapshot.data?.docs ??
                              <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                          final attendanceReady = <String, bool>{};
                          for (final doc in attendanceDocs) {
                            final data = doc.data();
                            final key =
                                '${_attendanceActivityId(data)}|${data['studentId'] ?? ''}';
                            attendanceReady[key] = _isAttendancePresent(data);
                          }

                          final records = docs.where((doc) {
                            final data = doc.data();
                            final title = (data['title'] ?? data['name'] ?? '')
                                .toString();
                            final category = (data['category'] ?? '')
                                .toString();
                            final venue = (data['venue'] ?? '').toString();
                            final status = (data['status'] ?? 'Draft')
                                .toString();
                            final sessionDate = (data['session_date'] ?? '')
                                .toString();
                            final displayDate = (data['date'] ?? '').toString();
                            final matchesFilter =
                                _statusFilter == 'All' ||
                                status == _statusFilter;
                            final matchesQuery =
                                query.isEmpty ||
                                _safeLower(title).contains(query) ||
                                _safeLower(category).contains(query) ||
                                _safeLower(venue).contains(query);
                            final matchesDate = _matchesSelectedDate(
                              sessionDate,
                              displayDate,
                            );
                            return matchesFilter && matchesQuery && matchesDate;
                          }).toList();

                          if (records.isEmpty) {
                            return const _MessageCard(
                              title: 'No supervised activity found',
                              message:
                                  'No activity matches the current lecturer search and filter.',
                              color: AppColors.warning,
                              background: AppColors.warningSoft,
                            );
                          }

                          return Column(
                            children: records.map((doc) {
                              final data = doc.data();
                              final title =
                                  (data['title'] ?? data['name'] ?? doc.id)
                                      .toString();
                              final category =
                                  (data['category'] ?? 'Co-Curriculum')
                                      .toString();
                              final date = (data['date'] ?? '').toString();
                              final venue = (data['venue'] ?? '').toString();
                              final hours = (data['hours'] ?? 8).toString();
                              final cats =
                                  (data['cats'] ?? data['creditValue'] ?? 2)
                                      .toString();
                              final status = (data['status'] ?? 'Draft')
                                  .toString();
                              final normalizedStatus = _safeLower(status);
                              final regs = registrationDocs
                                  .where(
                                    (regDoc) =>
                                        (regDoc.data()['activityId'] ?? '')
                                            .toString() ==
                                        doc.id,
                                  )
                                  .toList();
                              final attendedCount = regs.where((regDoc) {
                                final regData = regDoc.data();
                                final key =
                                    '${regData['activityId'] ?? ''}|${regData['studentId'] ?? ''}';
                                return attendanceReady[key] == true ||
                                    _safeLower(regData['attendanceStatus']) ==
                                        'present' ||
                                    _safeLower(regData['attendanceStatus']) ==
                                        'validated';
                              }).length;
                              final gradedCount = regs
                                  .where(
                                    (regDoc) =>
                                        ((regDoc.data()['totalMarks'] as num?)
                                                ?.toInt() ??
                                            0) >
                                        0,
                                  )
                                  .length;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ActivityCard(
                                  title: title,
                                  meta:
                                      '$category  |  $date  |  $venue  |  $hours hours  |  $cats CATS',
                                  lecturer:
                                      '$attendedCount attended  |  $gradedCount graded',
                                  statusLabel: status,
                                  statusColor: normalizedStatus == 'closed'
                                      ? AppColors.warning
                                      : normalizedStatus == 'draft'
                                      ? AppColors.studentBlue
                                      : AppColors.treasuryTeal,
                                  statusBackground: normalizedStatus == 'closed'
                                      ? AppColors.warningSoft
                                      : normalizedStatus == 'draft'
                                      ? AppColors.infoSoft
                                      : AppColors.tealSoft,
                                  note:
                                      'Open details or grade students with valid attendance records.',
                                  primaryAction: 'View Details',
                                  secondaryAction: 'Grade Students',
                                  onPrimaryTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => _ActivityDetailsPage(
                                          activityId: doc.id,
                                          titleFallback: title,
                                          subtitle: 'Lecturer',
                                        ),
                                      ),
                                    );
                                  },
                                  onSecondaryTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            _LecturerActivityGradingPage(
                                              activityId: doc.id,
                                              titleFallback: title,
                                              lecturerUid: widget.lecturerUid,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        },
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
          title: 'Attendance',
          message: 'Marks can be entered after attendance is recorded.',
          color: AppColors.warning,
          background: AppColors.warningSoft,
        ),
      ],
    );
  }
}

class _CreateActivityPage extends StatelessWidget {
  const _CreateActivityPage({required this.nextDocumentIdLoader});

  final Future<String> Function() nextDocumentIdLoader;

  @override
  Widget build(BuildContext context) {
    return _ActivityFormPage(
      pageTitle: 'Create Activity',
      nextDocumentIdLoader: nextDocumentIdLoader,
      submitLabel: 'Save Activity',
      infoMessage:
          'Register a new approved co-curriculum activity with session, capacity, hours, CATS, and supervising lecturer details.',
    );
  }
}

class _ActivityFormPage extends StatefulWidget {
  const _ActivityFormPage({
    required this.pageTitle,
    required this.submitLabel,
    required this.infoMessage,
    this.documentId,
    this.nextDocumentIdLoader,
    this.initialActivityTitle,
  });

  final String pageTitle;
  final String submitLabel;
  final String infoMessage;
  final String? documentId;
  final Future<String> Function()? nextDocumentIdLoader;
  final String? initialActivityTitle;

  @override
  State<_ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<_ActivityFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _venueController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();

  _ActivityOption? _selectedActivity;
  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  String? _status;
  String? _selectedLecturer;
  bool _saving = false;
  bool _loadingExisting = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2026, 5, 10);
    if (widget.initialActivityTitle != null) {
      _selectedActivity = _activityOptions.firstWhere(
        (activity) => activity.title == widget.initialActivityTitle,
        orElse: () => _activityOptions.first,
      );
      _status = 'Active';
      _applyActivityDefaults(_selectedActivity!);
    }
    if (widget.documentId != null) {
      _loadExistingActivity();
    }
  }

  @override
  void dispose() {
    _venueController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _applyActivityDefaults(_ActivityOption activity) {
    _capacityController.text = activity.defaultCapacity.toString();
    _venueController.text = activity.defaultVenue;
    _descriptionController.text = activity.description;
  }

  Future<void> _loadExistingActivity() async {
    final documentId = widget.documentId;
    if (documentId == null) {
      return;
    }

    setState(() {
      _loadingExisting = true;
    });

    try {
      final doc = await _activityController.getActivityById(documentId);
      if (!mounted || doc == null) {
        return;
      }

      final data = doc.data() ?? <String, dynamic>{};
      final activityTitle = (data['title'] ?? data['name'] ?? '').toString();
      final matchedActivity = _activityOptions
          .cast<_ActivityOption?>()
          .firstWhere(
            (activity) => activity?.title == activityTitle,
            orElse: () => _selectedActivity,
          );
      final parsedDate = _parseStoredDate(
        data['session_date']?.toString(),
        data['date']?.toString(),
      );
      final parsedStartTime = _parseStoredTime(data['startTime']?.toString());
      final parsedEndTime = _parseStoredTime(data['endTime']?.toString());
      final rawStatus = (data['status'] ?? _status ?? 'Active').toString();
      final normalizedStatus = _safeLower(rawStatus);
      final resolvedStatus = normalizedStatus == 'open'
          ? 'Active'
          : normalizedStatus == 'closed'
          ? 'Closed'
          : normalizedStatus == 'draft'
          ? 'Draft'
          : 'Active';

      String? resolvedLecturer =
          (data['supervisorLecturerName'] ??
                  data['supervisor'] ??
                  data['lecturer'])
              ?.toString();
      if ((resolvedLecturer == null || resolvedLecturer.isEmpty) &&
          (data['supervisorLecturerId'] ?? '').toString().isNotEmpty) {
        final lecturerSnapshot = await _activityController.users
            .where(
              'uid',
              isEqualTo: (data['supervisorLecturerId'] ?? '').toString(),
            )
            .limit(1)
            .get();
        if (lecturerSnapshot.docs.isNotEmpty) {
          resolvedLecturer = _userDisplayName(
            lecturerSnapshot.docs.first.data(),
          );
        }
      }

      setState(() {
        if (matchedActivity != null) {
          _selectedActivity = matchedActivity;
        }
        _status = resolvedStatus;
        _selectedLecturer = resolvedLecturer;
        _venueController.text = (data['venue'] ?? '').toString();
        _capacityController.text =
            (data['capacity'] ?? data['maxParticipants'] ?? '').toString();
        _descriptionController.text = (data['description'] ?? '').toString();
        if (parsedDate != null) {
          _selectedDate = parsedDate;
        }
        if (parsedStartTime != null) {
          _startTime = parsedStartTime;
        }
        if (parsedEndTime != null) {
          _endTime = parsedEndTime;
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load the current activity details.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingExisting = false;
        });
      }
    }
  }

  int get _calculatedHours {
    final startMinutes = (_startTime.hour * 60) + _startTime.minute;
    final endMinutes = (_endTime.hour * 60) + _endTime.minute;
    var diffMinutes = endMinutes - startMinutes;
    if (diffMinutes <= 0) {
      diffMinutes += 24 * 60;
    }
    if (diffMinutes >= 300) {
      diffMinutes -= 60;
    }
    return (diffMinutes / 60).round();
  }

  int get _fixedCats => 2;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveActivity() async {
    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final selectedActivity = _selectedActivity;
      final selectedStatus = _status;
      final selectedLecturer = _selectedLecturer;
      if (selectedActivity == null ||
          selectedStatus == null ||
          selectedLecturer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete all required fields before saving.'),
          ),
        );
        return;
      }

      final activityId =
          widget.documentId ??
          (widget.nextDocumentIdLoader != null
              ? await widget.nextDocumentIdLoader!()
              : selectedActivity.title
                    .toLowerCase()
                    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
                    .replaceAll(RegExp(r'^-|-$'), ''));
      final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
      final cats = _fixedCats;
      final hours = _calculatedHours;
      final supervisorName = selectedLecturer;
      final isCreatingActivity = widget.documentId == null;

      final activityData = {
        'id': activityId,
        'title': selectedActivity.title,
        'name': selectedActivity.title,
        'category': selectedActivity.category,
        'description': _descriptionController.text.trim(),
        'date': _displayDate(_selectedDate),
        'session_date':
            '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        'startTime': _formatTime(_startTime),
        'endTime': _formatTime(_endTime),
        'venue': _venueController.text.trim(),
        'hours': hours,
        'cats': cats,
        'creditValue': cats,
        'capacity': capacity,
        if (isCreatingActivity) 'availableSlots': capacity,
        'supervisorLecturerName': supervisorName,
        'status': selectedStatus,
        'requiresAttendance': true,
        if (isCreatingActivity) 'participantsCount': 0,
        'maxParticipants': capacity,
        'eligibilityRule': 'all_active_students',
        'isCompleted': false,
        'createdBy': 'pad-001',
        'sourceModule': 'manage_co_curriculum',
        'managedBy': 'pusat_adab',
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };
      final result = widget.documentId == null
          ? await _activityController.saveActivity(activityData)
          : await _activityController.updateActivity(activityId, activityData);
      if (!mounted) return;
      if (result['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (result['message'] ?? 'Unable to save activity right now.')
                  .toString(),
            ),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.submitLabel} completed for ${selectedActivity.title}.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save activity right now. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: widget.pageTitle,
      subtitle: 'Pusat Adab',
      child: _loadingExisting
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Activity details'),
                  const SizedBox(height: 10),
                  _DropdownFieldCard<_ActivityOption>(
                    label: 'Activity',
                    value: _selectedActivity,
                    hintText: 'Choose activity',
                    validator: (value) =>
                        value == null ? 'Choose activity' : null,
                    items: _activityOptions
                        .map(
                          (activity) => DropdownMenuItem<_ActivityOption>(
                            value: activity,
                            child: Text(activity.title),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedActivity = value;
                        _selectedLecturer = null;
                        if (value != null) {
                          _applyActivityDefaults(value);
                        } else {
                          _venueController.clear();
                          _capacityController.clear();
                          _descriptionController.clear();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _FormFieldCard(
                    label: 'Category',
                    value:
                        _selectedActivity?.category ?? 'Choose activity first',
                  ),
                  const SizedBox(height: 10),
                  _DateTimeCard(
                    dateLabel: _displayDate(_selectedDate),
                    startLabel: _formatTime(_startTime),
                    endLabel: _formatTime(_endTime),
                    onDateTap: _pickDate,
                    onStartTap: () => _pickTime(isStart: true),
                    onEndTap: () => _pickTime(isStart: false),
                  ),
                  const SizedBox(height: 10),
                  _TextInputCard(
                    label: 'Venue',
                    controller: _venueController,
                    hintText: 'Enter venue',
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _FormFieldCard(
                          label: 'Hours',
                          value: '$_calculatedHours hours',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FormFieldCard(
                          label: 'CATS',
                          value: '$_fixedCats CATS',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _TextInputCard(
                          label: 'Capacity',
                          controller: _capacityController,
                          hintText: '30',
                          keyboardType: TextInputType.number,
                          validator: _numberField,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DropdownFieldCard<String>(
                          label: 'Status',
                          hintText: 'Choose status',
                          value: _status,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Choose status'
                              : null,
                          items: const [
                            DropdownMenuItem(
                              value: 'Active',
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: 'Closed',
                              child: Text('Closed'),
                            ),
                            DropdownMenuItem(
                              value: 'Draft',
                              child: Text('Draft'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _status = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _LecturerDropdownCard(
                    selectedLecturer: _selectedLecturer,
                    onChanged: (value) {
                      setState(() {
                        _selectedLecturer = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _TextInputCard(
                    label: 'Description',
                    controller: _descriptionController,
                    hintText: 'Describe the activity',
                    validator: _requiredField,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 14),
                  const _MessageCard(
                    title: 'Activity setup',
                    message: 'Fill in the details below to add a new activity.',
                    color: AppColors.treasuryTeal,
                    background: AppColors.tealSoft,
                  ),
                  const SizedBox(height: 10),
                  const _MessageCard(
                    title: 'Hours and CATS',
                    message:
                        'Hours are calculated from the session time. CATS stay fixed for each activity.',
                    color: AppColors.studentBlue,
                    background: AppColors.infoSoft,
                  ),
                  const SizedBox(height: 16),
                  _SubmitBar(
                    primaryLabel: _saving ? 'Saving...' : widget.submitLabel,
                    secondaryLabel: 'Cancel',
                    primaryColor: AppColors.treasuryTeal,
                    onPrimaryTap: _saving ? () {} : _saveActivity,
                    onSecondaryTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DropdownFieldCard<T> extends StatelessWidget {
  const _DropdownFieldCard({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.validator,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final String? Function(T?)? validator;

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
          const SizedBox(height: 6),
          DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            hint: hintText == null ? null : Text(hintText!),
            decoration: InputDecoration(
              isDense: true,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _TextInputCard extends StatelessWidget {
  const _TextInputCard({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final int maxLines;

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
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              isDense: true,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTimeCard extends StatelessWidget {
  const _DateTimeCard({
    required this.dateLabel,
    required this.startLabel,
    required this.endLabel,
    required this.onDateTap,
    required this.onStartTap,
    required this.onEndTap,
  });

  final String dateLabel;
  final String startLabel;
  final String endLabel;
  final VoidCallback onDateTap;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;

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
          const Text(
            'Date and time',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          _ActionChip(
            label: 'Date: $dateLabel',
            background: AppColors.grayOne,
            color: AppColors.textDark,
            onTap: onDateTap,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ActionChip(
                  label: 'Start: $startLabel',
                  background: AppColors.infoSoft,
                  color: AppColors.studentBlue,
                  onTap: onStartTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionChip(
                  label: 'End: $endLabel',
                  background: AppColors.tealSoft,
                  color: AppColors.treasuryTeal,
                  onTap: onEndTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RectSearchField extends StatelessWidget {
  const _RectSearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textMuted,
          size: 20,
        ),
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
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.infoSoft : AppColors.grayOne,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.studentBlue : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.studentBlue : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactMetaChip extends StatelessWidget {
  const _CompactMetaChip({required this.icon, required this.label});

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
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10.1, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}

class _LecturerDropdownCard extends StatelessWidget {
  const _LecturerDropdownCard({
    required this.selectedLecturer,
    required this.onChanged,
  });

  final String? selectedLecturer;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _activityController.users
          .where('role', isEqualTo: 'lecturer')
          .snapshots(),
      builder: (context, snapshot) {
        final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
            snapshot.data?.docs ??
            <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        final lecturers =
            docs
                .map(
                  (doc) =>
                      (doc.data()['fullName'] ??
                              doc.data()['name'] ??
                              doc.data()['email'] ??
                              '')
                          .toString(),
                )
                .where((name) => name.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

        final currentValue = lecturers.contains(selectedLecturer)
            ? selectedLecturer
            : null;

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
              const Text(
                'Supervising lecturer',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Text(
                  'Loading lecturer list...',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                )
              else if (lecturers.isEmpty)
                const Text(
                  'No lecturer found. Seed lecturer users first.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: currentValue,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Choose lecturer' : null,
                  hint: const Text('Choose lecturer'),
                  items: lecturers
                      .map(
                        (lecturer) => DropdownMenuItem<String>(
                          value: lecturer,
                          child: Text(lecturer),
                        ),
                      )
                      .toList(),
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    isDense: true,
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
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityDetailsPage extends StatelessWidget {
  const _ActivityDetailsPage({
    required this.activityId,
    required this.titleFallback,
    this.subtitle = 'Pusat Adab',
  });

  final String activityId;
  final String titleFallback;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: 'Activity Details',
      subtitle: subtitle,
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _activityController.activities.doc(activityId).snapshots(),
        builder: (context, activitySnapshot) {
          if (activitySnapshot.connectionState == ConnectionState.waiting) {
            return const _MessageCard(
              title: 'Loading activity',
              message: 'Please wait a moment.',
              color: AppColors.studentBlue,
              background: AppColors.infoSoft,
            );
          }

          final data = activitySnapshot.data?.data();
          if (data == null) {
            return _MessageCard(
              title: titleFallback,
              message: 'This activity is no longer available.',
              color: AppColors.warning,
              background: AppColors.warningSoft,
            );
          }

          final title = (data['title'] ?? data['name'] ?? titleFallback)
              .toString();
          final category = (data['category'] ?? 'Co-Curriculum').toString();
          final date = (data['date'] ?? '').toString();
          final startTime = (data['startTime'] ?? '').toString();
          final endTime = (data['endTime'] ?? '').toString();
          final venue = (data['venue'] ?? '').toString();
          final hours = (data['hours'] ?? '').toString();
          final cats = (data['cats'] ?? data['creditValue'] ?? '').toString();
          final lecturerId =
              (data['supervisorLecturerId'] ?? data['lecturerId'] ?? '')
                  .toString();
          final fallbackLecturer =
              (data['supervisor'] ??
                      data['supervisorLecturerName'] ??
                      'Lecturer not assigned')
                  .toString();
          final status = (data['status'] ?? 'Draft').toString();
          final description = (data['description'] ?? '').toString();

          return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: lecturerId.isEmpty
                ? null
                : _activityController.users
                      .where('uid', isEqualTo: lecturerId)
                      .limit(1)
                      .get(),
            builder: (context, lecturerSnapshot) {
              final lecturer = lecturerSnapshot.data?.docs.isNotEmpty == true
                  ? _userDisplayName(
                      lecturerSnapshot.data!.docs.first.data(),
                      fallback: fallbackLecturer,
                    )
                  : fallbackLecturer;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            _StatusBadge(
                              label: status,
                              color: AppColors.studentBlue,
                              background: AppColors.infoSoft,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ActivityMetaWrap(
                          meta:
                              '$category  |  $date  |  $venue  |  $hours hours  |  $cats CATS',
                        ),
                        const SizedBox(height: 10),
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
                                lecturer,
                                style: const TextStyle(
                                  fontSize: 10.8,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (startTime.isNotEmpty || endTime.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_outlined,
                                size: 15,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$startTime - $endTime',
                                style: const TextStyle(
                                  fontSize: 10.8,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MessageCard(
                    title: 'Activity description',
                    message: description.isEmpty
                        ? 'No description is available for this activity yet.'
                        : description,
                    color: AppColors.treasuryTeal,
                    background: AppColors.tealSoft,
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _activityController.activityRegistrations
                        .where('activityId', isEqualTo: activityId)
                        .snapshots(),
                    builder: (context, registrationSnapshot) {
                      if (registrationSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const _MessageCard(
                          title: 'Loading registrations',
                          message:
                              'Fetching participant and registration records for this activity.',
                          color: AppColors.studentBlue,
                          background: AppColors.infoSoft,
                        );
                      }

                      final registrationDocs =
                          registrationSnapshot.data?.docs ??
                          <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                      return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        future: _activityController.users.get(),
                        builder: (context, usersSnapshot) {
                          final userDocs =
                              usersSnapshot.data?.docs ??
                              <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                          final usersByUid = <String, Map<String, dynamic>>{};
                          final usersByDocId = <String, Map<String, dynamic>>{};
                          for (final doc in userDocs) {
                            final userData = doc.data();
                            usersByDocId[doc.id] = userData;
                            final uid = (userData['uid'] ?? '').toString();
                            if (uid.isNotEmpty) {
                              usersByUid[uid] = userData;
                            }
                          }

                          final registrations = registrationDocs.map((doc) {
                            final regData = doc.data();
                            final studentId = (regData['studentId'] ?? '')
                                .toString();
                            final studentData =
                                usersByUid[studentId] ??
                                usersByDocId[studentId] ??
                                <String, dynamic>{};
                            final studentName =
                                (studentData['fullName'] ??
                                        studentData['name'] ??
                                        studentData['email'] ??
                                        studentId)
                                    .toString();
                            final registrationStatus =
                                (regData['status'] ?? 'registered').toString();
                            final matricId = (studentData['matricId'] ?? '')
                                .toString();
                            final attendanceStatus =
                                (regData['attendanceStatus'] ?? 'present')
                                    .toString();
                            final totalMarks =
                                ((regData['totalMarks'] as num?)?.toInt() ?? 0);
                            final markStatus =
                                (regData['markStatus'] ?? 'pending').toString();
                            final evaluatedByLecturerId =
                                (regData['evaluatedByLecturerId'] ?? '')
                                    .toString();
                            final evaluatedBy = _userDisplayName(
                              usersByUid[evaluatedByLecturerId] ??
                                  usersByDocId[evaluatedByLecturerId],
                            );
                            return {
                              'studentName': studentName,
                              'matricId': matricId,
                              'status': registrationStatus,
                              'attendanceStatus': attendanceStatus,
                              'totalMarks': totalMarks,
                              'markStatus': markStatus,
                              'evaluatedBy': evaluatedBy,
                            };
                          }).toList();

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
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Participants and registrations',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${registrations.length} records',
                                      style: const TextStyle(
                                        fontSize: 10.8,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (registrations.isEmpty)
                                  const _MessageCard(
                                    title: 'No registration yet',
                                    message:
                                        'No student registration has been recorded for this activity.',
                                    color: AppColors.warning,
                                    background: AppColors.warningSoft,
                                    compact: true,
                                  )
                                else
                                  ...registrations.map((registration) {
                                    final statusText =
                                        (registration['status'] ?? '')
                                            .toString();
                                    final normalizedStatus = _safeLower(
                                      statusText,
                                    );
                                    final badgeColor =
                                        normalizedStatus == 'completed'
                                        ? AppColors.success
                                        : normalizedStatus == 'registered'
                                        ? AppColors.studentBlue
                                        : normalizedStatus == 'not_eligible'
                                        ? AppColors.danger
                                        : AppColors.warning;
                                    final badgeBackground =
                                        normalizedStatus == 'completed'
                                        ? AppColors.successSoft
                                        : normalizedStatus == 'registered'
                                        ? AppColors.infoSoft
                                        : normalizedStatus == 'not_eligible'
                                        ? AppColors.dangerSoft
                                        : AppColors.warningSoft;
                                    final statusLabel = statusText.isEmpty
                                        ? 'Registered'
                                        : '${statusText[0].toUpperCase()}${statusText.substring(1)}';
                                    final attendanceText =
                                        (registration['attendanceStatus'] ?? '')
                                            .toString();
                                    final totalMarks =
                                        (registration['totalMarks'] ?? 0)
                                            .toString();
                                    final markStatus =
                                        (registration['markStatus'] ?? '')
                                            .toString();
                                    final evaluatedBy =
                                        (registration['evaluatedBy'] ?? '')
                                            .toString();

                                    final subtitle =
                                        (registration['matricId'] ?? '')
                                            .toString()
                                            .isEmpty
                                        ? 'Registration record is available for this activity.'
                                        : 'Matric ID: ${registration['matricId']}';

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: AppColors.grayOne,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    (registration['studentName'] ??
                                                            '')
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors.textDark,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    subtitle,
                                                    style: const TextStyle(
                                                      fontSize: 10.5,
                                                      color:
                                                          AppColors.textMuted,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 7,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: AppColors
                                                              .infoSoft,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          border: Border.all(
                                                            color: AppColors
                                                                .border,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Attendance: ${attendanceText.isEmpty ? 'Present' : attendanceText}',
                                                          style: const TextStyle(
                                                            fontSize: 10.1,
                                                            color: AppColors
                                                                .studentBlue,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 7,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              AppColors.grayOne,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          border: Border.all(
                                                            color: AppColors
                                                                .border,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Marks: $totalMarks%',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 10.1,
                                                                color: AppColors
                                                                    .textDark,
                                                              ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 7,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              _safeLower(
                                                                    markStatus,
                                                                  ) ==
                                                                  'passed'
                                                              ? AppColors
                                                                    .successSoft
                                                              : AppColors
                                                                    .warningSoft,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          border: Border.all(
                                                            color: AppColors
                                                                .border,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Mark status: ${markStatus.isEmpty ? 'Pending' : markStatus}',
                                                          style: TextStyle(
                                                            fontSize: 10.1,
                                                            color:
                                                                _safeLower(
                                                                      markStatus,
                                                                    ) ==
                                                                    'passed'
                                                                ? AppColors
                                                                      .success
                                                                : AppColors
                                                                      .warning,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (evaluatedBy
                                                      .isNotEmpty) ...[
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Reviewed by $evaluatedBy',
                                                      style: const TextStyle(
                                                        fontSize: 10.2,
                                                        color:
                                                            AppColors.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            _StatusBadge(
                                              label: statusLabel,
                                              color: badgeColor,
                                              background: badgeBackground,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
