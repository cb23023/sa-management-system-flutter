import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../models/attendance/attendance_record_model.dart';
import '../../services/attendance/api_service.dart';
import '../../widgets/attendance/attendance_widgets.dart';

String _moduleName(AttendanceRecordData record, PusatAdabDataBundle bundle) {
  if (record.activityId.isNotEmpty &&
      (bundle.activityTitles[record.activityId] ?? '').isNotEmpty) {
    return bundle.activityTitles[record.activityId]!;
  }
  final session = bundle.sessionsById[record.sessionId];
  if (session != null && session.subject.trim().isNotEmpty) {
    return session.subject;
  }
  return record.subject.trim().isEmpty ? 'Attendance Module' : record.subject;
}

String _lecturerName(AttendanceRecordData record, PusatAdabDataBundle bundle) {
  if (record.lecturerName.trim().isNotEmpty) return record.lecturerName;
  final session = bundle.sessionsById[record.sessionId];
  if (session != null && session.lecturerName.trim().isNotEmpty) {
    return session.lecturerName;
  }
  return 'Unknown Lecturer';
}

List<AttendanceRecordData> filterPusatAdabRecords(
  PusatAdabDataBundle bundle, {
  required String lecturerName,
  required String moduleName,
  required String monthKey,
  required String dateValue,
}) {
  return bundle.records.where((record) {
    final recordLecturer = _lecturerName(record, bundle);
    final recordModule = _moduleName(record, bundle);
    if (lecturerName != 'All' && recordLecturer != lecturerName) return false;
    if (moduleName != 'All' && recordModule != moduleName) return false;
    if (dateValue.isNotEmpty && record.date != dateValue) return false;
    if (monthKey != 'All') {
      final parsedDate = tryParseRecordDate(record.date);
      if (parsedDate == null) return false;
      final recordMonth =
          '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}';
      if (recordMonth != monthKey) return false;
    }
    return true;
  }).toList();
}

List<PusatAdabModuleSummary> buildModuleSummaries(
  PusatAdabDataBundle bundle,
  List<AttendanceRecordData> records,
) {
  final grouped = <String, List<AttendanceRecordData>>{};
  for (final record in records) {
    final moduleName = _moduleName(record, bundle);
    final lecturer = _lecturerName(record, bundle);
    final key = '${record.activityId}|$moduleName|$lecturer';
    grouped.putIfAbsent(key, () => []).add(record);
  }

  return grouped.entries.map((entry) {
    final moduleRecords = entry.value;
    final first = moduleRecords.first;
    final sessionIds = moduleRecords
        .map((r) => r.sessionId)
        .where((id) => id.trim().isNotEmpty)
        .toSet();
    final latestDate = moduleRecords
        .map((r) => tryParseRecordDate(r.date))
        .whereType<DateTime>()
        .fold<DateTime?>(null, (latest, date) {
      if (latest == null || date.isAfter(latest)) return date;
      return latest;
    });
    return PusatAdabModuleSummary(
      key: entry.key,
      moduleName: _moduleName(first, bundle),
      lecturerName: _lecturerName(first, bundle),
      records: moduleRecords,
      sessionCount: sessionIds.length,
      latestDate: latestDate,
    );
  }).toList()
    ..sort((a, b) {
      final left = a.latestDate ?? DateTime(2000);
      final right = b.latestDate ?? DateTime(2000);
      return right.compareTo(left);
    });
}

// ── Dashboard overview tab ────────────────────────────────────────────────────

class AttendanceDashboardScreen extends StatelessWidget {
  const AttendanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PusatAdabDataBundle>(
      future: AttendanceApiService().getPusatAdabBundle(),
      builder: (context, snapshot) {
        final bundle = snapshot.data;
        if (bundle == null) {
          return const AttSurfaceCard(
            child: AttMessageCard(message: 'Loading attendance data...'),
          );
        }

        final summaries =
            buildModuleSummaries(bundle, bundle.records);
        final presentCount =
            bundle.records.where((r) => r.status == 'Present').length;
        final attendanceRate = bundle.records.isEmpty
            ? 0
            : ((presentCount / bundle.records.length) * 100).round();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AttSectionHeader(
              'Pusat Adab',
              'Overview of attendance data from the database.',
            ),
            const SizedBox(height: 12),
            AttSurfaceCard(
              child: Column(
                children: [
                  AttActionTile(
                    'Modules',
                    '${summaries.length}',
                    'Modules with attendance records ready for review.',
                    Icons.menu_book_rounded,
                    AppColors.studentBlue,
                    AppColors.infoSoft,
                  ),
                  const SizedBox(height: 10),
                  AttActionTile(
                    'Attendance records',
                    '${bundle.records.length}',
                    'Student attendance records retrieved from Firebase.',
                    Icons.fact_check_outlined,
                    AppColors.treasuryTeal,
                    AppColors.tealSoft,
                  ),
                  const SizedBox(height: 10),
                  AttActionTile(
                    'Present rate',
                    '$attendanceRate%',
                    'Current overall present rate from the retrieved records.',
                    Icons.pie_chart_outline_rounded,
                    AppColors.success,
                    AppColors.successSoft,
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

// ── Records tab ───────────────────────────────────────────────────────────────

class PusatAdabRecordScreen extends StatefulWidget {
  const PusatAdabRecordScreen({super.key});

  @override
  State<PusatAdabRecordScreen> createState() => _PusatAdabRecordScreenState();
}

class _PusatAdabRecordScreenState extends State<PusatAdabRecordScreen> {
  String _selectedLecturer = 'All';
  String _selectedModule = 'All';
  String _selectedMonth = 'All';
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PusatAdabDataBundle>(
      future: AttendanceApiService().getPusatAdabBundle(),
      builder: (context, snapshot) {
        final bundle = snapshot.data;
        if (bundle == null) {
          return const AttSurfaceCard(
            child: AttMessageCard(message: 'Loading attendance records...'),
          );
        }

        final lecturers = <String>{
          'All',
          ...bundle.records.map((r) => _lecturerName(r, bundle)),
        }.toList();
        final modules = <String>{
          'All',
          ...bundle.records.map((r) => _moduleName(r, bundle)),
        }.toList();
        final months = <String>{
          'All',
          ...bundle.records
              .map((r) => tryParseRecordDate(r.date))
              .whereType<DateTime>()
              .map(
                (d) =>
                    '${d.year}-${d.month.toString().padLeft(2, '0')}',
              ),
        }.toList()
          ..sort();

        if (!lecturers.contains(_selectedLecturer)) _selectedLecturer = 'All';
        if (!modules.contains(_selectedModule)) _selectedModule = 'All';
        if (!months.contains(_selectedMonth)) _selectedMonth = 'All';

        final filtered = filterPusatAdabRecords(
          bundle,
          lecturerName: _selectedLecturer,
          moduleName: _selectedModule,
          monthKey: _selectedMonth,
          dateValue: _dateController.text.trim(),
        );
        final summaries = buildModuleSummaries(bundle, filtered);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AttSectionHeader(
              'Attendance Records',
              'Filter by lecturer, module, date, or month.',
            ),
            const SizedBox(height: 12),
            AttSurfaceCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLecturer,
                    decoration:
                        const InputDecoration(labelText: 'Lecturer'),
                    items: lecturers
                        .map(
                          (v) => DropdownMenuItem(
                              value: v, child: Text(v)),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedLecturer = v ?? 'All'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedModule,
                    decoration:
                        const InputDecoration(labelText: 'Module'),
                    items: modules
                        .map(
                          (v) => DropdownMenuItem(
                              value: v, child: Text(v)),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedModule = v ?? 'All'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedMonth,
                    decoration:
                        const InputDecoration(labelText: 'Month'),
                    items: months
                        .map(
                          (v) => DropdownMenuItem(
                              value: v, child: Text(v)),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedMonth = v ?? 'All'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _dateController.clear()),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (summaries.isEmpty)
              const AttSurfaceCard(
                child: AttMessageCard(
                  message:
                      'No attendance records match the selected filters.',
                ),
              )
            else
              AttSurfaceCard(
                child: Column(
                  children: summaries.map((summary) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ModuleTile(
                        summary: summary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _ModuleDetailPage(
                              summary: summary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.summary, required this.onTap});

  final PusatAdabModuleSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final latestDate = summary.latestDate == null
        ? 'No date'
        : summary.latestDate!.toIso8601String().split('T').first;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.grayOne,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.moduleName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${summary.lecturerName} | ${summary.records.length} records | '
                    '${summary.sessionCount} sessions | $latestDate',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AttPill(
              text: '${summary.attendanceRate}%',
              color: AppColors.success,
              background: AppColors.successSoft,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleDetailPage extends StatelessWidget {
  const _ModuleDetailPage({required this.summary});

  final PusatAdabModuleSummary summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: Text(summary.moduleName),
        backgroundColor: AppColors.studentBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AttSurfaceCard(
              child: Column(
                children: [
                  AttActionTile(
                    'Lecturer',
                    summary.lecturerName,
                    'Module owner for these attendance records.',
                    Icons.person_outline_rounded,
                    AppColors.studentBlue,
                    AppColors.infoSoft,
                  ),
                  const SizedBox(height: 10),
                  AttActionTile(
                    'Attendance rate',
                    '${summary.attendanceRate}%',
                    'Present students from the current filtered records.',
                    Icons.pie_chart_outline_rounded,
                    AppColors.success,
                    AppColors.successSoft,
                  ),
                  const SizedBox(height: 10),
                  AttActionTile(
                    'Sessions',
                    '${summary.sessionCount}',
                    'Unique attendance sessions related to this module.',
                    Icons.event_note_rounded,
                    AppColors.treasuryTeal,
                    AppColors.tealSoft,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const AttSectionHeader(
              'Student Attendance',
              'Student list and attendance details for this module.',
            ),
            const SizedBox(height: 12),
            AttSurfaceCard(
              child: Column(
                children: summary.records.map((record) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AttStatusRow(
                      record.name,
                      '${record.sessionName} | ${record.date} | ${record.method}',
                      record.status,
                      attendanceStatusColor(record.status),
                      attendanceStatusSoftColor(record.status),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
