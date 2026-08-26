import 'package:flutter/material.dart';

class AssetItem {
  String name;
  String category;
  double currentValue;
  double monthlySip;
  double expectedReturn;
  IconData icon;
  Color accentColor;
  String tooltip;

  AssetItem({
    required this.name,
    required this.category,
    required this.currentValue,
    required this.monthlySip,
    required this.expectedReturn,
    required this.icon,
    required this.accentColor,
    required this.tooltip,
  });
}

class DebtItem {
  String name;
  String type;
  double outstandingPrincipal;
  double interestRate;
  double monthlyEmi;

  DebtItem({
    required this.name,
    required this.type,
    required this.outstandingPrincipal,
    required this.interestRate,
    required this.monthlyEmi,
  });
}

class PortfolioSampleData {
  static List<AssetItem> getDefaultAssets() {
    return [
      AssetItem(
        name: 'Flexi & Large Cap MFs',
        category: 'Equity Funds',
        currentValue: 1850000,
        monthlySip: 35000,
        expectedReturn: 14.0,
        icon: Icons.trending_up,
        accentColor: const Color(0xFF10B981),
        tooltip: 'Market-linked mutual funds for inflation-beating growth.',
      ),
      AssetItem(
        name: 'Mid & Small Cap MFs',
        category: 'Alpha Growth',
        currentValue: 950000,
        monthlySip: 15000,
        expectedReturn: 16.0,
        icon: Icons.rocket_launch_outlined,
        accentColor: const Color(0xFF38BDF8),
        tooltip: 'High growth mid/small cap funds for capital compounding.',
      ),
      AssetItem(
        name: 'Public Provident Fund (PPF)',
        category: 'Govt EEE Scheme',
        currentValue: 850000,
        monthlySip: 12500,
        expectedReturn: 7.1,
        icon: Icons.verified_user_outlined,
        accentColor: const Color(0xFF818CF8),
        tooltip: '15-year sovereign-backed 100% tax-free asset.',
      ),
      AssetItem(
        name: 'National Pension System (NPS)',
        category: 'Tier-I Pension',
        currentValue: 1250000,
        monthlySip: 10000,
        expectedReturn: 10.5,
        icon: Icons.account_balance_outlined,
        accentColor: const Color(0xFFF59E0B),
        tooltip: 'Low-cost retirement pension combining debt and equities.',
      ),
      AssetItem(
        name: 'Provident Fund (EPF/VPF)',
        category: 'Retirement Fixed',
        currentValue: 1600000,
        monthlySip: 18000,
        expectedReturn: 8.25,
        icon: Icons.assured_workload_outlined,
        accentColor: const Color(0xFF34D399),
        tooltip: 'Sovereign guaranteed retirement debt yielding ~8.25% p.a.',
      ),
      AssetItem(
        name: 'Emergency Liquid Reserve',
        category: 'Instant Cash',
        currentValue: 770000,
        monthlySip: 0,
        expectedReturn: 6.8,
        icon: Icons.savings_outlined,
        accentColor: const Color(0xFFA78BFA),
        tooltip:
            'Instant-access liquid buffer covering household emergency needs.',
      ),
    ];
  }

  static List<DebtItem> getDefaultDebts() {
    return [
      DebtItem(
        name: 'Primary Home Loan',
        type: 'Secured Housing Loan',
        outstandingPrincipal: 2450000,
        interestRate: 8.50,
        monthlyEmi: 28500,
      ),
      DebtItem(
        name: 'Vehicle / Auto Loan',
        type: 'Fixed Term Loan',
        outstandingPrincipal: 480000,
        interestRate: 9.10,
        monthlyEmi: 14200,
      ),
    ];
  }
}
