import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../controllers/attendance/attendance_controller.dart';
import '../../models/attendance/attendance_record_model.dart';
import '../../widgets/attendance/attendance_widgets.dart';

class AttendanceRecordScreen extends StatefulWidget {
  const AttendanceRecordScreen({required this.currentUser, super.key});

  final AppUser? currentUser;

  @override
  State<AttendanceRecordScreen> createState() => _AttendanceRecordScreenState();
}

class _AttendanceRecordScreenState extends State<AttendanceRecordScreen> {
  late final AttendanceController _controller;
  late Future<List<AttendanceRecordData>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _controller = AttendanceController(currentUser: widget.currentUser);
    _recordsFuture = _controller.loadRecordsForLecturer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(
    AttendanceRecordData record,
    String status,
  ) async {
    try {
      await _controller.updateRecordStatus(record, status);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _recordsFuture = _controller.loadRecordsForLecturer();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AttendanceRecordData>>(
      future: _recordsFuture,
      builder: (context, snapshot) {
        final records = snapshot.data ?? const [];
        final sessionKeys =
            records.map(recordSessionKey).toSet().toList();

        if (sessionKeys.isNotEmpty &&
            !sessionKeys.contains(_controller.selectedSessionKey)) {
          _controller.selectedSessionKey = sessionKeys.first;
        }

        final filtered = records.where((record) {
          final sessionMatch = _controller.selectedSessionKey.isEmpty ||
              recordSessionKey(record) == _controller.selectedSessionKey;
          if (!sessionMatch) return false;

          final parsedDate = tryParseRecordDate(record.date);
          if (parsedDate == null) {
            return _controller.dateFilter == RecordDateFilter.all;
          }
          final today = DateTime.now();
          final startOfToday =
              DateTime(today.year, today.month, today.day);
          final startOfWeek = startOfToday
              .subtract(Duration(days: startOfToday.weekday - 1));
          final startOfMonth = DateTime(today.year, today.month, 1);
          return switch (_controller.dateFilter) {
            RecordDateFilter.today => parsedDate.isAfter(
                startOfToday.subtract(const Duration(seconds: 1)),
              ),
            RecordDateFilter.thisWeek => parsedDate.isAfter(
                startOfWeek.subtract(const Duration(seconds: 1)),
              ),
            RecordDateFilter.thisMonth => parsedDate.isAfter(
                startOfMonth.subtract(const Duration(seconds: 1)),
              ),
            RecordDateFilter.all => true,
          };
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AttSectionHeader(
              'Attendance Records',
              'Select class history and update student status.',
            ),
            const SizedBox(height: 12),
            AttSurfaceCard(
              child: Column(
                children: [
                  if (sessionKeys.isNotEmpty) ...[
                    DropdownButtonFormField<RecordDateFilter>(
                      initialValue: _controller.dateFilter,
                      decoration:
                          const InputDecoration(labelText: 'Filter Date'),
                      items: RecordDateFilter.values
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(f.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _controller.dateFilter = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _controller.selectedSessionKey,
                      decoration: const InputDecoration(
                        labelText: 'Class History',
                      ),
                      items: sessionKeys.map((key) {
                        final parts = key.split('|');
                        final subject =
                            parts.length > 1 ? parts[1] : 'Attendance';
                        final sessionName =
                            parts.length > 2 ? parts[2] : 'Session';
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text('$subject - $sessionName'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(
                            () => _controller.selectedSessionKey = value);
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (filtered.isEmpty)
                    const AttMessageCard(
                        message: 'No attendance record yet.')
                  else
                    ...filtered.map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AttEditableRecordCard(
                          record: record,
                          onChanged: (v) => _updateStatus(record, v),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
