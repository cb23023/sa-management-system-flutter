part of 'co_curriculum_module_page.dart';

class _GradingPage extends StatelessWidget {
  const _GradingPage({required this.lecturerUid});

  final String lecturerUid;

  @override
  Widget build(BuildContext context) {
    return _LecturerGradingTab(lecturerUid: lecturerUid);
  }
}

class _LecturerGradingTab extends StatefulWidget {
  const _LecturerGradingTab({required this.lecturerUid});

  final String lecturerUid;

  @override
  State<_LecturerGradingTab> createState() => _LecturerGradingTabState();
}

class _LecturerGradingTabState extends State<_LecturerGradingTab> {
  final TextEditingController _searchController = TextEditingController();
  String _gradingFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                'Grading',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter marks for students in this activity.',
                style: TextStyle(
                  fontSize: 11.2,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              _RectSearchField(
                controller: _searchController,
                hintText: 'Search activity',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Ready', 'Graded']
                    .map(
                      (filter) => _FilterChipButton(
                        label: filter,
                        selected: _gradingFilter == filter,
                        onTap: () {
                          setState(() {
                            _gradingFilter = filter;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _gradingController.activities
                    .where(
                      'supervisorLecturerId',
                      isEqualTo: widget.lecturerUid,
                    )
                    .snapshots(),
                builder: (context, activitySnapshot) {
                  if (activitySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const _MessageCard(
                      title: 'Loading grading records',
                      message: 'Please wait a moment.',
                      color: AppColors.studentBlue,
                      background: AppColors.infoSoft,
                    );
                  }

                  final activityDocs =
                      activitySnapshot.data?.docs ??
                      <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                  final activityIds = activityDocs
                      .map((doc) => doc.id)
                      .toList();

                  return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: activityIds.isEmpty
                        ? null
                        : _gradingController.activityRegistrations
                              .where('activityId', whereIn: activityIds)
                              .get(),
                    builder: (context, registrationSnapshot) {
                      final registrationDocs =
                          registrationSnapshot.data?.docs ??
                          <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                      return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        future: activityIds.isEmpty
                            ? null
                            : _gradingController.attendanceRecords
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

                          final List<Map<String, dynamic>> cards = activityDocs
                              .map<Map<String, dynamic>>((activityDoc) {
                                final data = activityDoc.data();
                                final title =
                                    (data['title'] ??
                                            data['name'] ??
                                            activityDoc.id)
                                        .toString();
                                final regs = registrationDocs
                                    .where(
                                      (doc) =>
                                          (doc.data()['activityId'] ?? '')
                                              .toString() ==
                                          activityDoc.id,
                                    )
                                    .toList();
                                final readyCount = regs.where((doc) {
                                  final regData = doc.data();
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
                                      (doc) =>
                                          ((doc.data()['totalMarks'] as num?)
                                                  ?.toInt() ??
                                              0) >
                                          0,
                                    )
                                    .length;
                                return <String, dynamic>{
                                  'doc': activityDoc,
                                  'title': title,
                                  'readyCount': readyCount,
                                  'gradedCount': gradedCount,
                                };
                              })
                              .where((item) {
                                final title = _safeLower(item['title']);
                                final readyCount =
                                    (item['readyCount'] as int?) ?? 0;
                                final gradedCount =
                                    (item['gradedCount'] as int?) ?? 0;
                                final matchesQuery =
                                    query.isEmpty || title.contains(query);
                                final matchesFilter =
                                    _gradingFilter == 'All' ||
                                    (_gradingFilter == 'Ready' &&
                                        readyCount > gradedCount) ||
                                    (_gradingFilter == 'Graded' &&
                                        gradedCount >= readyCount &&
                                        readyCount > 0);
                                return matchesQuery && matchesFilter;
                              })
                              .toList();

                          if (cards.isEmpty) {
                            return const _MessageCard(
                              title: 'No grading record found',
                              message:
                                  'No supervised activity matches the current grading filter.',
                              color: AppColors.warning,
                              background: AppColors.warningSoft,
                            );
                          }

                          return Column(
                            children: cards.map((item) {
                              final activityDoc =
                                  item['doc']
                                      as QueryDocumentSnapshot<
                                        Map<String, dynamic>
                                      >;
                              final data = activityDoc.data();
                              final title = item['title'].toString();
                              final readyCount =
                                  (item['readyCount'] as int?) ?? 0;
                              final gradedCount =
                                  (item['gradedCount'] as int?) ?? 0;
                              final date = (data['date'] ?? '').toString();
                              final venue = (data['venue'] ?? '').toString();

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _PrimaryActionCard(
                                  title: title,
                                  message:
                                      '$date  |  $venue  |  $readyCount attended  |  $gradedCount graded',
                                  actionLabel: 'Grade Students',
                                  color: AppColors.studentBlue,
                                  background: AppColors.infoSoft,
                                  icon: Icons.grading_outlined,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            _LecturerActivityGradingPage(
                                              activityId: activityDoc.id,
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
      ],
    );
  }
}

class _LecturerActivityGradingPage extends StatelessWidget {
  const _LecturerActivityGradingPage({
    required this.activityId,
    required this.titleFallback,
    required this.lecturerUid,
  });

  final String activityId;
  final String titleFallback;
  final String lecturerUid;

  Future<void> _openGradeDialog(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> registrationDoc,
    String studentName,
    int currentMark,
  ) async {
    final controller = TextEditingController(
      text: currentMark > 0 ? '$currentMark' : '',
    );
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Grade $studentName'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Total mark',
              hintText: '0 - 100',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                if (parsed == null || parsed < 0 || parsed > 100) {
                  return;
                }
                Navigator.of(context).pop(parsed);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    final studentId = (registrationDoc.data()['studentId'] ?? '').toString();
    final attendanceResult = await _gradingController.validateAttendance(
      activityId,
      studentId,
    );
    if (attendanceResult['success'] != true) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (attendanceResult['message'] ??
                    'Marks cannot be saved because attendance has not been recorded as present.')
                .toString(),
          ),
        ),
      );
      return;
    }

    final updateResult = await _gradingController.updateStudentMark(
      registrationDoc.id,
      result,
      lecturerUid,
    );
    if (updateResult['success'] != true) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (updateResult['message'] ?? 'Unable to update marks right now.')
                .toString(),
          ),
        ),
      );
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marks updated for $studentName.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: 'Activity Grading',
      subtitle: 'Lecturer',
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _gradingController.activities.doc(activityId).snapshots(),
        builder: (context, activitySnapshot) {
          if (activitySnapshot.connectionState == ConnectionState.waiting) {
            return const _MessageCard(
              title: 'Loading grading page',
              message: 'Preparing the supervised activity and student records.',
              color: AppColors.studentBlue,
              background: AppColors.infoSoft,
            );
          }

          final activityData = activitySnapshot.data?.data();
          if (activityData == null) {
            return _MessageCard(
              title: titleFallback,
              message: 'This activity record is no longer available.',
              color: AppColors.warning,
              background: AppColors.warningSoft,
            );
          }

          final title =
              (activityData['title'] ?? activityData['name'] ?? titleFallback)
                  .toString();
          final category = (activityData['category'] ?? 'Co-Curriculum')
              .toString();
          final date = (activityData['date'] ?? '').toString();
          final startTime = (activityData['startTime'] ?? '').toString();
          final endTime = (activityData['endTime'] ?? '').toString();
          final venue = (activityData['venue'] ?? '').toString();
          final hours = (activityData['hours'] ?? '').toString();
          final cats =
              (activityData['cats'] ?? activityData['creditValue'] ?? '')
                  .toString();
          final status = (activityData['status'] ?? 'Draft').toString();
          final description = (activityData['description'] ?? '').toString();

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
              const _MessageCard(
                title: 'Marks',
                message:
                    'Only students with recorded attendance can be graded here.',
                color: AppColors.studentBlue,
                background: AppColors.infoSoft,
                compact: true,
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _gradingController.activityRegistrations
                    .where('activityId', isEqualTo: activityId)
                    .snapshots(),
                builder: (context, registrationSnapshot) {
                  if (registrationSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const _MessageCard(
                      title: 'Loading registrations',
                      message: 'Please wait a moment.',
                      color: AppColors.studentBlue,
                      background: AppColors.infoSoft,
                    );
                  }

                  final registrationDocs =
                      registrationSnapshot.data?.docs ??
                      <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                  return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: _gradingController.users.get(),
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

                      return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        future: _gradingController.attendanceRecords
                            .where('activityId', isEqualTo: activityId)
                            .get(),
                        builder: (context, attendanceSnapshot) {
                          final attendanceDocs =
                              attendanceSnapshot.data?.docs ??
                              <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                          final attendanceReady = <String, bool>{};
                          for (final doc in attendanceDocs) {
                            final data = doc.data();
                            final studentId = (data['studentId'] ?? '')
                                .toString();
                            attendanceReady[studentId] = _isAttendancePresent(
                              data,
                            );
                          }

                          final cards = registrationDocs.map((doc) {
                            final regData = doc.data();
                            final studentId = (regData['studentId'] ?? '')
                                .toString();
                            final studentData =
                                usersByUid[studentId] ??
                                usersByDocId[studentId] ??
                                <String, dynamic>{};
                            final studentName = _userDisplayName(
                              studentData,
                              fallback: studentId,
                            );
                            final matricId = (studentData['matricId'] ?? '')
                                .toString();
                            final attendanceStatus = _safeLower(
                              regData['attendanceStatus'],
                            );
                            final canGrade =
                                attendanceReady[studentId] == true ||
                                attendanceStatus == 'present' ||
                                attendanceStatus == 'validated';
                            final mark =
                                ((regData['totalMarks'] as num?)?.toInt() ?? 0);
                            final markStatus =
                                (regData['markStatus'] ?? 'pending').toString();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                studentName,
                                                style: const TextStyle(
                                                  fontSize: 13,
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
                                          label: canGrade
                                              ? 'Attendance ready'
                                              : 'Attendance required',
                                          color: canGrade
                                              ? AppColors.success
                                              : AppColors.warning,
                                          background: canGrade
                                              ? AppColors.successSoft
                                              : AppColors.warningSoft,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _CompactMetaChip(
                                          icon: Icons.fact_check_outlined,
                                          label: canGrade
                                              ? 'Present'
                                              : 'No valid attendance',
                                        ),
                                        _CompactMetaChip(
                                          icon: Icons.score_outlined,
                                          label: mark > 0
                                              ? '$mark%'
                                              : 'Not graded',
                                        ),
                                        _CompactMetaChip(
                                          icon: Icons.rule_outlined,
                                          label: markStatus.isEmpty
                                              ? 'Pending'
                                              : markStatus,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ActionChip(
                                            label: canGrade
                                                ? 'Assign Mark'
                                                : 'Attendance Required',
                                            background: canGrade
                                                ? AppColors.studentBlue
                                                : AppColors.grayOne,
                                            color: canGrade
                                                ? Colors.white
                                                : AppColors.textMuted,
                                            onTap: canGrade
                                                ? () => _openGradeDialog(
                                                    context,
                                                    doc,
                                                    studentName,
                                                    mark,
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList();

                          if (cards.isEmpty) {
                            return const _MessageCard(
                              title: 'No student record found',
                              message:
                                  'No registration is available yet for this supervised activity.',
                              color: AppColors.warning,
                              background: AppColors.warningSoft,
                            );
                          }

                          return Column(children: cards);
                        },
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
