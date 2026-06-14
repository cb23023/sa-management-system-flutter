// =============================================================================
// SAMMS-PACK-207 | notification_area.dart
// Class Type    : Screen
// Responsibility: Displays module notifications for the current user filtered
//   to module2. Automatically marks all unread notifications as read via a
//   Firestore batch write when the tab is opened. Tapping a notification routes
//   the user to the relevant target (claim result, claim review, or Activities
//   tab) based on the actionLink, notification content, and current role.
// Attributes   : userUid (String), role (CoCurriculumRole), _markingRead (bool)
// Methods      : build (_NotificationArea, _ModuleNotificationBadge,
//                  _ModuleNotificationsTabState),
//                _markModuleNotificationsAsRead, _openNotificationTarget
// =============================================================================

part of 'co_curriculum_module_page.dart';

// _NotificationArea — thin router widget that delegates to
// _ModuleNotificationsTab, passing userUid and role for notification filtering
// and tap-routing.
class _NotificationArea extends StatelessWidget {
  const _NotificationArea({required this.userUid, required this.role});

  final String userUid;
  final CoCurriculumRole role;

  @override
  Widget build(BuildContext context) {
    return _ModuleNotificationsTab(userUid: userUid, role: role);
  }
}

// _ModuleNotificationBadge — streams unread notifications for the current user
// filtered to module2. Renders a red pill badge showing the count (capped at
// "9+"); returns SizedBox.shrink when there are no unread notifications.
class _ModuleNotificationBadge extends StatelessWidget {
  const _ModuleNotificationBadge({required this.userUid});

  final String userUid;

  @override
  // build — subscribes to the notifications collection filtered by userId.
  // Counts documents where module == 'module2' and isRead != true, then
  // displays the badge or hides it with SizedBox.shrink().
  Widget build(BuildContext context) {
    if (userUid.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _claimController.notifications
          .where('userId', isEqualTo: userUid)
          .snapshots(),
      builder: (context, snapshot) {
        final unreadCount =
            (snapshot.data?.docs ??
                    const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
                .where((doc) {
                  final data = doc.data();
                  return _safeLower(data['module']) == 'module2' &&
                      (data['isRead'] ?? false) != true;
                })
                .length;

        if (unreadCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white, width: 1.4),
          ),
          constraints: const BoxConstraints(minWidth: 18),
          child: Text(
            unreadCount > 9 ? '9+' : '$unreadCount',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

// _ModuleNotificationsTab — scrollable notification list for the module.
// Streams all notifications for the user, filters to module2, sorts by
// createdAt descending, and auto-marks unread docs as read via a batch write
// after the first frame. Each row is tappable and routes to the correct screen
// using _openNotificationTarget based on the notification type and user role.
class _ModuleNotificationsTab extends StatefulWidget {
  const _ModuleNotificationsTab({required this.userUid, required this.role});

  final String userUid;
  final CoCurriculumRole role;

  @override
  State<_ModuleNotificationsTab> createState() =>
      _ModuleNotificationsTabState();
}

class _ModuleNotificationsTabState extends State<_ModuleNotificationsTab> {
  bool _markingRead = false;

  // _markModuleNotificationsAsRead — performs a batched Firestore write to set
  // isRead: true on every unread notification document. Uses _markingRead to
  // prevent concurrent calls from overlapping.
  Future<void> _markModuleNotificationsAsRead(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> unreadDocs,
  ) async {
    if (_markingRead || unreadDocs.isEmpty) {
      return;
    }
    _markingRead = true;
    try {
      final batch = _claimController.batch();
      for (final doc in unreadDocs) {
        batch.set(doc.reference, {'isRead': true}, SetOptions(merge: true));
      }
      await batch.commit();
    } finally {
      _markingRead = false;
    }
  }

  @override
  // build — streams notifications for the user filtered to module2. Schedules
  // a post-frame callback to mark unread docs as read, sorts the list by
  // createdAt descending, and renders each notification as a tappable card with
  // an icon, type badge, message, and date pill. Tapping calls _openNotificationTarget.
  Widget build(BuildContext context) {
    if (widget.userUid.trim().isEmpty) {
      return const _MessageCard(
        title: 'Notifications unavailable',
        message: 'No user identifier was found for this session.',
        color: AppColors.warning,
        background: AppColors.warningSoft,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _claimController.notifications
          .where('userId', isEqualTo: widget.userUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _MessageCard(
            title: 'Unable to load notifications',
            message: 'Please try again later.',
            color: AppColors.danger,
            background: AppColors.dangerSoft,
          );
        }

        final docs =
            (snapshot.data?.docs ??
                    const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
                .where((doc) => _safeLower(doc.data()['module']) == 'module2')
                .toList();
        final unreadDocs = docs
            .where((doc) => (doc.data()['isRead'] ?? false) != true)
            .toList();
        if (unreadDocs.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _markModuleNotificationsAsRead(unreadDocs);
          });
        }
        docs.sort((a, b) {
          final aDate = _parseDynamicDate(a.data()['createdAt']);
          final bDate = _parseDynamicDate(b.data()['createdAt']);
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });

        if (docs.isEmpty) {
          return const _MessageCard(
            title: 'No notifications yet',
            message: 'Claim submissions and review decisions will appear here.',
            color: AppColors.studentBlue,
            background: AppColors.infoSoft,
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            final type = (data['type'] ?? 'info').toString();
            final createdAt = _parseDynamicDate(data['createdAt']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _openNotificationTarget(
                    context,
                    actionLink: (data['actionLink'] ?? '').toString(),
                    title: (data['title'] ?? '').toString(),
                    message: (data['message'] ?? '').toString(),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _moduleNotificationBackground(type),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            _moduleNotificationIcon(type),
                            color: _moduleNotificationColor(type),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    (data['title'] ?? 'Notification')
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  _InlineBadge(
                                    text: _moduleNotificationTag(type),
                                    color: _moduleNotificationColor(type),
                                    background: _moduleNotificationBackground(
                                      type,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                (data['message'] ?? '').toString(),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textMuted,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (createdAt != null)
                                    _InfoPill(
                                      icon: Icons.calendar_today_outlined,
                                      text: _displayDate(createdAt),
                                    ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: AppColors.textMuted,
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
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // _openNotificationTarget — routes the user when a notification is tapped.
  //   student   : push _ClaimResultPage if the notification is claim-related
  //               and has an actionLink; otherwise navigate to Claims or Activities tab.
  //   pusatAdab : push _ClaimReviewLoaderPage for claim notifications;
  //               otherwise navigate to Review or Activities tab.
  //   lecturer  : always navigates to the Activities tab.
  void _openNotificationTarget(
    BuildContext context, {
    required String actionLink,
    required String title,
    required String message,
  }) {
    final shell = ModuleShellScope.of(context);
    if (shell == null) {
      return;
    }

    final lowerAction = _safeLower(actionLink);
    final lowerTitle = _safeLower(title);
    final lowerMessage = _safeLower(message);
    final isClaimNotice =
        lowerAction.contains('claim') ||
        lowerTitle.contains('claim') ||
        lowerMessage.contains('claim') ||
        lowerMessage.contains('review');

    switch (widget.role) {
      case CoCurriculumRole.student:
        if (isClaimNotice && actionLink.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _ClaimResultPage(claimId: actionLink),
            ),
          );
        } else {
          shell.goToTabLabel(isClaimNotice ? 'Claims' : 'Activities');
        }
        break;
      case CoCurriculumRole.pusatAdab:
        if (isClaimNotice && actionLink.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _ClaimReviewLoaderPage(claimId: actionLink),
            ),
          );
        } else {
          shell.goToTabLabel(isClaimNotice ? 'Review' : 'Activities');
        }
        break;
      case CoCurriculumRole.lecturer:
        shell.goToTabLabel('Activities');
        break;
    }
  }
}
