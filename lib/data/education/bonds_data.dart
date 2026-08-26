import 'package:flutter/material.dart';
import '../../models/education_models.dart';

final bondsCategory = EduCategoryTree(
  title: 'Bonds & Fixed Income',
  subtitle: 'G-Sec, SDLs, T-Bills, Corporate Debt & Yields',
  icon: Icons.shield_rounded,
  color: const Color(0xFF38BDF8),
  subGroups: [
    EduSubGroup(
      groupName: '1. Fixed Income Mechanics & Yield Dynamics',
      groupTag: 'Foundations',
      icon: Icons.foundation_rounded,
      nodes: [
        EduLeafNode(
          title: 'Fixed Income Instruments & Debt Mechanics',
          badge: 'Debt Instruments',
          rateOrRule:
              'Contractual Obligation: Semi-Annual Coupon + 100% Principal Redemption',
          taxSection: 'Fixed Income (SOV / Corporate)',
          lockIn: 'Held to Maturity = Guaranteed Yield',
          shortSummary:
              'Debt contracts where investors lend capital to sovereign governments or corporations in exchange for scheduled coupon interest and principal return.',
          deepExplanation:
              '• Debt Capital Obligation: Bondholders are creditors with seniority over equity shareholders in corporate liquidation order.\n\n'
              '• Coupon Rate: The stated annual interest rate disbursed at predefined intervals (e.g., 7.18% p.a., paid semi-annually).\n\n'
              '• Maturity & Redemption: The termination date when the issuer repays the original par value (₹100/unit) in full.\n\n'
              '• Risk Architecture: Equities provide ownership with variable residual earnings; bonds provide contracted cash flows with capital protection.',
          sampleInvestment: '₹10.0 Lakhs in 10Y Benchmark G-Sec',
          sampleTenure: '10 Years (7.18% GS 2033)',
          sampleExpectedReturn: '7.18% p.a. Semi-Annual',
          sampleMaturityValue:
              '₹35,900 every 6 months + ₹10 Lakhs Principal Returned',
          metrics: [
            {'label': 'Sovereign Risk', 'val': '0.00% (SOV)'},
            {'label': 'Payment Cadence', 'val': 'Semi-Annual'},
            {'label': 'Direct Portal', 'val': 'RBI Retail Direct'},
          ],
        ),
        EduLeafNode(
          title: 'Yield to Maturity (YTM) & Interest Rate Sensitivity',
          badge: 'Price vs Yield',
          rateOrRule:
              'Bond Price is Inversely Proportional to Market Benchmark Rates',
          taxSection: 'Market Valuation',
          lockIn: 'Secondary Market Liquidity',
          shortSummary:
              'Bond market valuations fluctuate inversely with RBI repo rate cycles across duration profiles.',
          deepExplanation:
              '• Price-Yield Inverse Mechanics: As market interest rates decline, existing fixed-rate bonds with higher coupon rates appreciate in secondary market value.\n\n'
              '• Yield to Maturity (YTM): The annualized internal rate of return (IRR) realized by holding the debt security until final maturity with all coupon reinvestments.\n\n'
              '• Sovereign Credit Guarantee: Government Securities (G-Secs) and State Development Loans (SDLs) carry zero credit default risk.',
          sampleInvestment: '₹5.0 Lakhs in G-Sec (Rate Cut Cycle)',
          sampleTenure: '3 Years Holding',
          sampleExpectedReturn: '7.2% Yield + 4.5% Capital Gain',
          sampleMaturityValue:
              'Total Annualized Return: ~11.7% during easing cycles',
          metrics: [
            {'label': 'Price Dynamics', 'val': 'Inverse to Yield'},
            {'label': 'Credit Risk', 'val': '0.00% in G-Secs'},
            {'label': 'Tenure Range', 'val': '91D to 40 Years'},
          ],
        ),
      ],
    ),
    EduSubGroup(
      groupName: '2. Sovereign & State Debt Categories',
      groupTag: 'Sovereign Debt',
      icon: Icons.account_balance_rounded,
      nodes: [
        EduLeafNode(
          title: 'State Development Loans (SDLs) vs. Treasury Bills (T-Bills)',
          badge: 'Sovereign Spread',
          rateOrRule:
              'SDL (+35 bps spread over G-Sec) • T-Bills (Zero Coupon Discounted)',
          taxSection: 'Sovereign Debt',
          lockIn: 'Maturity (91D to 15 Yrs)',
          shortSummary:
              'State government long-term development bonds and RBI short-term liquidity management discount instruments.',
          deepExplanation:
              '• State Development Loans (SDLs): Sovereign bonds issued by State Governments (e.g., Tamil Nadu, Maharashtra). Serviced directly by RBI automatic debit from state treasury accounts, yielding 25–40 bps over Central G-Secs.\n\n'
              '• Treasury Bills (T-Bills): Sovereign short-term discount paper (91, 182, or 364 days). Issued at a discount to par and redeemed at ₹100 face value on maturity.',
          sampleInvestment: '₹1,00,000 in 364-Day T-Bill',
          sampleTenure: '364 Days',
          sampleExpectedReturn: '6.84% p.a.',
          sampleMaturityValue:
              'Purchase at ₹93,600 -> Redeem at ₹1,00,000 (Gain: ₹6,400)',
          metrics: [
            {'label': 'SDL Spread', 'val': '+0.35% vs G-Sec'},
            {'label': 'T-Bill Tenures', 'val': '91D / 182D / 364D'},
            {'label': 'Platform', 'val': 'RBI Retail Direct'},
          ],
        ),
      ],
    ),
  ],
);
