import 'package:flutter/material.dart';
import '../services/app_language_service.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = AppLanguageService();

    return AnimatedBuilder(
      animation: languageService,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF475569)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: languageService.currentLanguage,
              dropdownColor: const Color(0xFF1E293B),
              icon: const Icon(
                Icons.translate_rounded,
                color: Color(0xFF38BDF8),
                size: 18,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              items: AppLanguageService.supportedLanguages.entries.map((e) {
                final isProOnly =
                    e.key != 'en' &&
                    !languageService.isProUser &&
                    languageService.freePreviewCountRemaining == 0;

                return DropdownMenuItem(
                  value: e.key,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.value),
                      if (isProOnly) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFFF59E0B),
                          size: 13,
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  languageService.requestLanguageChange(val, context);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
