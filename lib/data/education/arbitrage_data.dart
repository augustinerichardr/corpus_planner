import 'package:flutter/material.dart';
import '../../models/education_models.dart';

final arbitrageCategory = EduCategoryTree(
  title: 'Arbitrage & Cash Parking',
  subtitle: 'Market Neutrality, Spread Capture & Tax Alpha',
  icon: Icons.swap_horizontal_circle_rounded,
  color: const Color(0xFFF59E0B),
  subGroups: [
    EduSubGroup(
      groupName: '1. Market Spread Intelligence',
      groupTag: 'Cash-Futures',
      icon: Icons.currency_exchange_rounded,
      nodes: [
        EduLeafNode(
          title: 'What is Arbitrage & Cash-Futures Spread?',
          badge: 'Market Neutral',
          rateOrRule: 'Arbitrage Spread = Futures Price - Cash Spot Price',
          taxSection: 'Sec 112A (12.5% LTCG)',
          lockIn: 'None (Liquid T+2)',
          shortSummary:
              'How arbitrage mutual funds lock in risk-free spreads while maintaining favorable equity taxation.',
          deepExplanation:
              '• **Mechanism:** Simultaneously buying a stock in cash spot and shorting its futures contract. The difference is locked-in yield regardless of market direction.\n'
              '• **Tax Alpha:** Classified as Equity Funds for taxation (12.5% LTCG after 1 year), beating 30% slab rates on Bank FDs.',
          sampleInvestment: '₹5.0 Lakhs in Arbitrage Fund',
          sampleTenure: '1 Year',
          sampleExpectedReturn: '7.20% Gross Yield',
          sampleMaturityValue:
              'Post-Tax: ₹5.315L (6.3% Net) vs ₹5.245L (4.9% Net in 30% FD)',
          metrics: [
            {'label': 'Market Risk', 'val': 'Zero Directional'},
            {'label': 'Tax Rate (>1Y)', 'val': '12.5% LTCG'},
            {'label': 'Avg Return', 'val': '6.8% to 7.6%'},
          ],
        ),
      ],
    ),
    EduSubGroup(
      groupName: '2. Debt vs. Equity Spread Optimization',
      groupTag: 'Cash Flow Arbitrage',
      icon: Icons.balance_rounded,
      nodes: [
        EduLeafNode(
          title: 'Home Loan Prepayment vs. Equity Arbitrage',
          badge: 'Interest Spread',
          rateOrRule: 'Net Spread Alpha = Equity CAGR - Loan Interest Rate',
          taxSection: 'Sec 24(b) vs Sec 112A',
          lockIn: 'Loan Tenure',
          shortSummary:
              'Why investing surplus cash flow in equity mutual funds beats pre-closing low-cost 8.5% home loans.',
          deepExplanation:
              '• **Positive Spread:** Equity compounding at 13.5% outpaces an 8.5% mortgage rate by a net +5.0% annual alpha margin.\n'
              '• **Liquidity Advantage:** Prepaying locks capital into illiquid bricks, while mutual funds keep liquidity accessible for emergencies.',
          sampleInvestment: '₹15,000 / mo Surplus Cash',
          sampleTenure: '15 Years',
          sampleExpectedReturn: '13.5% Equity vs 8.5% Loan',
          sampleMaturityValue:
              'Mutual Fund Creates ₹1.05 Cr | Prepay Saves ₹33.6L Interest',
          metrics: [
            {'label': 'Loan Rate', 'val': '8.5% Floating'},
            {'label': 'Equity CAGR', 'val': '13.5% Historic'},
            {'label': 'Alpha Spread', 'val': '+5.0% Annual'},
          ],
        ),
      ],
    ),
  ],
);
