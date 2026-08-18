import 'package:flutter/material.dart';
import '../widgets/dashboard_app_bar.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: const DashboardAppBar(
        title: 'Financial Knowledge & Decision Hub',
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1E293B),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFF10B981),
              labelColor: const Color(0xFF10B981),
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.compare_arrows), text: 'Versus Showdowns'),
                Tab(
                  icon: Icon(Icons.account_balance),
                  text: 'India Schemes (PPF, NPS, SSY)',
                ),
                Tab(
                  icon: Icon(Icons.pie_chart),
                  text: 'Equity & Asset Classes',
                ),
                Tab(
                  icon: Icon(Icons.credit_card),
                  text: 'Debts, EMIs & Payoff Frameworks',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVersusShowdownsTab(),
                _buildGovernmentSchemesTab(),
                _buildEquityAssetClassesTab(),
                _buildDebtsAndEmisTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersusShowdownsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Financial Dilemmas (Quick Decisions)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _showdownCard(
            title: '15-Year Wealth: PPF vs. Equity ELSS Fund (₹1.5L / Year)',
            optAName: 'Public Provident Fund (PPF)',
            optAVal: '₹40.7 Lakhs (7.1% Tax-Free)',
            optBName: 'Equity Mutual Fund (ELSS)',
            optBVal: '₹84.3 Lakhs (13.5% Post-Tax)',
            verdict:
                'ELSS generates over 2x higher terminal wealth over 15 years with a shorter lock-in (3 yrs vs 15 yrs).',
          ),
          _showdownCard(
            title:
                'Insurance Choice: ₹1 Cr Term Insurance + SIP vs. Traditional LIC Endowment',
            optAName: 'LIC Endowment Policy',
            optAVal: '₹38 Lakhs Return + ₹10L Cover',
            optBName: 'Term Plan + Equity SIP',
            optBVal: '₹1.15 Cr Wealth + ₹1 Cr Cover',
            verdict:
                'Never mix insurance with investment. Term insurance gives 10x cover at 1/10th cost, leaving surplus for compounding SIPs.',
          ),
          _showdownCard(
            title:
                'Cash Strategy: Extra ₹10,000/mo into Home Loan Prepayment vs. Index SIP',
            optAName: 'Home Loan Prepayment (8.5%)',
            optAVal: 'Saves ₹22.4L Interest',
            optBName: 'Nifty 50 Equity SIP (13%)',
            optBVal: 'Creates ₹70.2L Corpus',
            verdict:
                'Investing surplus cash in equities beats 8.5% loan interest by a net +4.5% annual arbitrage margin.',
          ),
        ],
      ),
    );
  }

  Widget _buildGovernmentSchemesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Government & Retirement Vehicles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _schemeInfoCard(
            'Public Provident Fund (PPF)',
            '7.1% p.a. (Govt Revised)',
            '15-Yr Sovereign Lock-in',
            '• Annual limit: ₹500 minimum to ₹1.5 Lakh maximum per financial year.\n• 15-year maturity; partial withdrawals permitted from the 7th financial year.\n• EEE (Exempt-Exempt-Exempt) status: Investment, interest earned, and maturity proceeds are 100% tax-free.',
            const Color(0xFF38BDF8),
          ),
          _schemeInfoCard(
            'National Pension System (NPS Tier-I)',
            '10% – 12% Market Linked',
            'Retirement (Age 60)',
            '• Section 80CCD(1B) provides an exclusive ₹50,000 deduction above the ₹1.5L 80C limit.\n• Active Choice lets you allocate up to 75% in Equities (E) and remainder in Debt (C & G).\n• At age 60, 60% of the corpus is 100% tax-free lump sum; 40% converts to monthly annuity pension.',
            const Color(0xFF10B981),
          ),
          _schemeInfoCard(
            'Sukanya Samriddhi Yojana (SSY)',
            '8.2% p.a. (Highest Fixed Yield)',
            'Girl Child (< 10 Yrs)',
            '• Highest sovereign fixed-rate guaranteed return among all government small savings schemes.\n• Deposits allowed for 15 years; account matures after 21 years or upon marriage after age 18.\n• EEE tax-exempt status.',
            const Color(0xFFA855F7),
          ),
        ],
      ),
    );
  }

  Widget _buildEquityAssetClassesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SEBI Equity Categorization & Risk Styles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _assetClassCard(
            'Large Cap Mutual Funds',
            'Top 100 Companies',
            '12% – 14% Expected CAGR',
            'Moderate Volatility',
            '• Invests in mature industry leaders (Reliance, TCS, HDFC Bank, Infosys).\n• Provides core portfolio stability and lowest downside drawdowns during market corrections.',
            const Color(0xFF10B981),
          ),
          _assetClassCard(
            'Mid Cap Mutual Funds',
            'Rank 101 to 250',
            '15% – 18% Expected CAGR',
            'High Volatility',
            '• High-growth emerging businesses transitioning into tomorrow\'s large caps.\n• Requires a minimum 5 to 7 year investment horizon to ride out economic cycles.',
            const Color(0xFF38BDF8),
          ),
          _assetClassCard(
            'Small Cap Mutual Funds',
            'Rank 251 and Beyond',
            '18% – 22% Expected CAGR',
            'Very High Volatility',
            '• High alpha generation and multi-bagger potential; prone to 30%–40% sharp drawdowns.\n• Best accumulated strictly via systematic SIPs over a 7+ year timeframe.',
            const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtsAndEmisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Liabilities, EMIs & Payoff Frameworks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _debtFrameworkCard(
            'Home Loans (Mortgage)',
            'Collateralized Long-Term',
            '8.25% – 9.50% Floating Rate',
            'Lowest Borrowing Cost',
            '• Longest amortizing liability (15–30 yrs). Interest rate is floating and linked to RBI repo rate.\n• Old Tax Regime allows up to ₹2L interest deduction (Sec 24b) and ₹1.5L principal (Sec 80C).',
            const Color(0xFF38BDF8),
          ),
          _debtFrameworkCard(
            'Personal Loans & Credit Card Debt',
            'Unsecured High-Cost',
            '12.0% – 36.0%+ p.a.',
            'Severe Wealth Destroyer',
            '• Top priority for immediate prepayment via the Debt Avalanche method.\n• Carrying credit card balances compounds daily interest, negating any investment gains.',
            const Color(0xFFEF4444),
          ),
          _debtFrameworkCard(
            'The "EMI Unlock" Wealth Multiplier',
            'Strategic Framework',
            'Redirect EMI → SIP',
            'High Financial Impact',
            '• When a loan (e.g., Car Loan ₹15,000/mo) is paid off, never absorb that money into lifestyle expenses.\n• Immediately convert the completed EMI into a monthly SIP to accelerate terminal corpus by ₹30L–₹50L.',
            const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _showdownCard({
    required String title,
    required String optAName,
    required String optAVal,
    required String optBName,
    required String optBVal,
    required String verdict,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        optAName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        optAVal,
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        optBName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        optBVal,
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Colors.amberAccent,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  verdict,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 10.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _schemeInfoCard(
    String name,
    String returns,
    String lockIn,
    String details,
    Color accent,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  lockIn,
                  style: TextStyle(
                    color: accent,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            returns,
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            details,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _assetClassCard(
    String name,
    String badge,
    String cagr,
    String risk,
    String desc,
    Color accent,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: accent,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                cagr,
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• $risk',
                style: const TextStyle(color: Colors.grey, fontSize: 10.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _debtFrameworkCard(
    String title,
    String badge,
    String rate,
    String status,
    String desc,
    Color accent,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: accent,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                rate,
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• $status',
                style: const TextStyle(color: Colors.grey, fontSize: 10.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
