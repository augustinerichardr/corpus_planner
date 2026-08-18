class AiAdvisorService {
  static Future<String> askFinancialAdvisor({
    required String userQuery,
    required double currentCorpus,
    required double monthlySip,
    required double equityAllocation,
    required double debtAllocation,
    required double inflationRate,
    required String countryCurrency,
  }) async {
    // Simulate brief processing latency for realistic UX
    await Future.delayed(const Duration(milliseconds: 300));

    final q = userQuery.toLowerCase();

    // 1. Allocation & Diversification Queries
    if (q.contains('allocate') ||
        q.contains('allocation') ||
        q.contains('large') ||
        q.contains('mid') ||
        q.contains('small')) {
      return "Based on your active ${equityAllocation.toInt()}% Equity and ${debtAllocation.toInt()}% Debt split:\n\n"
          "• Core Stability (Large Cap / Flexi Cap): 50% of equity allocation for steady index compounding.\n"
          "• Growth Acceleration (Mid Cap): 30% of equity allocation for high earnings growth.\n"
          "• Alpha Booster (Small Cap): 20% of equity allocation for 7+ year multi-bagger potential.\n\n"
          "With your current $countryCurrency ${monthlySip.toStringAsFixed(0)} monthly SIP, rebalance annually to protect capital gains.";
    }

    // 2. Taxation & LTCG Queries
    if (q.contains('tax') ||
        q.contains('ltcg') ||
        q.contains('stcg') ||
        q.contains('capital gain')) {
      return "Under current Indian tax provisions for Equity Mutual Funds:\n\n"
          "• Long-Term Capital Gains (LTCG): Gains realized after holding for > 12 months are taxed at 12.5% on gains exceeding ₹1.25 Lakh per financial year.\n"
          "• Short-Term Capital Gains (STCG): Units sold within 12 months are taxed at 20% flat.\n"
          "• Debt Mutual Funds: Taxed according to your individual income tax slab.\n\n"
          "Strategy: Stagger redemptions across multiple financial years to maximize the ₹1.25 Lakh annual LTCG exemption window.";
    }

    // 3. SWP & Retirement Sustainability
    if (q.contains('swp') ||
        q.contains('withdraw') ||
        q.contains('sustainable') ||
        q.contains('retire')) {
      const safeAnnualRate = 0.04;
      final safeMonthlyIncome = (currentCorpus * safeAnnualRate) / 12;
      return "For an inflation-adjusted retirement with an assumed ${inflationRate.toStringAsFixed(1)}% annual inflation:\n\n"
          "• 4% Safe Withdrawal Rule: A conservative starting withdrawal rate of 4% annually ($countryCurrency ${safeMonthlyIncome.toStringAsFixed(0)}/month) preserves principal for 25+ years.\n"
          "• Sequence of Returns Protection: Maintain a 3-year living expense buffer in Liquid/Debt funds to avoid liquidating equity during market corrections.\n"
          "• Asset Rebalancing: Keep at least 30–40% in equity to outpace inflation erosion over a multi-decade horizon.";
    }

    // 4. Step-Up Compounding Queries
    if (q.contains('step up') ||
        q.contains('step-up') ||
        q.contains('increase sip') ||
        q.contains('lump sum')) {
      return "The Power of Annual Step-Up Compounding:\n\n"
          "• A 10% annual increase on your $countryCurrency ${monthlySip.toStringAsFixed(0)} SIP doubles your terminal corpus compared to a flat SIP over a 15-year horizon.\n"
          "• Align step-up adjustments with annual salary increments or business profit expansions to minimize lifestyle inflation.";
    }

    // Default Fallback Analysis
    return "Portfolio Summary Analysis:\n\n"
        "• Projected Gross Value: $countryCurrency ${currentCorpus.toStringAsFixed(0)}\n"
        "• Target Asset Split: ${equityAllocation.toInt()}% Equity | ${debtAllocation.toInt()}% Debt\n"
        "• Inflation Assumption: ${inflationRate.toStringAsFixed(1)}% p.a.\n\n"
        "Key Recommendation: Maintain disciplined monthly SIP allocations, increase contributions annually by 10%, and let compounding work over a 5+ year timeframe.";
  }
}
