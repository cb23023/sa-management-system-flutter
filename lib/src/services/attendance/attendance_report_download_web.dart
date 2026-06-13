import 'dart:js_interop';
import 'package:web/web.dart' as web;

String _escape(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}

Future<void> openPrintableAttendanceReport({
  required String title,
  required String subtitle,
  required String generatedAt,
  required List<String> summaryLines,
  required List<Map<String, String>> rows,
}) async {
  final summaryHtml = summaryLines
      .map((line) => '<li>${_escape(line)}</li>')
      .join();
  final rowsHtml = rows
      .map(
        (row) => '''
          <tr>
            <td>${_escape(row['module'] ?? '')}</td>
            <td>${_escape(row['lecturer'] ?? '')}</td>
            <td>${_escape(row['student'] ?? '')}</td>
            <td>${_escape(row['status'] ?? '')}</td>
            <td>${_escape(row['date'] ?? '')}</td>
            <td>${_escape(row['method'] ?? '')}</td>
          </tr>
        ''',
      )
      .join();

  final htmlContent = '''
    <html>
      <head>
        <title>${_escape(title)}</title>
        <style>
          body { font-family: Arial, sans-serif; padding: 32px; color: #173055; }
          h1 { margin-bottom: 8px; }
          p, li { font-size: 14px; line-height: 1.5; }
          table { width: 100%; border-collapse: collapse; margin-top: 20px; }
          th, td { border: 1px solid #d7e3f4; padding: 10px; text-align: left; font-size: 13px; }
          th { background: #eef4ff; }
          .muted { color: #5d6f8e; }
        </style>
      </head>
      <body>
        <h1>${_escape(title)}</h1>
        <p class="muted">${_escape(subtitle)}</p>
        <p class="muted">Generated at: ${_escape(generatedAt)}</p>
        <ul>$summaryHtml</ul>
        <table>
          <thead>
            <tr>
              <th>Module</th>
              <th>Lecturer</th>
              <th>Student</th>
              <th>Status</th>
              <th>Date</th>
              <th>Method</th>
            </tr>
          </thead>
          <tbody>$rowsHtml</tbody>
        </table>
        <script>
          window.onload = function () { window.print(); };
        </script>
      </body>
    </html>
  ''';

  final blobParts = <JSAny>[htmlContent.toJS].toJS;
  final options = web.BlobPropertyBag(type: 'text/html');
  final blob = web.Blob(blobParts, options);
  final url = web.URL.createObjectURL(blob);
  web.window.open(url, '_blank');
}
