import 'package:flutter/material.dart';
import '../screens/pricing_screen.dart';

class DashboardAppBar<T> extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final ValueChanged<T>? onCountryChanged;
  final bool isPro;
  final VoidCallback? onUpgradeTap;

  const DashboardAppBar({
    super.key,
    required this.title,
    this.onCountryChanged,
    this.isPro = false,
    this.onUpgradeTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0F172A),
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.show_chart,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        // PRO STATUS INDICATOR / UPGRADE BUTTON
        if (!isPro)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ElevatedButton.icon(
              onPressed: onUpgradeTap ?? () => PricingModal.show(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              icon: const Icon(
                Icons.workspace_premium,
                size: 16,
                color: Colors.black,
              ),
              label: const Text(
                'Upgrade Pro',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.verified, color: Color(0xFF10B981), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'PRO ACTIVE',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(width: 12),

        // REGION / CURRENCY DROPDOWN
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'India (₹ INR)',
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'India (₹ INR)',
                  child: Text('India (₹ INR)'),
                ),
                DropdownMenuItem(
                  value: 'USA (\$ USD)',
                  child: Text('USA (\$ USD)'),
                ),
              ],
              onChanged: (val) {},
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
