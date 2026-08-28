import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF38BDF8),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Financial Knowledge Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send Feedback',
                    icon: const Icon(
                      Icons.feedback_rounded,
                      color: Color(0xFF38BDF8),
                      size: 20,
                    ),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const TextFeedbackDialog(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: const Color(0xFF1E293B),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: const Color(0xFF10B981),
                indicatorWeight: 3,
                labelColor: const Color(0xFF10B981),
                unselectedLabelColor: const Color(0xFF94A3B8),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.compare_arrows_rounded, size: 18),
                    text: 'Versus',
                  ),
                  Tab(
                    icon: Icon(Icons.account_balance_rounded, size: 18),
                    text: 'India Schemes',
                  ),
                  Tab(
                    icon: Icon(Icons.pie_chart_outline_rounded, size: 18),
                    text: 'Equity',
                  ),
                  Tab(
                    icon: Icon(Icons.credit_card_rounded, size: 18),
                    text: 'Debts & EMI',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildList('Strategy Showdowns', [
                    _cardData(
                      'SIP vs. Lump Sum',
                      'Timing Risk',
                      'Rupee Cost Averaging Advantage',
                      [
                        'SIP eliminates emotional market timing by averaging market swings over cycles.',
                        'Outperforms lump sum deployments during volatile and downward market regimes.',
                        'Annual Step-Up SIP significantly accelerates terminal wealth compounding.',
                      ],
                    ),
                    _cardData(
                      'Active vs. Index Funds',
                      'Expense Alpha',
                      'Nifty 50 Index vs. Active Large Cap',
                      [
                        'Over 85% of active large-cap funds fail to consistently outperform their benchmark.',
                        'Ultra-low expense ratios (TER < 0.2%) compound greater net wealth over 15+ years.',
                      ],
                    ),
                  ]),
                  _buildList('Government & Retirement Vehicles', [
                    _cardData(
                      'Public Provident Fund (PPF)',
                      '15-Yr Lock-In',
                      '7.1% p.a. (Govt Revised)',
                      [
                        'Annual limit: ₹500 minimum to ₹1.5 Lakh maximum per financial year.',
                        '15-year maturity; partial withdrawals permitted from the 7th financial year.',
                        'EEE tax status: Principal, accrued interest, and maturity sum are 100% tax-exempt.',
                      ],
                    ),
                    _cardData(
                      'National Pension System (NPS)',
                      'Age 60 Maturity',
                      '10% – 12% Market Linked',
                      [
                        'Section 80CCD(1B) provides an exclusive ₹50,000 tax deduction above the 80C limit.',
                        'Active Choice permits up to 75% equity allocation (E) with corporate/govt debt.',
                        'At age 60, 60% corpus is a tax-free lump sum; 40% converts to mandatory monthly annuity.',
                      ],
                    ),
                    _cardData(
                      'Sukanya Samriddhi Yojana (SSY)',
                      'Girl Child (< 10 Yrs)',
                      '8.2% p.a. Guaranteed',
                      [
                        'Highest guaranteed sovereign return among all small savings instruments.',
                        '15-year deposit tenure; matures in 21 years or upon marriage after age 18.',
                        'Complete EEE tax-exempt status.',
                      ],
                    ),
                  ]),
                  _buildList('Equity & Asset Allocation', [
                    _cardData(
                      'Large Cap Index Funds',
                      'Core Stability',
                      'Top 100 Bluechip Indian Enterprises',
                      [
                        'Forms the resilient core of long-term wealth compounding portfolios.',
                        'Delivers consistent dividend reinvestment with moderate market volatility.',
                      ],
                    ),
                    _cardData(
                      'Flexi-Cap Mutual Funds',
                      'Dynamic Growth',
                      'Large, Mid & Small Cap Blend',
                      [
                        'Fund manager actively rotates capital into high-growth emerging sectors.',
                        'Recommended equity vehicle for investment horizons exceeding 7 to 10+ years.',
                      ],
                    ),
                  ]),
                  _buildList('Liabilities & Payoff Frameworks', [
                    _cardData(
                      'Home Loans (Mortgages)',
                      'Low Borrowing Cost',
                      '8.25% – 9.50% Floating Rate',
                      [
                        'Amortizes over 15–30 years; floating interest rate pegged to the RBI repo rate.',
                        'Tax deductions available on interest (Sec 24b) and principal repayment (Sec 80C).',
                      ],
                    ),
                    _cardData(
                      'Personal Loans & Credit Cards',
                      'Wealth Destroyer',
                      '12.0% – 36.0%+ p.a.',
                      [
                        'Must be repaid immediately using the Debt Avalanche payoff method.',
                        'High compounding daily interest rapidly erodes all portfolio capital gains.',
                      ],
                      isWarn: true,
                    ),
                    _cardData(
                      'The "EMI Unlock" Multiplier',
                      'Core Strategy',
                      'Redirect Finished EMI → SIP',
                      [
                        'When any loan ends, avoid absorbing that free cashflow into lifestyle expenses.',
                        'Immediately channel the finished EMI into an equity SIP to build ₹30L–₹50L extra corpus.',
                      ],
                      isAccent: true,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _cardData(
    String title,
    String badge,
    String sub,
    List<String> b, {
    bool isWarn = false,
    bool isAccent = false,
  }) =>
      {
        'title': title,
        'badge': badge,
        'sub': sub,
        'bullets': b,
        'warn': isWarn,
        'accent': isAccent,
      };

  Widget _buildList(String header, List<Map<String, dynamic>> cards) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        Text(
          header,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...cards.map((c) => _buildCard(c)),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> c) {
    final isWarn = c['warn'] as bool;
    final isAccent = c['accent'] as bool;
    final border = isWarn
        ? const Color(0xFFEF4444).withValues(alpha: 0.4)
        : (isAccent
            ? const Color(0xFF10B981).withValues(alpha: 0.4)
            : const Color(0xFF38BDF8).withValues(alpha: 0.3));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  c['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: (isWarn ? Colors.red : const Color(0xFF0EA5E9))
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  c['badge'],
                  style: TextStyle(
                    color: isWarn
                        ? const Color(0xFFF87171)
                        : const Color(0xFF38BDF8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            c['sub'],
            style: TextStyle(
              color: isWarn ? const Color(0xFFF87171) : const Color(0xFF38BDF8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(color: Color(0xFF334155), height: 16),
          ...(c['bullets'] as List<String>).map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                  Expanded(
                    child: Text(
                      b,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                        height: 1.35,
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
}

// ---------------------------------------------------------
// TEXT FEEDBACK MODAL
// ---------------------------------------------------------
class TextFeedbackDialog extends StatefulWidget {
  const TextFeedbackDialog({super.key});
  @override
  State<TextFeedbackDialog> createState() => _TextFeedbackDialogState();
}

class _TextFeedbackDialogState extends State<TextFeedbackDialog> {
  final _msgCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isSending = false;

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final msg = _msgCtrl.text.trim();
    if (msg.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email and feedback message.'),
        ),
      );
      return;
    }
    setState(() => _isSending = true);
    try {
      final res = await http.post(
        Uri.parse('https://formspree.io/f/xrpzjppr'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'message': msg}),
      );
      if (res.statusCode >= 200 && res.statusCode < 300 && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Feedback dispatched!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        return;
      }
    } catch (_) {}
    final mail = Uri.parse(
      'mailto:ganymedeearth24@gmail.com?subject=Feedback&body=${Uri.encodeComponent(msg)}',
    );
    if (await canLaunchUrl(mail)) await launchUrl(mail);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text(
        'Send Feedback',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _msgCtrl,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Enter your feedback or suggestions...',
                hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                filled: true,
                fillColor: Color(0xFF0F172A),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Your email for direct reply',
                hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                filled: true,
                fillColor: Color(0xFF0F172A),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.black,
          ),
          child: _isSending
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send'),
        ),
      ],
    );
  }
}
