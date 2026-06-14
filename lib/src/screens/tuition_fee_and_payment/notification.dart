import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../theme/app_colors.dart';
import '../../controllers/tuition_fee_and_payment/notification_controller.dart';
import '../../models/tuition_fee_and_payment/notification.dart';

// Student notice screen for SRS REQ-304:
// displays payment reminders, verification results, and access block notices.
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key, this.user});

  final AppUser? user;
  static final NotificationController _notificationController =
      NotificationController();

  @override
  Widget build(BuildContext context) {
    if (user == null) return const _LoadingPlaceholder();

    // Notices are filtered to the current student and tuition module so other
    // module notifications do not mix with payment-related updates.
    return StreamBuilder<List<TuitionNotification>>(
      stream: _notificationController.getNotificationStream(
        user!.uid,
        matricId: user!.identifier,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingPlaceholder();
        }

        final notifications = snapshot.data ?? [];
        if (notifications.isEmpty) {
          return const _EmptyState(
            icon: Icons.notifications_none,
            message:
                'No notices yet.\nYou\'ll be notified when there are payment updates.',
          );
        }

        return Column(
          children: notifications.map((notification) {
            return _NotificationItem(
              bulletColor: notification.bulletColor,
              title: notification.title,
              message: notification.message,
              time: notification.formattedDate,
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── Payment form sheet ───────────────────────────────────────────────────────

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.bulletColor,
    required this.title,
    required this.message,
    required this.time,
  });

  final Color bulletColor;
  final String title;
  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: bulletColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
