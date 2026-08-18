import 'dart:io';

Future<void> saveCsvFile(String csvContent, String fileName) async {
  final tempDir = Directory.systemTemp;
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsString(csvContent);
}
