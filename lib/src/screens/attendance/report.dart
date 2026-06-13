import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../services/attendance/attendance_report_download.dart';
import '../../models/attendance/attendance_record_model.dart';
import '../../models/attendance/report_data.dart';
import 'attendance_dashboard.dart';
import '../../services/attendance/api_service.dart';
import '../../widgets/attendance/attendance_widgets.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  String _selectedLecturer = 'All';
  String _selectedModule = 'All';
  String _selectedMonth = 'All';
  bool _reportGenerated = false;

  Future<void> _downloadReport(
    List<AttendanceRecordData> records,
    PusatAdabDataBundle bundle,
  ) async {
    final report = ReportData(
      title: 'Attendance Report',
      subtitle: 'Pusat Adab attendance report',
      generatedAt: DateTime.now().toIso8601String(),
      lecturerFilter: _selectedLecturer,
      moduleFilter: _selectedModule,
      monthFilter: _selectedMonth,
      summaryLines: [
        'Records: ${records.length}',
        'Present: ${records.where((r) => r.status == 'Present').length}',
        'Lecturer filter: $_selectedLecturer',
        'Module filter: $_selectedModule',
        'Month filter: $_selectedMonth',
      ],
      rows: records
          .map(
            (r) => {
              'module': _resolveModule(r, bundle),
              'lecturer': _resolveLecturer(r, bundle),
              'student': r.name,
              'status': r.status,
              'date': r.date,
              'method': r.method,
            },
          )
          .toList(),
    );

    await AttendanceReportDownload.openPrintableReport(
      title: report.title,
      subtitle: report.subtitle,
      generatedAt: report.generatedAt,
      summaryLines: report.summaryLines,
      rows: report.rows,
    );
  }

  String _resolveModule(
      AttendanceRecordData record, PusatAdabDataBundle bundle) {
    if (record.activityId.isNotEmpty &&
        (bundle.activityTitles[record.activityId] ?? '').isNotEmpty) {
      return bundle.activityTitles[record.activityId]!;
    }
    final session = bundle.sessionsById[record.sessionId];
    if (session != null && session.subject.trim().isNotEmpty) {
      return session.subject;
    }
    return record.subject.isEmpty ? 'Attendance Module' : record.subject;
  }

  String _resolveLecturer(
      AttendanceRecordData record, PusatAdabDataBundle bundle) {
    if (record.lecturerName.trim().isNotEmpty) return record.lecturerName;
    final session = bundle.sessionsById[record.sessionId];
    if (session != null && session.lecturerName.trim().isNotEmpty) {
      return session.lecturerName;
    }
    return 'Unknown Lecturer';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PusatAdabDataBundle>(
      future: AttendanceApiService().getPusatAdabBundle(),
      builder: (context, snapshot) {
        final bundle = snapshot.data;
        if (bundle == null) {
          return const AttSurfaceCard(
            child: AttMessageCard(message: 'Loading report data...'),
          );
        }

        final lecturers = <String>{
          'All',
          ...bundle.records
              .map((r) => _resolveLecturer(r, bundle)),
        }.toList();
        final modules = <String>{
          'All',
          ...bundle.records.map((r) => _resolveModule(r, bundle)),
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

        final filteredRecords = filterPusatAdabRecords(
          bundle,
          lecturerName: _selectedLecturer,
          moduleName: _selectedModule,
          monthKey: _selectedMonth,
          dateValue: '',
        );
        final presentCount =
            filteredRecords.where((r) => r.status == 'Present').length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AttSectionHeader(
              'Generate Report',
              'Create a printable attendance report from database records.',
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
                          (v) =>
                              DropdownMenuItem(value: v, child: Text(v)),
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
                          (v) =>
                              DropdownMenuItem(value: v, child: Text(v)),
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
                          (v) =>
                              DropdownMenuItem(value: v, child: Text(v)),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedMonth = v ?? 'All'),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          setState(() => _reportGenerated = true),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Generate Report'),
                    ),
                  ),
                  if (_reportGenerated) ...[
                    const SizedBox(height: 14),
                    AttMessageCard(
                      message:
                          'Report ready with ${filteredRecords.length} records and $presentCount present students.',
                    ),
                    const SizedBox(height: 12),
                    AttActionTile(
                      'Report Preview',
                      '${filteredRecords.length} records',
                      'This report is based on the current filters and can be opened for PDF download/print.',
                      Icons.description_outlined,
                      AppColors.studentBlue,
                      AppColors.infoSoft,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: filteredRecords.isEmpty
                            ? null
                            : () => _downloadReport(
                                  filteredRecords,
                                  bundle,
                                ),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Download PDF'),
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
