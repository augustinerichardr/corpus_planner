import 'package:flutter/material.dart';
import '../../models/education_models.dart';

final investmentBasicsCategory = EduCategoryTree(
  title: 'Investment Fundamentals',
  subtitle: 'Capital Allocation, Compounding & Inflation Alpha',
  icon: Icons.lightbulb_outline_rounded,
  color: const Color(0xFFA78BFA),
  subGroups: [
    EduSubGroup(
      groupName: '1. Capital Allocation & Wealth Principles',
      groupTag: 'Core Directives',
      icon: Icons.account_balance_rounded,
      nodes: [
        EduLeafNode(
          title: 'Asset Growth & Capital Allocation Architecture',
          badge: 'Capital Theory',
          rateOrRule:
              'Total Wealth Growth = Capital Appreciation + Cash Flow Yield - Inflation',
          taxSection: 'Productive Capital',
          lockIn: 'Long-Term Horizon',
          shortSummary:
              'Systematic allocation into productive, income-generating instruments rather than holding depreciating cash.',
          deepExplanation:
              '• Productive Capital Allocation: Commits financial resources to corporate equity, fixed-income debt, and physical assets to expand real purchasing power over multi-year horizons.\n\n'
              '• Income & Growth Drivers: Combines equity earnings expansion, enterprise value appreciation, and consistent dividend/coupon cash flow yields.\n\n'
              '• Systematic Risk Management: Absorbs short-term market volatility to capture long-term equity risk premia over risk-free baseline rates.',
          sampleInvestment: '₹10,000 Monthly Allocation',
          sampleTenure: '15 Years',
          sampleExpectedReturn: '13.0% CAGR (Equities)',
          sampleMaturityValue: '₹57.8 Lakhs (vs ₹25.2L in 4% savings accounts)',
          metrics: [
            {'label': 'Core Target', 'val': 'Beating Inflation'},
            {'label': 'Instruments', 'val': 'Equity / Debt / Gold'},
            {'label': 'Horizon', 'val': '5+ Years'},
          ],
        ),
        EduLeafNode(
          title: 'Inflation Drag & Real Purchasing Power Protection',
          badge: 'Macro Economics',
          rateOrRule:
              'Real Compounded Return = Nominal Yield - Headline CPI Inflation',
          taxSection: 'Monetary Drag',
          lockIn: '7+ Years Discipline',
          shortSummary:
              'Headline CPI inflation constantly degrades the purchasing power of static cash, leading to negative real returns.',
          deepExplanation:
              '• Purchasing Power Degradation: At 6.5% average annual inflation, an instrument yielding 3.5% incurs a net -3.0% real destruction of purchasing power annually.\n\n'
              '• Equity Inflation Hedge: Corporate revenues and pricing pass-through allow equity asset classes to compound net capital ahead of inflation indices.\n\n'
              '• Asset Doubling Velocity (Rule of 72): Calculates capital doubling time by dividing 72 by the expected nominal CAGR (72 / 12% = 6 Years).',
          sampleInvestment: '₹10,000 / month SIP',
          sampleTenure: '15 Years',
          sampleExpectedReturn: '13.5% CAGR',
          sampleMaturityValue: '₹61.2 Lakhs (Total Invested: ₹18.0L)',
          metrics: [
            {'label': 'Benchmark CPI', 'val': '6.0% - 7.0%'},
            {'label': 'Savings Real Yield', 'val': '-3.0% Drag'},
            {'label': 'Equity Real Alpha', 'val': '+6.5% Net'},
          ],
        ),
      ],
    ),
    EduSubGroup(
      groupName: '2. Systematic Step-Up Strategies',
      groupTag: 'Growth Multipliers',
      icon: Icons.trending_up_rounded,
      nodes: [
        EduLeafNode(
          title: 'Systematic Step-Up SIP Multiplier',
          badge: '10% Annual Step-Up',
          rateOrRule: 'SIP_year(t) = Base_SIP * (1 + StepUp%)^(t-1)',
          taxSection: 'Discipline Multiplier',
          lockIn: 'Systematic',
          shortSummary:
              'Stepping up monthly contributions by 10% annually dramatically expands terminal corpus size.',
          deepExplanation:
              '• Income Alignment: Automatically increments SIP outlays alongside annual compensation increases, containing lifestyle expenditure inflation.\n\n'
              '• Terminal Value Expansion: A constant ₹25,000/month allocation yields ~₹1.82 Cr across 15 years at 12% CAGR, while a 10% annual step-up delivers ~₹3.41 Cr (1.87x multiplier).',
          sampleInvestment: '₹25,000 / mo + 10% Step-Up',
          sampleTenure: '15 Years',
          sampleExpectedReturn: '12.0% CAGR',
          sampleMaturityValue: '₹3.41 Cr (vs ₹1.82 Cr Static Allocation)',
          metrics: [
            {'label': 'Static 15Y Corpus', 'val': '₹1.82 Cr'},
            {'label': '10% Step-Up', 'val': '₹3.41 Cr'},
            {'label': 'Wealth Boost', 'val': '1.87x Output'},
          ],
        ),
      ],
    ),
  ],
);
