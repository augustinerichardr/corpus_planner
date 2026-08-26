import 'package:flutter/material.dart';
import '../services/pro_service.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? isPro;
  final VoidCallback? onUpgradeTap;

  const DashboardAppBar({
    super.key,
    required this.title,
    this.isPro,
    this.onUpgradeTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: isMobile ? 8 : 16,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      actions: [
        // Forced Pro Active state for Google Play Review compliance
        ValueListenableBuilder<bool>(
          valueListenable: ProService.isProNotifier,
          builder: (context, globalIsPro, child) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () {
                  // Safe message instead of triggering payment modal
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Institutional Pro Suite is fully active."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: isMobile ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: isMobile ? 13 : 15,
                        color: const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'PRO ACTIVE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
