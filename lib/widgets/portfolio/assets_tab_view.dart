import 'package:flutter/material.dart';
import '../../models/portfolio_models.dart';
import '../../services/settings_service.dart';

class AssetsTabView extends StatelessWidget {
  final List<AssetItem> assets;
  final double totalMonthlySip;
  final VoidCallback onClearAll;
  final VoidCallback onResetSample;
  final VoidCallback onAddAsset;

  const AssetsTabView({
    super.key,
    required this.assets,
    required this.totalMonthlySip,
    required this.onClearAll,
    required this.onResetSample,
    required this.onAddAsset,
  });

  @override
  Widget build(BuildContext context) {
    final isSample = assets.length == 6;
    final settings = SettingsService();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return Column(
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSample
                          ? 'Sample Portfolio Baseline'
                          : 'Your Custom Asset Stack',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isSample) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color:
                                const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          'SAMPLE TEMPLATE',
                          style: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'SIP: ${settings.formatCurrency(totalMonthlySip)}/mo',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: const Size(50, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: isSample ? onClearAll : onResetSample,
                      child: Text(
                        isSample ? 'Clear' : 'Sample',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10.5),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: onAddAsset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: const Size(60, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.add, size: 12),
                      label: const Text(
                        'Add Asset',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1100
                      ? 3
                      : (constraints.maxWidth > 650 ? 2 : 1);
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisExtent: 95,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: assets.length,
                    itemBuilder: (context, idx) =>
                        _buildAssetTile(assets[idx], settings),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAssetTile(AssetItem item, SettingsService settings) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(item.icon, color: item.accentColor, size: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Tooltip(
                          message: item.tooltip,
                          child: const Icon(
                            Icons.help_outline,
                            color: Colors.grey,
                            size: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${item.category} • ${item.expectedReturn}% p.a.',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(color: Colors.grey, fontSize: 9),
                  ),
                  Text(
                    settings.formatCurrency(item.currentValue),
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Text(
                  item.monthlySip > 0
                      ? 'SIP: ${settings.formatCurrency(item.monthlySip)}/mo'
                      : 'Lump Sum Only',
                  style: TextStyle(
                    color: item.monthlySip > 0
                        ? const Color(0xFF38BDF8)
                        : Colors.grey,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
