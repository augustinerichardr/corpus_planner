import 'package:flutter/material.dart';
import '../../models/education_models.dart';

final govtSavingsCategory = EduCategoryTree(
  title: 'Govt Small Savings (India)',
  subtitle: 'Sovereign EEE & Fixed Guaranteed Yields',
  icon: Icons.account_balance_rounded,
  color: const Color(0xFF10B981),
  subGroups: [
    EduSubGroup(
      groupName: '1. Family & Retirement Sovereign Anchors',
      groupTag: 'Triple Tax-Exempt (EEE)',
      icon: Icons.family_restroom_rounded,
      nodes: [
        EduLeafNode(
          title: 'Sukanya Samriddhi Yojana (SSY)',
          badge: 'Girl Child (< 10 Yrs)',
          rateOrRule: '8.20% p.a. (Govt Guaranteed)',
          taxSection: 'Sec 80C + EEE (100% Tax Free)',
          lockIn: '21 Years / Marriage after 18',
          shortSummary:
              'Highest sovereign fixed-rate guaranteed return among all government small savings schemes in India.',
          deepExplanation:
              '• **Eligibility:** Girl child below 10 years of age (Max 2 accounts per family).\n'
              '• **Deposit Range:** Minimum ₹250 to Maximum ₹1.5 Lakhs per financial year.\n'
              '• **Tax Treatment:** Exempt-Exempt-Exempt (EEE). No tax on deposit, interest compounding, or maturity.',
          sampleInvestment: '₹1.5 Lakh / yr (15 Yrs)',
          sampleTenure: '21 Years Maturity',
          sampleExpectedReturn: '8.20% p.a.',
          sampleMaturityValue: '₹71.8 Lakhs (Total Invested: ₹22.5L)',
          metrics: [
            {'label': 'Sovereign Risk', 'val': '0.00%'},
            {'label': 'Annual Ceiling', 'val': '₹1.5 Lakhs'},
            {'label': 'Compounding', 'val': 'Annual'},
          ],
        ),
        EduLeafNode(
          title: 'Public Provident Fund (PPF)',
          badge: 'Universal Sovereign',
          rateOrRule: '7.10% p.a. Compounded Annually',
          taxSection: 'Sec 80C + EEE (Tax Free)',
          lockIn: '15 Years (Partial at Yr 7)',
          shortSummary:
              'Core sovereign wealth anchor with zero default risk and complete tax immunity.',
          deepExplanation:
              '• **Lock-in Period:** 15 financial years. Extendable indefinitely in 5-year blocks with or without contributions.\n'
              '• **Partial Liquidity:** Partial withdrawals permitted starting from the 7th financial year.\n'
              '• **Asset Protection:** Funds in a PPF account cannot be attached by any court decree or creditor claim.',
          sampleInvestment: '₹1.5 Lakh / yr (15 Yrs)',
          sampleTenure: '15 Years',
          sampleExpectedReturn: '7.10% p.a.',
          sampleMaturityValue: '₹40.68 Lakhs (Total Invested: ₹22.5L)',
          metrics: [
            {'label': 'Tenure Block', 'val': '15 + 5 Yrs'},
            {'label': 'Min Deposit', 'val': '₹500 / FY'},
            {'label': 'Max Deposit', 'val': '₹1.5 Lakhs'},
          ],
        ),
        EduLeafNode(
          title: 'Senior Citizen Savings Scheme (SCSS)',
          badge: 'Retirees (60+ Yrs)',
          rateOrRule: '8.20% p.a. (Paid Quarterly)',
          taxSection: 'Sec 80C Eligible (Interest Taxable)',
          lockIn: '5 Years (+3 Year Extension)',
          shortSummary:
              'Quarterly pension-like liquidity for retirees backed by sovereign guarantee.',
          deepExplanation:
              '• **Eligibility:** Individuals aged 60+ (or 55+ for VRS opt-outs).\n'
              '• **Investment Limit:** Up to ₹30 Lakhs across post offices and scheduled commercial banks.\n'
              '• **Taxation:** Principal qualifies for Sec 80C; interest is taxable at individual slab rate.',
          sampleInvestment: '₹30.0 Lakhs (Max Cap)',
          sampleTenure: '5 Years',
          sampleExpectedReturn: '8.20% p.a.',
          sampleMaturityValue: '₹61,500 / quarter (₹12.3L total income)',
          metrics: [
            {'label': 'Payout Mode', 'val': 'Quarterly'},
            {'label': 'Max Allocation', 'val': '₹30 Lakhs'},
            {'label': 'Lock-in', 'val': '5 Years'},
          ],
        ),
      ],
    ),
    EduSubGroup(
      groupName: '2. Post Office Savings Certificates',
      groupTag: 'Guaranteed Returns',
      icon: Icons.markunread_mailbox_rounded,
      nodes: [
        EduLeafNode(
          title: 'Mahila Samman Savings Certificate',
          badge: 'Women & Girls',
          rateOrRule: '7.50% p.a. Compounded Quarterly',
          taxSection: 'TDS Exempt (Slab Taxable)',
          lockIn: '2 Years Fixed',
          shortSummary:
              'Sovereign short-term capital preservation certificate specifically for women.',
          deepExplanation:
              '• **Tenure:** Exactly 2 years from date of deposit.\n'
              '• **Deposit Cap:** Maximum ₹2 Lakhs per individual.\n'
              '• **Partial Exit:** Up to 40% of the balance can be withdrawn after 1 year.',
          sampleInvestment: '₹2.0 Lakhs (Max Cap)',
          sampleTenure: '2 Years',
          sampleExpectedReturn: '7.50% p.a.',
          sampleMaturityValue: '₹2,32,044 at maturity',
          metrics: [
            {'label': 'Tenure', 'val': '2 Years'},
            {'label': 'Max Cap', 'val': '₹2.0 Lakhs'},
            {'label': 'Compounding', 'val': 'Quarterly'},
          ],
        ),
        EduLeafNode(
          title: 'Kisan Vikas Patra (KVP)',
          badge: 'Capital Doubler',
          rateOrRule: 'Doubles Money in 115 Months',
          taxSection: 'Taxable at Slab Rate',
          lockIn: '115 Months (Exit after 2.5 Yrs)',
          shortSummary:
              'Government guaranteed principal doubling certificate with loan pledging collateral status.',
          deepExplanation:
              '• **Doubling Time:** 115 months (9 years 7 months) at 7.50% effective yield.\n'
              '• **Collateral Value:** Easily pledged across Indian banks to secure low-interest overdraft limits.\n'
              '• **Premature Redemption:** Permitted after 2.5 years without loss of accrued yield.',
          sampleInvestment: '₹5.0 Lakhs Outlay',
          sampleTenure: '115 Months (9.6 Yrs)',
          sampleExpectedReturn: '7.50% p.a.',
          sampleMaturityValue: '₹10.00 Lakhs Guaranteed',
          metrics: [
            {'label': 'Effective Yield', 'val': '7.50% p.a.'},
            {'label': 'Doubling Rule', 'val': '2x Principal'},
            {'label': 'Min Deposit', 'val': '₹1,000'},
          ],
        ),
        EduLeafNode(
          title: 'National Savings Certificate (NSC VIII)',
          badge: '5-Year Sovereign',
          rateOrRule: '7.70% p.a. Annual Compounding',
          taxSection: 'Sec 80C Deemed Reinvestment',
          lockIn: '5 Years Fixed',
          shortSummary:
              'Fixed 5-year post office certificate with automatic Section 80C reinvestment benefits.',
          deepExplanation:
              '• **Automatic Tax Shield:** Interest accrued in Years 1–4 is deemed reinvested and automatically qualifies for Section 80C deduction.',
          sampleInvestment: '₹1.0 Lakh Outlay',
          sampleTenure: '5 Years',
          sampleExpectedReturn: '7.70% p.a.',
          sampleMaturityValue: '₹1,44,903 at maturity',
          metrics: [
            {'label': 'Lock-in', 'val': '5 Years'},
            {'label': 'Reinvestment', 'val': 'Sec 80C Y1-Y4'},
            {'label': 'Risk Profile', 'val': 'Zero SOV'},
          ],
        ),
      ],
    ),
  ],
);
