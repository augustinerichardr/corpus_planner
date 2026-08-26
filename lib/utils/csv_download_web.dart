// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;

void saveCsvFile(String csvContent, String fileName) {
  final bytes = utf8.encode(csvContent);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();

  html.Url.revokeObjectUrl(url);
}
