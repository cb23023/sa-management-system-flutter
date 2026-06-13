import 'attendance_report_download_stub.dart'
    if (dart.library.html) 'attendance_report_download_web.dart';

abstract class AttendanceReportDownload {
  static Future<void> openPrintableReport({
    required String title,
    required String subtitle,
    required String generatedAt,
    required List<String> summaryLines,
    required List<Map<String, String>> rows,
  }) {
    return openPrintableAttendanceReport(
      title: title,
      subtitle: subtitle,
      generatedAt: generatedAt,
      summaryLines: summaryLines,
      rows: rows,
    );
  }
}
