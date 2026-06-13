class ReportData {
  const ReportData({
    required this.title,
    required this.subtitle,
    required this.generatedAt,
    required this.summaryLines,
    required this.rows,
    this.lecturerFilter = 'All',
    this.moduleFilter = 'All',
    this.monthFilter = 'All',
  });

  final String title;
  final String subtitle;
  final String generatedAt;
  final List<String> summaryLines;

  /// Each row is a map with keys: module, lecturer, student, status, date, method.
  final List<Map<String, String>> rows;

  final String lecturerFilter;
  final String moduleFilter;
  final String monthFilter;

  int get totalRecords => rows.length;

  int get presentCount =>
      rows.where((r) => r['status'] == 'Present').length;

  int get attendanceRate =>
      rows.isEmpty ? 0 : ((presentCount / rows.length) * 100).round();
}
