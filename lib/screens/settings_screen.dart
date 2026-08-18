import 'package:flutter/material.dart';
import '../widgets/dashboard_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  final String activeTheme;
  final Color activeAccentColor;
  final bool isPaidUser;
  final ValueChanged<String> onThemeChanged;
  final ValueChanged<Color> onAccentChanged;
  final ValueChanged<bool> onTogglePaidUser;

  const SettingsScreen({
    super.key,
    required this.activeTheme,
    required this.activeAccentColor,
    required this.isPaidUser,
    required this.onThemeChanged,
    required this.onAccentChanged,
    required this.onTogglePaidUser,
  });

  static const List<Map<String, String>> themes = [
    {
      'name': 'Midnight Slate',
      'bg': '0xFF0F172A',
      'desc': 'Modern dark navy slate palette',
    },
    {
      'name': 'OLED Pure Black',
      'bg': '0xFF000000',
      'desc': 'Maximum contrast & battery saving',
    },
    {
      'name': 'Deep Charcoal',
      'bg': '0xFF18181B',
      'desc': 'Neutral high-readability dark theme',
    },
  ];

  static const List<Color> accents = [
    Color(0xFF10B981), // Emerald Green
    Color(0xFF38BDF8), // Cyan / Sky Blue
    Color(0xFFF59E0B), // Amber Gold
    Color(0xFFEC4899), // Neon Pink / Rose
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DashboardAppBar(
        title: 'App Settings & Preferences',
        onCountryChanged: (_) {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance & Theme',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Theme Options
            ...themes.map((t) {
              final isSel = activeTheme == t['name'];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSel ? activeAccentColor : Colors.white10,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t['name']!,
                          style: TextStyle(
                            color: isSel ? activeAccentColor : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t['desc']!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Radio<String>(
                      value: t['name']!,
                      groupValue: activeTheme,
                      activeColor: activeAccentColor,
                      onChanged: (v) {
                        if (v != null) onThemeChanged(v);
                      },
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),
            const Text(
              'Brand Accent Color',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Color Picker Row
            Row(
              children: accents.map((c) {
                final isSel = activeAccentColor.value == c.value;
                return GestureDetector(
                  onTap: () => onAccentChanged(c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSel ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: isSel
                        ? const Icon(Icons.check, size: 18, color: Colors.black)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const Text(
              'Membership & Pro Tier (Demo Simulation)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isPaidUser ? Colors.amberAccent : Colors.white10,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPaidUser
                                ? Icons.workspace_premium
                                : Icons.lock_clock,
                            color: isPaidUser
                                ? Colors.amberAccent
                                : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isPaidUser
                                ? 'Pro Subscription Active'
                                : 'Free Demo Mode',
                            style: TextStyle(
                              color: isPaidUser
                                  ? Colors.amberAccent
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Toggle to test unlimited AI queries and full app features.',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                  Switch(
                    value: isPaidUser,
                    activeColor: Colors.amberAccent,
                    onChanged: onTogglePaidUser,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
