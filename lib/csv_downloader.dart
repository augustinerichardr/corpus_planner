// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;

void downloadCsvFile(String csvContent, String fileName) {
  final bytes = utf8.encode(csvContent);
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();

  html.Url.revokeObjectUrl(url);
}

class CsvDownloader {
  static void downloadCsv({
    required String csvData,
    required String fileName,
  }) {
    downloadCsvFile(csvData, fileName);
  }
}
