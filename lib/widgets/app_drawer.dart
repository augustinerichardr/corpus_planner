import 'package:flutter/material.dart';
import '../screens/pricing_screen.dart';
import '../services/pro_service.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int primaryIndex, [int? subTabIndex]) onNavigate;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: SafeArea(
        child: Column(
          children: [
            // App Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_graph_rounded,
                      color: Color(0xFF10B981),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CorpusIQ Pro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Wealth Intelligence Engine',
                        style: TextStyle(color: Colors.grey, fontSize: 10.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1E293B), height: 1),

            // Navigation Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                children: [
                  // 0. Wealth Planner
                  _navTile(
                    icon: Icons.bar_chart_rounded,
                    title: 'Wealth Planner',
                    isSelected: selectedIndex == 0,
                    onTap: () => onNavigate(0),
                  ),

                  // 1. Net Worth Portfolio (Sub-sections)
                  _expansionSection(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Net Worth Portfolio',
                    isParentActive: selectedIndex == 1,
                    subItems: [
                      _subTile('Assets & SIPs', 1, 0),
                      _subTile('Debts & Loans', 1, 1),
                      _subTile('Allocation & Milestones', 1, 2),
                    ],
                  ),

                  // 2. SWP Simulator
                  _navTile(
                    icon: Icons.account_balance_outlined,
                    title: 'SWP Simulator',
                    isSelected: selectedIndex == 2,
                    onTap: () => onNavigate(2),
                  ),

                  // 3. Mutual Funds Screener
                  _navTile(
                    icon: Icons.pie_chart_outline,
                    title: 'Mutual Funds Screener',
                    isSelected: selectedIndex == 3,
                    onTap: () => onNavigate(3),
                  ),

                  // 4. Bonds & Fixed Income
                  _navTile(
                    icon: Icons.shield_outlined,
                    title: 'Bonds & Fixed Income',
                    isSelected: selectedIndex == 4,
                    onTap: () => onNavigate(4),
                  ),

                  // 5. Arbitrage Engine
                  _navTile(
                    icon: Icons.swap_horizontal_circle_outlined,
                    title: 'Arbitrage Engine',
                    isSelected: selectedIndex == 5,
                    onTap: () => onNavigate(5),
                  ),

                  // 6. Dedicated Education Hub (Direct Predefined Topics)
                  _expansionSection(
                    icon: Icons.school_outlined,
                    title: 'Education & Learning Hub',
                    isParentActive: selectedIndex == 6,
                    accentColor: const Color(0xFF38BDF8),
                    subItems: [
                      _subTile('💡 What is Investment?', 6, 0),
                      _subTile('📊 What are Mutual Funds?', 6, 1),
                      _subTile('🛡️ Bonds & Fixed Income', 6, 2),
                      _subTile('⚡ Arbitrage & Cash Parking', 6, 3),
                      _subTile('🚀 How to Start Investing', 6, 4),
                      _subTile('⚖️ Income Tax Act Codes', 6, 5),
                      _subTile('🏦 Govt Small Savings (India)', 6, 6),
                    ],
                  ),

                  // 7. Settings
                  _navTile(
                    icon: Icons.settings_outlined,
                    title: 'App Settings',
                    isSelected: selectedIndex == 7,
                    onTap: () => onNavigate(7),
                  ),
                ],
              ),
            ),

            // Bottom Pro Banner
            ValueListenableBuilder<bool>(
              valueListenable: ProService.isProNotifier,
              builder: (context, isPro, _) {
                if (isPro) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: InkWell(
                    onTap: () => PricingModal.show(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: Color(0xFFF59E0B),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Upgrade to Pro',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
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
        ),
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
        size: 19,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF10B981) : Colors.white,
          fontSize: 12.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tileColor: isSelected
          ? const Color(0xFF10B981).withValues(alpha: 0.12)
          : Colors.transparent,
      onTap: onTap,
    );
  }

  Widget _expansionSection({
    required IconData icon,
    required String title,
    required bool isParentActive,
    required List<Widget> subItems,
    Color accentColor = const Color(0xFF10B981),
  }) {
    return Theme(
      data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        dense: true,
        initiallyExpanded: isParentActive,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Icon(
          icon,
          color: isParentActive ? accentColor : const Color(0xFF94A3B8),
          size: 19,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isParentActive ? accentColor : Colors.white,
            fontSize: 12.5,
            fontWeight: isParentActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        children: subItems,
      ),
    );
  }

  Widget _subTile(String label, int parentIdx, int subIdx) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 6),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        title: Text(
          label,
          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5),
        ),
        onTap: () => onNavigate(parentIdx, subIdx),
      ),
    );
  }
}
