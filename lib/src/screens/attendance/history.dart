import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../theme/app_colors.dart';
import '../../controllers/attendance/attendance_controller.dart';
import '../../models/attendance/attendance_record_model.dart';
import '../../widgets/attendance_widgets.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({required this.currentUser, super.key});

  final AppUser? currentUser;

  @override
  Widget build(BuildContext context) {
    final controller = AttendanceController(currentUser: currentUser);
    return FutureBuilder<List<AttendanceRecordData>>(
      future: controller.loadRecordsForStudent(),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const [];
        final presentCount =
            records.where((r) => r.status == 'Present').length;
        final percentage = records.isEmpty
            ? 0
            : ((presentCount / records.length) * 100).round();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AttSectionHeader('History', 'Your attendance records.'),
            const SizedBox(height: 12),
            AttSurfaceCard(
              child: Column(
                children: [
                  AttActionTile(
                    'Attendance',
                    '$percentage%',
                    'Based on your current records.',
                    Icons.pie_chart_outline_rounded,
                    AppColors.violet,
                    AppColors.purpleSoft,
                  ),
                  if (records.isEmpty) ...[
                    const SizedBox(height: 12),
                    const AttMessageCard(
                      message: 'No attendance history from Firebase yet.',
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    ...records.map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AttStatusRow(
                          record.subject,
                          '${record.sessionName} | ${record.method} | ${record.date}',
                          record.status,
                          attendanceStatusColor(record.status),
                          attendanceStatusSoftColor(record.status),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

