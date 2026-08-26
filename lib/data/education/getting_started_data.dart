import 'package:flutter/material.dart';
import '../../models/education_models.dart';

final gettingStartedCategory = EduCategoryTree(
  title: 'How to Start Investing',
  subtitle: 'Step-by-Step Investor Roadmap & Shield',
  icon: Icons.rocket_launch_rounded,
  color: const Color(0xFF10B981),
  subGroups: [
    EduSubGroup(
      groupName: 'Phase 1: Protection & Foundation',
      groupTag: 'Safety First',
      icon: Icons.security_rounded,
      nodes: [
        EduLeafNode(
          title: 'Step 1: The Essential Financial Shield',
          badge: 'Phase 1 Checklist',
          rateOrRule:
              'Term Cover (20x CTC) + Health (₹10L-₹25L) + 6M Emergency Fund',
          taxSection: 'Sec 80D Eligible',
          lockIn: 'Permanent Cushion',
          shortSummary:
              'Establish an emergency runway and pure insurance before deploying capital into volatile equity markets.',
          deepExplanation:
              '• **Emergency Fund:** Park 6 months of living expenses + EMIs in Liquid Funds or Sweep-in FDs.\n'
              '• **Pure Term Insurance:** Buy term cover worth 15x–20x your annual income (Avoid ULIPs and Endowment plans).\n'
              '• **Comprehensive Health Insurance:** Maintain independent ₹10L–₹25L family floater cover separate from corporate employer coverage.',
          sampleInvestment: '₹5.0 Lakhs Emergency Fund',
          sampleTenure: 'Instant Liquidity (T+1)',
          sampleExpectedReturn: '6.8% Liquid Fund Yield',
          sampleMaturityValue: 'Full financial peace of mind during crisis',
          metrics: [
            {'label': 'Emergency Cover', 'val': '6 Months Cash'},
            {'label': 'Term Insurance', 'val': '20x Annual CTC'},
            {'label': 'Health Cover', 'val': '₹10L - ₹25L'},
          ],
        ),
      ],
    ),
    EduSubGroup(
      groupName: 'Phase 2: Execution & Allocation',
      groupTag: 'Portfolio Setup',
      icon: Icons.account_tree_rounded,
      nodes: [
        EduLeafNode(
          title: 'Step 2: Account Setup & Centralized KRA-KYC',
          badge: 'Phase 2 Checklist',
          rateOrRule: 'PAN + Aadhaar + CAMS/KFintech Centralized KRA-KYC',
          taxSection: 'SEBI Mandatory',
          lockIn: 'Lifetime Registered',
          shortSummary:
              'How to open Direct mutual fund portals (MF Central, AMC Websites) and Demat accounts.',
          deepExplanation:
              '• **KRA KYC:** Complete paperless video KYC via CAMS, KFintech, or any SEBI registered broker in 15 minutes.\n'
              '• **Direct vs Demat:** Direct plans can be held via MF Central (SoA form) or in Demat form with zero commissions.',
          sampleInvestment: '₹500 / month Initial Test SIP',
          sampleTenure: 'Immediate Activation',
          sampleExpectedReturn: 'Zero Brokerage',
          sampleMaturityValue: 'Active Direct investment pipeline',
          metrics: [
            {'label': 'KYC Time', 'val': '15 Minutes'},
            {'label': 'Direct Portal', 'val': 'MF Central / AMC'},
            {'label': 'Brokerage', 'val': '₹0 (Direct)'},
          ],
        ),
        EduLeafNode(
          title: 'Step 3: Core 3-Fund Portfolio Allocation',
          badge: 'Phase 3 Checklist',
          rateOrRule: '70:20:10 Strategic Allocation Matrix',
          taxSection: 'Strategic Balancing',
          lockIn: '7+ Years Discipline',
          shortSummary:
              'Constructing a diversified 3-fund portfolio across Large/Flexi-Cap, Mid-Cap, and Debt/Gold.',
          deepExplanation:
              '• **Core Anchor (50%):** Nifty 50 Index Fund or Flexi-Cap Fund.\n'
              '• **Growth Booster (30%):** Mid-Cap 150 Index or Quality Active Mid-Cap Fund.\n'
              '• **Shock Absorber (20%):** PPF / Debt Fund / Sovereign Gold Bonds (SGB).',
          sampleInvestment: '₹20,000 Monthly SIP Allocation',
          sampleTenure: '15 Years',
          sampleExpectedReturn: '13.5% Blended CAGR',
          sampleMaturityValue: '₹1.22 Cr Terminal Wealth',
          metrics: [
            {'label': 'Large/Flexi', 'val': '50% Allocation'},
            {'label': 'Mid-Cap', 'val': '30% Allocation'},
            {'label': 'Debt/Gold', 'val': '20% Allocation'},
          ],
        ),
      ],
    ),
  ],
);
