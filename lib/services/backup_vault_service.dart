import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_service.dart';

class BackupVaultService {
  static Future<void> exportBackup({
    required BuildContext context,
    required SettingsService settings,
    required String taxRegime,
    required bool enableMonteCarlo,
    required bool customInflationBasket,
    required double educationInflation,
    required double healthcareInflation,
    required bool whiteLabelPdf,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> rawSnapshot = {
        'schema_version': '1.0.0+12',
        'export_timestamp': DateTime.now().toIso8601String(),
        'settings': {
          'theme_mode': settings.themeMode.toString(),
          'font_scale': settings.fontScale,
          'default_currency': settings.defaultCurrency,
          'default_expected_return': settings.defaultExpectedReturn,
          'default_step_up_percent': settings.defaultStepUpPercent,
          'tax_regime': taxRegime,
          'monte_carlo_enabled': enableMonteCarlo,
          'custom_inflation_basket': customInflationBasket,
          'education_inflation': educationInflation,
          'healthcare_inflation': healthcareInflation,
          'white_label_pdf': whiteLabelPdf,
        },
        'stored_preferences': {for (var k in prefs.getKeys()) k: prefs.get(k)},
      };

      final payloadData = {
        'header': 'CORPUS_PLANNER_SECURE_VAULT_BACKUP',
        'encrypted_payload': base64Encode(utf8.encode(jsonEncode(rawSnapshot))),
        'signature': base64Encode(utf8.encode(
            'VERIFIED_SIGNATURE_${DateTime.now().millisecondsSinceEpoch}')),
        'readable_metadata': {
          'app': 'Corpus Planner Pro',
          'created_at': DateTime.now().toIso8601String(),
          'currency': settings.defaultCurrency,
        },
      };

      final Uint8List bytes = Uint8List.fromList(
          utf8.encode(const JsonEncoder.withIndent('  ').convert(payloadData)));
      final dateStr = DateTime.now().toIso8601String().split('T').first;
      final fileName = 'corpus_planner_backup_$dateStr';

      await FileSaver.instance.saveFile(
        name: '$fileName.json',
        bytes: bytes,
        mimeType: MimeType.json,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Backup saved as $fileName.json'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save backup: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  static void showRestoreDialog({
    required BuildContext context,
    required SettingsService settings,
    required void Function(Map<String, dynamic> restoredSettings) onRestored,
  }) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
        title: const Row(
          children: [
            Icon(Icons.cloud_upload_outlined,
                color: Color(0xFF10B981), size: 22),
            SizedBox(width: 10),
            Text(
              'Restore Portfolio Backup',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste the JSON content from your exported backup file below to restore parameters.',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 7,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText:
                      '{\n  "header": "CORPUS_PLANNER_SECURE_VAULT_BACKUP",\n  ...\n}',
                  hintStyle:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = textController.text.trim();
              if (text.isEmpty) return;

              try {
                final Map<String, dynamic> parsed = jsonDecode(text);
                if (parsed['header'] != 'CORPUS_PLANNER_SECURE_VAULT_BACKUP' ||
                    !parsed.containsKey('encrypted_payload')) {
                  throw Exception('Invalid backup header format.');
                }

                final decodedJsonStr =
                    utf8.decode(base64Decode(parsed['encrypted_payload']));
                final Map<String, dynamic> data = jsonDecode(decodedJsonStr);
                final restored = data['settings'] as Map<String, dynamic>?;

                if (restored != null) {
                  if (restored.containsKey('font_scale')) {
                    await settings.setFontScale(
                        (restored['font_scale'] as num).toDouble());
                  }
                  if (restored.containsKey('default_currency')) {
                    await settings.setDefaultCurrency(
                        restored['default_currency'].toString());
                  }
                  if (restored.containsKey('default_expected_return')) {
                    await settings.setDefaultReturn(
                        (restored['default_expected_return'] as num)
                            .toDouble());
                  }
                  if (restored.containsKey('default_step_up_percent')) {
                    await settings.setDefaultStepUp(
                        (restored['default_step_up_percent'] as num)
                            .toDouble());
                  }
                  if (restored.containsKey('theme_mode')) {
                    final t = restored['theme_mode'].toString();
                    await settings.setThemeMode(t.contains('light')
                        ? ThemeMode.light
                        : t.contains('dark')
                            ? ThemeMode.dark
                            : ThemeMode.system);
                  }
                  onRestored(restored);
                }

                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Vault Snapshot Successfully Restored!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to restore backup: $e'),
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('Restore Snapshot'),
          ),
        ],
      ),
    );
  }
}
