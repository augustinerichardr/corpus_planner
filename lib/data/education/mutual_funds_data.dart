import 'package:flutter/material.dart';
import '../../models/education_models.dart';

final mutualFundsCategory = EduCategoryTree(
  title: 'Mutual Funds',
  subtitle: 'AMC, AUM, Equity, Debt, Hybrid & Solution Funds',
  icon: Icons.pie_chart_rounded,
  color: const Color(0xFFF59E0B),
  subGroups: [
    EduSubGroup(
      groupName: '1. Structure & Factor Metrics',
      groupTag: 'Foundations',
      icon: Icons.info_outline_rounded,
      nodes: [
        EduLeafNode(
          title: 'Mutual Fund Structure, AMC & NAV Mechanics',
          badge: 'SEBI Regulated',
          rateOrRule:
              'NAV = (Total Portfolio Assets - Liabilities) / Outstanding Units',
          taxSection: 'SEBI Guidelines',
          lockIn: 'Open-Ended (T+2 Liquidity)',
          shortSummary:
              'Collective investment trust managed by a SEBI-registered Asset Management Company (AMC) pooling public capital.',
          deepExplanation:
              '• Asset Pooling Architecture: Aggregates capital from retail and institutional investors to acquire fractional ownership across 40–60 vetted enterprises.\n\n'
              '• Asset Management Company (AMC): The fiduciary corporate entity (e.g., SBI MF, HDFC MF, ICICI Prudential) employing licensed fund managers and quantitative research desks.\n\n'
              '• Assets Under Management (AUM): Aggregate market valuation of the underlying scheme. Substantial AUM ensures tight bid-ask spreads and deep liquidity during market stress.\n\n'
              '• Net Asset Value (NAV): The per-unit book value computed daily at market close after subtracting operating expense ratios (TER).',
          sampleInvestment: '₹10,000 Initial Allocation',
          sampleTenure: '5 Years',
          sampleExpectedReturn: '13.0% CAGR',
          sampleMaturityValue: '₹18,424 (NAV expands from ₹100.0 to ₹184.2)',
          metrics: [
            {'label': 'Regulator', 'val': 'SEBI / AMFI'},
            {'label': 'Settlement', 'val': 'T+2 Business Days'},
            {'label': 'Min SIP', 'val': '₹500 / month'},
          ],
        ),
        EduLeafNode(
          title: 'Alpha (α), Beta (β) & Sharpe Ratio Analytics',
          badge: 'Factor Analytics',
          rateOrRule:
              'Sharpe Ratio = (CAGR - RiskFree Rate) / Portfolio Volatility',
          taxSection: 'Risk-Adjusted Return',
          lockIn: 'Analytical Metrics',
          shortSummary:
              'Institutional risk-adjusted scorecards evaluating manager alpha generation, market volatility sensitivity, and downside buffers.',
          deepExplanation:
              '• Jensen Alpha (α): Statistical measure of excess returns generated over the benchmark index. An alpha of +3.0% indicates 300 bps of active outperformance.\n\n'
              '• Market Beta (β): Relative volatility coefficient versus the benchmark index. A beta of 0.85 indicates 15% lower price swings during systemic drawdowns.\n\n'
              '• Sharpe Ratio: Excess return generated per unit of total risk (standard deviation). A Sharpe score > 1.20 reflects optimal risk-adjusted compounding efficiency.',
          sampleInvestment: 'Fund A (Sharpe 1.45) vs Fund B (Sharpe 0.82)',
          sampleTenure: '5 Years Evaluation',
          sampleExpectedReturn: 'Equal 14% CAGR',
          sampleMaturityValue:
              'Fund A achieved identical yield with 40% lower drawdowns',
          metrics: [
            {'label': 'Target Alpha', 'val': '> +2.0%'},
            {'label': 'Target Beta', 'val': '0.80 to 1.10'},
            {'label': 'Target Sharpe', 'val': '> 1.00'},
          ],
        ),
        EduLeafNode(
          title: 'Direct vs. Regular Plans & Total Expense Ratio (TER)',
          badge: 'Cost Architecture',
          rateOrRule:
              'Net Compounded Return = Gross Portfolio Yield - Total Expense Ratio',
          taxSection: 'Intermediary Trail',
          lockIn: 'None',
          shortSummary:
              'Regular plans deduct 1.0%–1.5% in distributor trail commissions annually, compounding to ~25% terminal capital loss over 20 years.',
          deepExplanation:
              '• Total Expense Ratio (TER): Annual operational, administrative, and portfolio management overhead deducted daily from fund NAV.\n\n'
              '• Regular Plan Commission Drag: Slices 0.75% to 1.25% annually from returns to compensate intermediary brokers and distributors.\n\n'
              '• Direct Plan Alpha Advantage: Direct plans eliminate distributor trail commissions, reinvesting 100% of gross earnings back into unit compounding.',
          sampleInvestment: '₹50,000 / month SIP',
          sampleTenure: '25 Years',
          sampleExpectedReturn: '13.0% Direct vs 11.8% Reg',
          sampleMaturityValue:
              'Direct: ₹11.4 Cr | Regular: ₹8.6 Cr (Saves ₹2.8 Cr in Fees)',
          metrics: [
            {'label': 'Direct TER', 'val': '0.20% - 0.75%'},
            {'label': 'Regular TER', 'val': '1.25% - 2.25%'},
            {'label': '20Y Drag', 'val': '~25% Less Capital'},
          ],
        ),
      ],
    ),
    EduSubGroup(
      groupName: '2. Equity Mutual Funds (SEBI Categories)',
      groupTag: 'Growth Assets',
      icon: Icons.show_chart_rounded,
      nodes: [
        EduLeafNode(
          title: 'Large-Cap, Mid-Cap & Small-Cap Categories',
          badge: 'Market Cap Bounds',
          rateOrRule: 'Large (Top 100) • Mid (101-250) • Small (251+)',
          taxSection: 'Sec 112A (12.5% LTCG)',
          lockIn: 'Open-Ended',
          shortSummary:
              'SEBI standardizes equity mutual funds based on the market capitalization ranking of underlying constituent holdings.',
          deepExplanation:
              '• Large-Cap Funds: Mandated minimum 80% investment in top 100 blue-chip market leaders. Core portfolio anchors delivering 12%–14% CAGR.\n\n'
              '• Mid-Cap Funds: Mandated minimum 65% exposure in emerging mid-tier enterprises (ranked 101–250). Accelerated earnings growth (14%–17% CAGR) with cyclical volatility.\n\n'
              '• Small-Cap Funds: Mandated minimum 65% in small enterprises (ranked 251+). High alpha upside potential accompanied by 30%–40% interim cyclical drawdowns (7+ yr horizon).',
          sampleInvestment: '₹15,000 / mo (40:30:30 Split)',
          sampleTenure: '10 Years',
          sampleExpectedReturn: '14.5% Portfolio CAGR',
          sampleMaturityValue: '₹37.8 Lakhs (Total Outlay: ₹18.0L)',
          metrics: [
            {'label': 'Large Cap', 'val': 'Top 100 Stocks'},
            {'label': 'Mid Cap', 'val': '101 to 250'},
            {'label': 'Small Cap', 'val': '251 and Above'},
          ],
        ),
        EduLeafNode(
          title: 'Flexi-Cap vs. Multi-Cap Allocation Framework',
          badge: 'Dynamic Allocation',
          rateOrRule:
              'Flexi (Unconstrained) vs Multi (25% Large + 25% Mid + 25% Small)',
          taxSection: 'Sec 112A (12.5% LTCG)',
          lockIn: 'Open-Ended',
          shortSummary:
              'Unconstrained macro allocation versus mandated structural diversification across market caps.',
          deepExplanation:
              '• Flexi-Cap Strategy: Fund managers hold complete discretion to allocate 0% to 100% across Large, Mid, and Small caps based on valuation cycles.\n\n'
              '• Multi-Cap Strategy: Enforces a strict minimum 25% in Large Caps, 25% in Mid Caps, and 25% in Small Caps at all times, preventing manager market-cap bias.',
          sampleInvestment: '₹10,000 / month SIP',
          sampleTenure: '12 Years',
          sampleExpectedReturn: '13.8% CAGR',
          sampleMaturityValue: '₹36.4 Lakhs (Total Invested: ₹14.4L)',
          metrics: [
            {'label': 'Flexi Mandate', 'val': 'Manager Discretion'},
            {'label': 'Multi Mandate', 'val': '25:25:25 Fixed Rule'},
            {'label': 'Target Horizon', 'val': '5 to 7+ Years'},
          ],
        ),
      ],
    ),
    EduSubGroup(
      groupName: '3. Hybrid, Balanced & Goal-Based Funds',
      groupTag: 'Asset Allocation',
      icon: Icons.account_balance_wallet_rounded,
      nodes: [
        EduLeafNode(
          title: 'Balanced Advantage Funds (BAF) & Hybrid Allocation',
          badge: 'Auto Rebalancing',
          rateOrRule: 'Dynamic Equity (30%-80%) + Debt (20%-70%)',
          taxSection: 'Equity Tax Classification',
          lockIn: 'Open-Ended',
          shortSummary:
              'Algorithmic rebalancing models that dynamically reduce equity exposure at peak valuations and increase equity during market corrections.',
          deepExplanation:
              '• Valuation-Driven Counter-Cyclical Asset Allocation: Models evaluate trailing P/E, P/B, and dividend yields to automatically book profits in equity during bull runs and buy dips in bear cycles.\n\n'
              '• Statutory Tax Alpha: Synthetically structures gross equity exposure above 65% via arbitrage hedges to maintain favorable Section 112A equity LTCG taxation (12.5%).',
          sampleInvestment: '₹20,000 / month SIP',
          sampleTenure: '7 Years',
          sampleExpectedReturn: '11.8% CAGR',
          sampleMaturityValue: '₹26.2 Lakhs (Muted downside drawdowns)',
          metrics: [
            {'label': 'Gross Equity', 'val': '65% to 80%'},
            {'label': 'Drawdown Buffer', 'val': 'High'},
            {'label': 'Tax Status', 'val': 'Equity Classified'},
          ],
        ),
      ],
    ),
  ],
);
