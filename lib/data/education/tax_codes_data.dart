import 'package:flutter/material.dart';
import '../../models/education_models.dart';

final taxCodesCategory = EduCategoryTree(
  title: 'Income Tax Act Codes',
  subtitle: 'Capital Gains (Sec 112A/111A/112/50AA) & Deductions',
  icon: Icons.gavel_rounded,
  color: const Color(0xFF38BDF8),
  subGroups: [
    EduSubGroup(
      groupName: '1. Capital Gains Tax Codes (Budget 2024–26)',
      groupTag: 'Equity & Debt',
      icon: Icons.receipt_long_rounded,
      nodes: [
        EduLeafNode(
          title: 'Section 112A — Long-Term Capital Gains (LTCG)',
          badge: 'Equity MF & Shares',
          rateOrRule: '12.5% Flat on Gains Exceeding ₹1.25 Lakhs / FY',
          taxSection: 'Sec 112A (Holding > 12 Months)',
          lockIn: 'Holding > 12 Months',
          shortSummary:
              'Tax rules on profits realized from equity shares and equity mutual funds held for more than 12 months.',
          deepExplanation:
              '• Exemption Limit: First ₹1,25,000 of aggregate LTCG in each financial year is 100% tax-free.\n\n'
              '• Flat Rate: Capital gains above ₹1.25 Lakhs are taxed at 12.5% without indexation.\n\n'
              '• Tax Harvesting: Rebalance and redeem up to ₹1.25 Lakhs of gains before March 31 every year and reinvest to reset your acquisition cost base with zero tax liability.',
          sampleInvestment: '₹5.0 Lakhs Realized Gain',
          sampleTenure: '> 12 Months Holding',
          sampleExpectedReturn: '12.5% on (₹5L - ₹1.25L)',
          sampleMaturityValue: 'Tax Payable: ₹46,875 (Effective Rate: 9.3%)',
          metrics: [
            {'label': 'Tax Rate', 'val': '12.5% Flat'},
            {'label': 'Annual Exemption', 'val': '₹1.25 Lakhs / FY'},
            {'label': 'Holding Rule', 'val': '> 12 Months'},
          ],
        ),
        EduLeafNode(
          title: 'Section 111A — Short-Term Capital Gains (STCG)',
          badge: 'Equity Exits < 1 Year',
          rateOrRule: 'Flat 20.0% on Realized Gains',
          taxSection: 'Sec 111A (Holding < 12 Months)',
          lockIn: 'None',
          shortSummary:
              'Flat tax applied to equity positions and mutual funds sold prior to completing 12 months.',
          deepExplanation:
              '• Flat 20% Tax: Applies regardless of whether your personal tax slab is 10%, 20%, or 30%.\n\n'
              '• Zero Exemption: No basic threshold exemption on STCG trades.\n\n'
              '• Loss Carry-Forward: STCG losses can be set off against both STCG and LTCG gains and carried forward for 8 assessment years.',
          sampleInvestment: '₹2.0 Lakhs Short-Term Profit',
          sampleTenure: '8 Months Holding',
          sampleExpectedReturn: 'Flat 20% Tax',
          sampleMaturityValue: 'Tax Payable: ₹40,000 (Net Profit: ₹1,60,000)',
          metrics: [
            {'label': 'Tax Rate', 'val': '20.0% Flat'},
            {'label': 'Exempt Threshold', 'val': '₹0 (Full Tax)'},
            {'label': 'Carry Forward', 'val': '8 Years'},
          ],
        ),
        EduLeafNode(
          title: 'Section 112 — Long-Term Capital Gains (Non-Equity)',
          badge: 'Real Estate & Gold',
          rateOrRule: '12.5% Flat without Indexation',
          taxSection: 'Sec 112 (Holding > 24 Months)',
          lockIn: 'Holding > 24 Months',
          shortSummary:
              'Governs the taxation of long-term capital gains on non-equity assets such as immovable property, gold, and unlisted shares.',
          deepExplanation:
              '• Applicable Assets: Property, gold, and unlisted shares held for over 24 months.\n\n'
              '• Flat Rate: Following Budget 2024 (July 23, 2024), taxed at 12.5% without indexation.\n\n'
              '• Grandfathering: For property bought before July 23, 2024, individuals can choose between 12.5% without indexation or 20% with indexation.',
          sampleInvestment: '₹20.0 Lakhs Profit on Gold/Property',
          sampleTenure: '3 Years Holding',
          sampleExpectedReturn: '12.5% Flat Tax',
          sampleMaturityValue: 'Tax Payable: ₹2,50,000',
          metrics: [
            {'label': 'Tax Rate', 'val': '12.5% Flat'},
            {'label': 'Indexation', 'val': 'Removed (Post Jul 24)'},
            {'label': 'Holding Rule', 'val': '> 24 Months'},
          ],
        ),
        EduLeafNode(
          title: 'Section 50AA — Specified Mutual Funds & Debt',
          badge: 'Debt MFs / Unlisted',
          rateOrRule: 'Taxed entirely at your Income Tax Slab Rate',
          taxSection: 'Sec 50AA (Any Holding Period)',
          lockIn: 'None',
          shortSummary:
              'Mandates that gains from specific debt funds, unlisted bonds, and market-linked debentures are taxed as short-term gains.',
          deepExplanation:
              '• Affected Assets: Debt mutual funds bought on or after April 1, 2023, and unlisted bonds transferred after July 23, 2024.\n\n'
              '• Taxation: Always taxed at the investor\'s income tax slab rate (up to 39%), regardless of how long you hold them.\n\n'
              '• No LTCG Benefit: These instruments lose all long-term capital gains and indexation advantages.',
          sampleInvestment: '₹5.0 Lakhs Gain in Debt MF',
          sampleTenure: '4 Years Holding',
          sampleExpectedReturn: '30% Slab Rate Tax',
          sampleMaturityValue: 'Tax Payable: ₹1,50,000',
          metrics: [
            {'label': 'Tax Rate', 'val': 'Slab Rate (up to 39%)'},
            {'label': 'LTCG Benefit', 'val': 'Not Available'},
            {'label': 'Indexation', 'val': 'Not Available'},
          ],
        ),
      ],
    ),
    EduSubGroup(
      groupName: '2. Tax Deductions & Exemptions',
      groupTag: 'Chapter VI-A',
      icon: Icons.shield_outlined,
      nodes: [
        EduLeafNode(
          title: 'Section 80C — Core Tax Deductions Basket',
          badge: 'Annual Deductions',
          rateOrRule: 'Up to ₹1,50,000 Aggregate Deduction',
          taxSection: 'Sec 80C (Old Regime)',
          lockIn: '3 to 15 Years',
          shortSummary:
              'The omnibus tax deduction basket covering PPF, ELSS, EPF, Life Insurance, and Home Loan Principal.',
          deepExplanation:
              '• Eligible Instruments: ELSS Mutual Funds (3 yr lock-in), PPF, EPF/VPF, SSY, NSC, and home loan principal repayments.\n\n'
              '• Tax Saving: Saves ₹46,800 annually for individuals in the 30% tax bracket under the Old Regime.',
          sampleInvestment: '₹1.5 Lakhs Annual Outlay',
          sampleTenure: 'Annual Cycle',
          sampleExpectedReturn: 'Depends on Vehicle (ELSS 13%, PPF 7.1%)',
          sampleMaturityValue: 'Direct Tax Saved: ₹46,800 / year (30% slab)',
          metrics: [
            {'label': 'Max Deduction', 'val': '₹1.50 Lakhs'},
            {'label': 'Tax Shield (30%)', 'val': '₹46,800 / FY'},
            {'label': 'Shortest Lock-in', 'val': 'ELSS (3 Years)'},
          ],
        ),
        EduLeafNode(
          title: 'Section 80CCD(1B) — National Pension System (NPS)',
          badge: 'Retirement Anchor',
          rateOrRule: 'Exclusive Additional ₹50,000 Tax Deduction',
          taxSection: 'Over & Above Sec 80C',
          lockIn: 'Till Age 60',
          shortSummary:
              'Dedicated retirement tax deduction saving up to ₹15,000 in income taxes for 30% slab earners.',
          deepExplanation:
              '• Deduction Advantage: Additional ₹50,000 deduction over the standard ₹1.5L Section 80C ceiling.\n\n'
              '• Maturity Exit: At age 60, 60% of the corpus is 100% tax-free lump sum; remaining 40% converts into a monthly taxable annuity pension.',
          sampleInvestment: '₹50,000 / year (20 Yrs)',
          sampleTenure: '20 Years',
          sampleExpectedReturn: '11.5% CAGR',
          sampleMaturityValue: '₹36.2 Lakhs + ₹3.0 Lakhs Tax Saved (30% slab)',
          metrics: [
            {'label': 'Extra Shield', 'val': '₹50,000 / FY'},
            {'label': 'Lump Sum Exit', 'val': '60% Tax-Free'},
            {'label': 'Equity Exposure', 'val': 'Up to 75%'},
          ],
        ),
        EduLeafNode(
          title: 'Section 24(b) — Home Loan Interest Shield',
          badge: 'Old Tax Regime',
          rateOrRule: 'Up to ₹2,00,000 Annual Interest Deduction',
          taxSection: 'Sec 24(b) (Self-Occupied)',
          lockIn: 'Property Amortization',
          shortSummary:
              'Tax shield saving up to ₹60,000 in income tax annually for home loan borrowers.',
          deepExplanation:
              '• Deduction Cap: Up to ₹2 Lakhs per financial year on interest payments for self-occupied properties.\n\n'
              '• Regime Rule: Valid exclusively under the Old Tax Regime. The New Tax Regime offers zero deduction for self-occupied house interest.',
          sampleInvestment: '₹2.0 Lakhs Interest Paid',
          sampleTenure: 'Annual Amortization',
          sampleExpectedReturn: 'Direct Slab Tax Shield',
          sampleMaturityValue: 'Tax Saved: ₹62,400 / year (30% slab + cess)',
          metrics: [
            {'label': 'Max Deduction', 'val': '₹2.0 Lakhs / FY'},
            {'label': 'Tax Saving (30%)', 'val': '₹62,400 / FY'},
            {'label': 'Regime', 'val': 'Old Regime Only'},
          ],
        ),
        EduLeafNode(
          title: 'Section 54EC — Capital Gain Exemption Bonds',
          badge: 'Real Estate Tax Shield',
          rateOrRule: 'Max ₹50 Lakhs Exemption on Property Gains',
          taxSection: 'Sec 54EC (Property Gains)',
          lockIn: '5 Years Mandatory',
          shortSummary:
              'Exempts long-term capital gains tax on real estate sales by investing proceeds into REC, PFC, or NHAI bonds.',
          deepExplanation:
              '• Tax Saving: Exempts 12.5% LTCG on real estate profits when invested within 6 months of property sale.\n\n'
              '• Limits: Maximum investment capped at ₹50 Lakhs per individual per financial year.',
          sampleInvestment: '₹50 Lakhs Real Estate Profit',
          sampleTenure: '5 Years Lock-in',
          sampleExpectedReturn: '5.25% p.a. Annual',
          sampleMaturityValue: 'Saves ₹6.25 Lakhs Capital Gains Tax',
          metrics: [
            {'label': 'Max Cap', 'val': '₹50 Lakhs / FY'},
            {'label': 'Lock-in', 'val': '5 Years Fixed'},
            {'label': 'Tax Status', 'val': 'Exempts Property LTCG'},
          ],
        ),
      ],
    ),
  ],
);
