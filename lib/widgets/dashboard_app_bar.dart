// lib/widgets/dashboard_app_bar.dart
import 'package:flutter/material.dart';
import '../services/pro_service.dart';
import '../screens/pricing_screen.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? isPro;
  final VoidCallback? onUpgradeTap;
  final VoidCallback? onMenuPressed;

  const DashboardAppBar({
    super.key,
    required this.title,
    this.isPro,
    this.onUpgradeTap,
    this.onMenuPressed,
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
      leading: onMenuPressed != null
          ? IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
              onPressed: onMenuPressed,
            )
          : null,
      automaticallyImplyLeading: false,
      titleSpacing: onMenuPressed != null ? 0 : (isMobile ? 8 : 16),
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
        ValueListenableBuilder<bool>(
          valueListenable: ProService.isProNotifier,
          builder: (context, globalIsPro, child) {
            final proActive = isPro ?? globalIsPro;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () {
                  if (!proActive) {
                    if (onUpgradeTap != null) {
                      onUpgradeTap!();
                    } else {
                      PricingModal.show(context);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Institutional Pro Suite is fully active."),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: isMobile ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: (proActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (proActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B))
                          .withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        proActive
                            ? Icons.verified_rounded
                            : Icons.workspace_premium_rounded,
                        size: isMobile ? 13 : 15,
                        color: proActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        proActive ? 'PRO ACTIVE' : 'Upgrade',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: proActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
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
