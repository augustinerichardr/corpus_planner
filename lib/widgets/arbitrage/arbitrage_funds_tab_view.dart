import 'package:flutter/material.dart';
import '../../services/app_language_service.dart';

class ArbitrageFundsTabView extends StatelessWidget {
  const ArbitrageFundsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final langService = AppLanguageService();

    return AnimatedBuilder(
      animation: langService,
      builder: (context, _) {
        final strings = langService.arbitrageStrings;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          children: [
            // 1. Mechanism Explanation Card
            _buildWrapperCard(
              icon: Icons.sync_alt_rounded,
              iconColor: const Color(0xFF10B981),
              title: strings['howItWorksTitle'] ??
                  'How Arbitrage Mutual Funds Generate Zero-Risk Returns',
              badge: strings['marketNeutralBadge'] ?? 'Market Neutral',
              badgeColor: const Color(0xFF10B981),
              description: strings['howItWorksDesc'] ??
                  'Arbitrage funds exploit price mispricings between the Cash Equity Market and Futures Market to lock in upfront risk-free spreads.',
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 550;
                  final step1 = _buildStepCard(
                    stepNumber: '1',
                    title: strings['step1Title'] ?? '1. Buy Cash Stock',
                    desc: strings['step1Desc'] ??
                        'Buy Reliance at ₹3,000 in cash market.',
                    accentColor: const Color(0xFF38BDF8),
                  );
                  final step2 = _buildStepCard(
                    stepNumber: '2',
                    title: strings['step2Title'] ?? '2. Sell Month Future',
                    desc: strings['step2Desc'] ??
                        'Simultaneously sell Future at ₹3,020.',
                    accentColor: const Color(0xFFF59E0B),
                  );
                  final step3 = _buildStepCard(
                    stepNumber: '3',
                    title: strings['step3Title'] ?? '3. Locked Expiry Gain',
                    desc: strings['step3Desc'] ??
                        '₹20 locked spread captured regardless of market direction.',
                    accentColor: const Color(0xFF10B981),
                  );

                  return isCompact
                      ? Column(
                          children: [
                            step1,
                            const SizedBox(height: 8),
                            step2,
                            const SizedBox(height: 8),
                            step3,
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: step1),
                            const SizedBox(width: 8),
                            Expanded(child: step2),
                            const SizedBox(width: 8),
                            Expanded(child: step3),
                          ],
                        );
                },
              ),
            ),
            const SizedBox(height: 14),

            // 2. Post-Tax Alpha Comparator Card
            _buildWrapperCard(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: const Color(0xFF38BDF8),
              title: strings['taxAlphaTitle'] ??
                  'Post-Tax Alpha: Arbitrage vs. Bank FD vs. Liquid Debt',
              badge: strings['taxBadge'] ?? '30% Tax Slab Basis',
              badgeColor: const Color(0xFF38BDF8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 550;

                  final arbLtcg = _buildTaxPill(
                    title: strings['arbLtcgTitle'] ?? 'Arbitrage (>1 Year)',
                    taxTag: strings['arbLtcgSub'] ?? '12.5% LTCG Tax Rate',
                    netYield: '~7.1% Net',
                    highlightColor: const Color(0xFF10B981),
                    isWinner: true,
                  );

                  final arbStcg = _buildTaxPill(
                    title: strings['arbStcgTitle'] ?? 'Arbitrage (<1 Year)',
                    taxTag: strings['arbStcgSub'] ?? '20% STCG Tax Rate',
                    netYield: '~6.4% Net',
                    highlightColor: const Color(0xFF38BDF8),
                  );

                  final bankFd = _buildTaxPill(
                    title: strings['bankFdTitle'] ?? 'Bank FD (1-3 Year)',
                    taxTag: strings['bankFdSub'] ?? 'Taxed at 30% Slab Rate',
                    netYield: '~4.9% Net',
                    highlightColor: const Color(0xFFEF4444),
                  );

                  final liquidDebt = _buildTaxPill(
                    title: strings['liquidDebtTitle'] ?? 'Liquid / Debt Fund',
                    taxTag:
                        strings['liquidDebtSub'] ?? 'Taxed at 30% Slab Rate',
                    netYield: '~4.7% Net',
                    highlightColor: const Color(0xFFEF4444),
                  );

                  if (isCompact) {
                    return Column(
                      children: [
                        arbLtcg,
                        const SizedBox(height: 8),
                        arbStcg,
                        const SizedBox(height: 8),
                        bankFd,
                        const SizedBox(height: 8),
                        liquidDebt,
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: arbLtcg),
                          const SizedBox(width: 8),
                          Expanded(child: arbStcg),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: bankFd),
                          const SizedBox(width: 8),
                          Expanded(child: liquidDebt),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // 3. Top Direct Arbitrage Funds List
            _buildWrapperCard(
              icon: Icons.format_list_bulleted_rounded,
              iconColor: const Color(0xFFA78BFA),
              title: strings['topFundsHeader'] ??
                  'Top Direct Arbitrage Mutual Funds in India',
              badge: strings['topFundsBadge'] ?? 'Zero Lock-In',
              badgeColor: const Color(0xFFA78BFA),
              child: Column(
                children: [
                  _buildFundRow(
                    name: 'Kotak Equity Arbitrage Fund - Direct Growth',
                    aum: '₹48,200 Cr',
                    expense: '0.36%',
                    oneYearReturn: '7.82%',
                  ),
                  const Divider(color: Color(0xFF334155), height: 16),
                  _buildFundRow(
                    name: 'Invesco India Arbitrage Fund - Direct Growth',
                    aum: '₹14,600 Cr',
                    expense: '0.34%',
                    oneYearReturn: '7.76%',
                  ),
                  const Divider(color: Color(0xFF334155), height: 16),
                  _buildFundRow(
                    name: 'SBI Arbitrage Opportunities Fund - Direct Growth',
                    aum: '₹29,100 Cr',
                    expense: '0.38%',
                    oneYearReturn: '7.69%',
                  ),
                  const Divider(color: Color(0xFF334155), height: 16),
                  _buildFundRow(
                    name: 'ICICI Prudential Equity Arbitrage - Direct Growth',
                    aum: '₹24,800 Cr',
                    expense: '0.35%',
                    oneYearReturn: '7.71%',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWrapperCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? badge,
    Color? badgeColor,
    String? description,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? const Color(0xFF10B981))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: (badgeColor ?? const Color(0xFF10B981))
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeColor ?? const Color(0xFF10B981),
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String desc,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  stepNumber,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxPill({
    required String title,
    required String taxTag,
    required String netYield,
    required Color highlightColor,
    bool isWinner = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWinner ? const Color(0xFF10B981) : const Color(0xFF334155),
          width: isWinner ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: highlightColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  netYield,
                  style: TextStyle(
                    color: highlightColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            taxTag,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildFundRow({
    required String name,
    required String aum,
    required String expense,
    required String oneYearReturn,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            Text('AUM: $aum',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
            Text('Exp Ratio: $expense',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
            Text('1Y Return: $oneYearReturn',
                style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
