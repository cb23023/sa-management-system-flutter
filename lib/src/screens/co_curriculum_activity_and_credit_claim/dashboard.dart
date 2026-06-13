part of 'co_curriculum_module_page.dart';

class _Dashboard extends StatelessWidget {
  const _Dashboard({
    required this.role,
    required this.userName,
    required this.userUid,
  });

  final CoCurriculumRole role;
  final String userName;
  final String userUid;

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case CoCurriculumRole.student:
        return _StudentDashboard(userName: userName, studentUid: userUid);
      case CoCurriculumRole.pusatAdab:
        return _PusatAdabDashboard(userName: userName);
      case CoCurriculumRole.lecturer:
        return _LecturerDashboard(userName: userName, lecturerUid: userUid);
    }
  }
}

class _StudentDashboard extends StatelessWidget {
  const _StudentDashboard({required this.userName, required this.studentUid});

  final String userName;
  final String studentUid;

  @override
  Widget build(BuildContext context) {
    if (studentUid.trim().isEmpty) {
      return const _MessageCard(
        title: 'Student profile unavailable',
        message: 'No student identifier was found for this session.',
        color: AppColors.warning,
        background: AppColors.warningSoft,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _activityController.activityRegistrations
          .where('studentId', isEqualTo: studentUid)
          .snapshots(),
      builder: (context, registrationSnapshot) {
        final registrationDocs =
            registrationSnapshot.data?.docs ??
            <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        final registeredCount = registrationDocs.length;
        final completedRegs = registrationDocs
            .where((doc) => _safeLower(doc.data()['status']) == 'completed')
            .toList();

        return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: _activityController.attendanceRecords
              .where('studentId', isEqualTo: studentUid)
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
                .where((id) => id.isNotEmpty)
                .toSet();

            final completedCount = completedRegs
                .where(
                  (doc) => attendanceReadyIds.contains(
                    (doc.data()['activityId'] ?? '').toString(),
                  ),
                )
                .length;
            final totalHours = completedCount * 8;
            final totalCats = completedCount * 2;

            return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: _claimController.creditClaims
                  .where('studentId', isEqualTo: studentUid)
                  .get(),
              builder: (context, claimSnapshot) {
                final claimDocs =
                    claimSnapshot.data?.docs ??
                    <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                final latestClaim = claimDocs.isEmpty
                    ? null
                    : (claimDocs.toList()..sort((a, b) {
                            final aDate =
                                _parseDynamicDate(
                                  a.data()['submittedAt'],
                                )?.millisecondsSinceEpoch ??
                                0;
                            final bDate =
                                _parseDynamicDate(
                                  b.data()['submittedAt'],
                                )?.millisecondsSinceEpoch ??
                                0;
                            return bDate.compareTo(aDate);
                          }))
                          .first;
                final latestStatus = latestClaim == null
                    ? 'No claim yet'
                    : (latestClaim.data()['claimStatus'] ?? 'pending')
                          .toString();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardProfileCard(
                      name: userName,
                      roleLabel: 'Student',
                      icon: Icons.person_outline_rounded,
                      color: AppColors.studentBlue,
                      background: AppColors.infoSoft,
                      subtitle: 'See your progress and latest claim status.',
                    ),
                    const SizedBox(height: 14),
                    _DashboardSummaryCard(
                      title: 'Overview',
                      metrics: [
                        _DashboardMetricData(
                          icon: Icons.schedule_rounded,
                          label: 'Hours',
                          value: '$totalHours / 32',
                          color: AppColors.studentBlue,
                          background: AppColors.infoSoft,
                        ),
                        _DashboardMetricData(
                          icon: Icons.workspace_premium_rounded,
                          label: 'CATS',
                          value: '$totalCats / 8',
                          color: AppColors.warning,
                          background: AppColors.warningSoft,
                        ),
                        _DashboardMetricData(
                          icon: Icons.event_available_rounded,
                          label: 'Joined',
                          value: '$registeredCount activities',
                          color: AppColors.treasuryTeal,
                          background: AppColors.tealSoft,
                        ),
                        _DashboardMetricData(
                          icon: Icons.assignment_turned_in_outlined,
                          label: 'Latest claim',
                          value: latestStatus,
                          color: AppColors.studentBlue,
                          background: AppColors.infoSoft,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _DashboardStatusCard(ready: completedCount >= 4),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PusatAdabDashboard extends StatelessWidget {
  const _PusatAdabDashboard({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardProfileCard(
          name: userName,
          roleLabel: 'Pusat Adab',
          icon: Icons.verified_user_outlined,
          color: AppColors.treasuryTeal,
          background: AppColors.tealSoft,
          subtitle: 'Oversee activities and student claims.',
        ),
        const SizedBox(height: 14),
        const _DashboardSummaryCard(
          title: 'Overview',
          metrics: [
            _DashboardMetricData(
              icon: Icons.event_note_rounded,
              label: 'Active activities',
              value: '18 records',
              color: AppColors.treasuryTeal,
              background: AppColors.tealSoft,
            ),
            _DashboardMetricData(
              icon: Icons.rule_folder_outlined,
              label: 'Pending reviews',
              value: '3 claims',
              color: AppColors.studentBlue,
              background: AppColors.infoSoft,
            ),
          ],
        ),
        const SizedBox(height: 14),
        const _MessageCard(
          title: 'Claim review',
          message: 'Review each claim before making a decision.',
          color: AppColors.studentBlue,
          background: AppColors.infoSoft,
        ),
      ],
    );
  }
}

class _LecturerDashboard extends StatelessWidget {
  const _LecturerDashboard({required this.userName, required this.lecturerUid});

  final String userName;
  final String lecturerUid;

  @override
  Widget build(BuildContext context) {
    if (lecturerUid.trim().isEmpty) {
      return const _MessageCard(
        title: 'Lecturer profile unavailable',
        message:
            'No lecturer identifier was found for this session. Please sign in again.',
        color: AppColors.warning,
        background: AppColors.warningSoft,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _activityController.activities
          .where('supervisorLecturerId', isEqualTo: lecturerUid)
          .snapshots(),
      builder: (context, snapshot) {
        final activityDocs =
            snapshot.data?.docs ??
            <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        final activityIds = activityDocs.map((doc) => doc.id).toList();

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
            final gradedCount = registrationDocs
                .where(
                  (doc) =>
                      ((doc.data()['totalMarks'] as num?)?.toInt() ?? 0) > 0,
                )
                .length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardProfileCard(
                  name: userName,
                  roleLabel: 'Lecturer',
                  icon: Icons.school_outlined,
                  color: AppColors.studentBlue,
                  background: AppColors.infoSoft,
                  subtitle: 'Manage your activities and student marks.',
                ),
                const SizedBox(height: 14),
                _DashboardSummaryCard(
                  title: 'Overview',
                  metrics: [
                    _DashboardMetricData(
                      icon: Icons.event_available_rounded,
                      label: 'Supervised',
                      value: '${activityDocs.length} activities',
                      color: AppColors.studentBlue,
                      background: AppColors.infoSoft,
                    ),
                    _DashboardMetricData(
                      icon: Icons.edit_note_rounded,
                      label: 'Graded',
                      value: '$gradedCount records',
                      color: AppColors.treasuryTeal,
                      background: AppColors.tealSoft,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const _MessageCard(
                  title: 'Mark entry',
                  message: 'You can enter marks after attendance is recorded.',
                  color: AppColors.studentBlue,
                  background: AppColors.infoSoft,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
