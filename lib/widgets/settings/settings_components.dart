import 'package:flutter/material.dart';

class SettingsWrapperCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color cardBg;
  final Color cardBorder;
  final String? badge;
  final Color? badgeColor;

  const SettingsWrapperCard({
    super.key,
    required this.title,
    required this.child,
    required this.cardBg,
    required this.cardBorder,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? const Color(0xFF10B981))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: badgeColor ?? const Color(0xFF10B981),
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class SettingDropdownTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const SettingDropdownTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            items: items
                .map(
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(i, style: const TextStyle(fontSize: 12)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class SettingValueTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const SettingValueTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: Color(0xFF38BDF8),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

class MiniMetricInput extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const MiniMetricInput({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Icon(Icons.edit, size: 14, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showNumericEditDialog(
  BuildContext context, {
  required String title,
  required double initial,
  required ValueChanged<double> onSaved,
}) {
  final controller = TextEditingController(text: initial.toStringAsFixed(1));
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          suffixText: '%',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final val = double.tryParse(controller.text);
            if (val != null && val > 0) onSaved(val);
            Navigator.pop(ctx);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

String getFontScaleLabel(double scale) {
  if (scale <= 0.86) return 'Compact (85%)';
  if (scale <= 1.05) return 'Standard (100%)';
  if (scale <= 1.20) return 'Large (115%)';
  return 'Extra Large (130%)';
}
