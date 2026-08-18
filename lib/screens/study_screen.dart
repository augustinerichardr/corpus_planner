import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/financial_versus_card.dart';

class StudyScreen extends StatefulWidget {
  final Function(
    double equity,
    double debt,
    double sip,
    double stepUp,
    int years,
  )?
  onApplyStrategy;
  final VoidCallback? onNavigateToPlanner;

  const StudyScreen({
    super.key,
    this.onApplyStrategy,
    this.onNavigateToPlanner,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
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
      appBar: DashboardAppBar(
        title: 'Financial Knowledge & Decision Hub',
        onCountryChanged: (_) {},
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1E293B),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF10B981),
              labelColor: const Color(0xFF10B981),
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.compare_arrows), text: 'Versus Showdowns'),
                Tab(
                  icon: Icon(Icons.account_balance_outlined),
                  text: 'India Schemes (PPF, NPS, SSY)',
                ),
                Tab(
                  icon: Icon(Icons.pie_chart_outline),
                  text: 'Equity & Asset Classes',
                ),
                Tab(
                  icon: Icon(Icons.money_off_csred_outlined),
                  text: 'Debts, EMIs & Loans',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVersusTab(),
                _buildIndiaSchemesTab(),
                _buildEquityClassesTab(),
                _buildDebtsAndLoansTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: VERSUS SHOWDOWNS
  Widget _buildVersusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Key Financial Dilemmas (Quick Decisions)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          FinancialVersusCard(
            title: '15-Year Wealth: PPF vs. Equity ELSS Fund (₹1.5L / Year)',
            optionAName: 'Public Provident Fund (PPF)',
            optionAValue: '₹40.7 Lakhs (7.1% Tax-Free)',
            optionBName: 'Equity Mutual Fund (ELSS)',
            optionBValue: '₹84.3 Lakhs (13.5% Post-Tax)',
            metricLabel: 'Terminal Value',
            takeaway:
                'ELSS generates over 2x higher terminal wealth over 15 years with a shorter lock-in (3 yrs vs 15 yrs).',
          ),
          FinancialVersusCard(
            title:
                'Insurance Choice: ₹1 Cr Term Insurance + SIP vs. Traditional LIC Endowment',
            optionAName: 'LIC Endowment Policy',
            optionAValue: '₹38 Lakhs Return + ₹10L Cover',
            optionBName: 'Term Plan + Equity SIP',
            optionBValue: '₹1.15 Cr Wealth + ₹1 Cr Cover',
            metricLabel: '30-Year Wealth + Protection',
            takeaway:
                'Never mix insurance with investment. Term insurance gives 10x cover at 1/10th cost, leaving surplus for compounding SIPs.',
            accentColor: Color(0xFF38BDF8),
          ),
          FinancialVersusCard(
            title:
                'Cash Strategy: Extra ₹10,000/mo into Home Loan Prepayment vs. Index SIP',
            optionAName: 'Home Loan Prepayment (8.5%)',
            optionAValue: 'Saves ₹22.4L Interest',
            optionBName: 'Nifty 50 Equity SIP (13%)',
            optionBValue: 'Creates ₹70.2L Corpus',
            metricLabel: '15-Year Financial Arbitrage',
            takeaway:
                'Investing surplus cash in equities beats 8.5% loan interest by a net +4.5% annual arbitrage margin.',
            accentColor: Color(0xFFA855F7),
          ),
          FinancialVersusCard(
            title:
                'Fixed Deposit (FD) vs. Arbitrage / Liquid Mutual Funds (30% Tax Slab)',
            optionAName: 'Bank Fixed Deposit (7.25%)',
            optionAValue: '5.07% Net Post-Tax Return',
            optionBName: 'Arbitrage Fund (7.0%)',
            optionBValue: '6.12% Net Post-Tax Return',
            metricLabel: 'Post-Tax Efficiency',
            takeaway:
                'Arbitrage funds are taxed as equity (12.5% LTCG after 1 yr) rather than your personal 30% slab rate.',
            accentColor: Colors.amberAccent,
          ),
        ],
      ),
    );
  }

  // TAB 2: INDIA SCHEMES
  Widget _buildIndiaSchemesTab() {
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
          _cheatCard(
            title: 'Public Provident Fund (PPF)',
            categoryBadge: '15-Yr Sovereign Lock-in',
            taxBadge: 'EEE (100% Tax Free)',
            returnRate: '7.1% p.a. (Govt Revised)',
            riskBadge: 'Zero Risk (Sovereign)',
            bullets: [
              'Annual limit: ₹500 minimum to ₹1.5 Lakh maximum per financial year.',
              '15-year maturity; partial withdrawals permitted from the 7th financial year.',
              'Extendable indefinitely in 5-year blocks with or without fresh contributions.',
            ],
            accentColor: const Color(0xFF10B981),
          ),
          _cheatCard(
            title: 'National Pension System (NPS Tier-I)',
            categoryBadge: 'Retirement (Age 60)',
            taxBadge: '80CCD(1B) Extra ₹50K',
            returnRate: '10% – 12% Market Linked',
            riskBadge: 'Low-to-Moderate Risk',
            bullets: [
              'Active Choice lets you allocate up to 75% in Equities (E) and remainder in Debt (C & G).',
              'At age 60, 60% of the corpus is 100% tax-free lump sum; 40% converts to monthly annuity pension.',
              'Corporate model provides up to 10% employer basic salary deduction without limits.',
            ],
            accentColor: const Color(0xFF38BDF8),
          ),
          _cheatCard(
            title: 'Sukanya Samriddhi Yojana (SSY)',
            categoryBadge: 'Girl Child (< 10 Yrs)',
            taxBadge: 'EEE (100% Tax Free)',
            returnRate: '8.2% p.a. (Highest Fixed Yield)',
            riskBadge: 'Zero Risk (Govt Backed)',
            bullets: [
              'Highest sovereign fixed-rate guaranteed return among all government small savings schemes.',
              'Deposits allowed for 15 years; account matures after 21 years or upon marriage after age 18.',
              'Max ₹1.5 Lakh per year eligible under Section 80C.',
            ],
            accentColor: const Color(0xFFA855F7),
          ),
          _cheatCard(
            title: 'Employee Provident Fund (EPF / VPF)',
            categoryBadge: 'Salaried Employees',
            taxBadge: 'Tax Free up to ₹2.5L/yr',
            returnRate: '8.25% p.a.',
            riskBadge: 'Zero Risk (Govt Managed)',
            bullets: [
              '12% of basic + DA contributed by employee with matching employer contribution.',
              'Voluntary Provident Fund (VPF) allows investing above 12% basic at the same high 8.25% yield.',
              'Interest is tax-exempt if total annual employee contribution does not exceed ₹2.5 Lakh.',
            ],
            accentColor: Colors.amberAccent,
          ),
        ],
      ),
    );
  }

  // TAB 3: EQUITY & ASSET CLASSES
  Widget _buildEquityClassesTab() {
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
          _cheatCard(
            title: 'Large Cap Mutual Funds',
            categoryBadge: 'Top 100 Companies',
            taxBadge: '12.5% LTCG (> ₹1.25L)',
            returnRate: '12% – 14% Expected CAGR',
            riskBadge: 'Moderate Volatility',
            bullets: [
              'Invests in mature industry leaders (Reliance, TCS, HDFC Bank, Infosys).',
              'Provides core portfolio stability and lowest downside drawdowns during market corrections.',
            ],
            accentColor: const Color(0xFF10B981),
          ),
          _cheatCard(
            title: 'Mid Cap Mutual Funds',
            categoryBadge: 'Rank 101 to 250',
            taxBadge: '12.5% LTCG (> ₹1.25L)',
            returnRate: '15% – 18% Expected CAGR',
            riskBadge: 'High Volatility',
            bullets: [
              'High-growth emerging businesses transitioning into tomorrow\'s large caps.',
              'Requires a minimum 5 to 7 year investment horizon to ride out economic cycles.',
            ],
            accentColor: const Color(0xFF38BDF8),
          ),
          _cheatCard(
            title: 'Small Cap Mutual Funds',
            categoryBadge: 'Rank 251 and Beyond',
            taxBadge: '12.5% LTCG (> ₹1.25L)',
            returnRate: '18% – 22% Expected CAGR',
            riskBadge: 'Very High Volatility',
            bullets: [
              'High alpha generation and multi-bagger potential; prone to 30%–40% sharp drawdowns.',
              'Best accumulated strictly via systematic SIPs over a 7+ year timeframe.',
            ],
            accentColor: const Color(0xFFEF4444),
          ),
          _cheatCard(
            title: 'Flexi Cap & Multi-Asset Funds',
            categoryBadge: 'Dynamic Asset Allocation',
            taxBadge: 'Equity Tax Rules',
            returnRate: '12% – 15% Expected CAGR',
            riskBadge: 'All-Weather Protection',
            bullets: [
              'Flexi Cap grants complete fund manager freedom to allocate across Large, Mid, and Small caps.',
              'Multi-Asset funds combine Equity + Debt + Gold to cushion market corrections.',
            ],
            accentColor: const Color(0xFFA855F7),
          ),
        ],
      ),
    );
  }

  // TAB 4: DEBTS & LOANS
  Widget _buildDebtsAndLoansTab() {
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
          _cheatCard(
            title: 'Home Loans (Mortgage)',
            categoryBadge: 'Collateralized Long-Term',
            taxBadge: 'Sec 80C & Sec 24(b) (Old)',
            returnRate: '8.25% – 9.50% Floating Rate',
            riskBadge: 'Lowest Borrowing Cost',
            bullets: [
              'Longest amortizing liability (15–30 yrs). Interest rate is floating and linked to RBI repo rate.',
              'Old Tax Regime allows up to ₹2L interest deduction (Sec 24b) and ₹1.5L principal (Sec 80C).',
            ],
            accentColor: const Color(0xFF38BDF8),
          ),
          _cheatCard(
            title: 'Personal Loans & Credit Card Debt',
            categoryBadge: 'Unsecured High-Cost',
            taxBadge: 'Zero Tax Benefit',
            returnRate: '12.0% – 36.0%+ p.a.',
            riskBadge: 'Severe Wealth Destroyer',
            bullets: [
              'Top priority for immediate prepayment via the Debt Avalanche method.',
              'Carrying credit card balances compounds daily interest, negating any investment gains.',
            ],
            accentColor: const Color(0xFFEF4444),
          ),
          _cheatCard(
            title: 'The "EMI Unlock" Wealth Multiplier',
            categoryBadge: 'Strategic Framework',
            taxBadge: 'Compounding Booster',
            returnRate: 'Redirect EMI ➔ SIP',
            riskBadge: 'High Financial Impact',
            bullets: [
              'When a loan (e.g., Car Loan ₹15,000/mo) is paid off, never absorb that money into lifestyle expenses.',
              'Immediately convert the completed EMI into a monthly SIP to accelerate terminal corpus by ₹30L–₹50L.',
            ],
            accentColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _cheatCard({
    required String title,
    required String categoryBadge,
    required String taxBadge,
    required String returnRate,
    required String riskBadge,
    required List<String> bullets,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withOpacity(0.4)),
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
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: accentColor.withOpacity(0.5)),
                ),
                child: Text(
                  categoryBadge,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _pill(taxBadge, const Color(0xFF38BDF8)),
              const SizedBox(width: 6),
              _pill(returnRate, const Color(0xFF10B981)),
              const SizedBox(width: 6),
              _pill(riskBadge, Colors.orangeAccent),
            ],
          ),
          const Divider(color: Colors.white10, height: 16),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
