import 'package:flutter/material.dart';
import '../widgets/dashboard_app_bar.dart';

class AiAdvisorScreen extends StatefulWidget {
  final bool isPaidUser;
  final VoidCallback? onUpgradeToPaid;

  const AiAdvisorScreen({
    super.key,
    this.isPaidUser = false,
    this.onUpgradeToPaid,
  });

  @override
  State<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends State<AiAdvisorScreen> {
  final TextEditingController _queryController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text':
          'Hello! I am your AI Wealth & Investment Advisor. Ask me anything regarding asset allocation, tax optimization, LTCG, SWP sustainability, or mutual fund comparisons.',
    },
  ];

  int _usedDemoPrompts = 0;
  static const int _maxFreePrompts = 2;
  bool _isThinking = false;

  final List<String> _quickPrompts = [
    'How should I allocate ₹50,000 monthly SIP between Large, Mid & Small caps?',
    'Explain the 12.5% LTCG tax rule on mutual funds in India.',
    'Is a 6% SWP withdrawal sustainable for 25 years with 6% inflation?',
    'Should I prepay my home loan or invest in equity mutual funds?',
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _sendQuery(String prompt) {
    final text = prompt.trim();
    if (text.isEmpty) return;

    if (!widget.isPaidUser && _usedDemoPrompts >= _maxFreePrompts) {
      _showUpgradePaywall();
      return;
    }

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      if (!widget.isPaidUser) _usedDemoPrompts++;
      _queryController.clear();
      _isThinking = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isThinking = false;
        _messages.add({
          'sender': 'ai',
          'text': _generateStructuredResponse(text),
        });
      });
    });
  }

  String _generateStructuredResponse(String q) {
    final lower = q.toLowerCase();
    if (lower.contains('allocate') ||
        lower.contains('allocation') ||
        lower.contains('sip')) {
      return '**Recommended 7+ Year Wealth Allocation Plan:**\n\n'
          '• **Large & Flexi-Cap (40%):** Core anchor stability (e.g. Parag Parikh, Bluechip).\n'
          '• **Mid-Cap (30%):** Earnings growth acceleration (101–250 ranking).\n'
          '• **Small-Cap (20%):** Multi-bagger upside with long runway.\n'
          '• **Gold / Debt Liquid (10%):** Volatility shock absorber.\n\n'
          '> **Actionable Rule:** Enforce an annual **10% Step-Up SIP** to beat inflation compounding.';
    } else if (lower.contains('ltcg') || lower.contains('tax')) {
      return '**LTCG Tax Optimization Strategy:**\n\n'
          '• **Holding Period:** > 12 months for equity mutual funds.\n'
          '• **Tax Rate:** 12.5% on gains exceeding ₹1.25 Lakhs per financial year.\n'
          '• **Harvesting Tip:** Redeem and reinvest ₹1.25 Lakhs of gains annually to reset your cost base tax-free.';
    } else if (lower.contains('swp') || lower.contains('sustain')) {
      return '**SWP Longevity & Safe Withdrawal Analysis:**\n\n'
          '• **Initial Safe Withdrawal Rate (SWR):** 4% – 5.5% annually.\n'
          '• **Inflation Cushion:** Maintain a 3-year emergency buffer in liquid debt funds.\n'
          '• **Verdict:** At 6% withdrawal with 6% inflation, portfolio yield must average ≥ 10.5% CAGR to prevent depletion.';
    }
    return '**Portfolio Strategy Recommendation:**\n\n'
        '• Maintain disciplined asset allocation based on your age and risk profile.\n'
        '• Keep 6–12 months living expenses strictly in Liquid Funds/FD.\n'
        '• Avoid timing market corrections; systematic rupee-cost averaging outperforms cash hoarding.';
  }

  void _showUpgradePaywall() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Colors.amberAccent,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'Free Demo Limit Reached',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'You have used your 2 free AI Advisor queries. To continue receiving unlimited, customized portfolio simulations, please upgrade to Pro.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                ),
              ),
              child: const Column(
                children: [
                  _ProFeatureRow('Unlimited AI Investment & Tax Queries'),
                  _ProFeatureRow('Multi-Goal Corpus Solvers & Backtesting'),
                  _ProFeatureRow('Full Portfolio Overlap & Risk Audits'),
                  _ProFeatureRow('Export Custom Branded PDF Blueprints'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                ),
                icon: const Icon(Icons.flash_on, color: Colors.black),
                label: const Text(
                  'Upgrade to Pro (\$4.99 / mo or Demo Toggle)',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                onPressed: () {
                  widget.onUpgradeToPaid?.call();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int remaining = widget.isPaidUser
        ? 999
        : (_maxFreePrompts - _usedDemoPrompts).clamp(0, _maxFreePrompts);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: DashboardAppBar(
        title: 'AI Wealth Advisor (LLM)',
        isPro: widget.isPaidUser,
        onUpgradeTap: _showUpgradePaywall,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1E293B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.isPaidUser ? Icons.workspace_premium : Icons.bolt,
                      color: widget.isPaidUser
                          ? Colors.amberAccent
                          : const Color(0xFF38BDF8),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isPaidUser
                          ? 'Pro Member — Unlimited LLM Queries'
                          : 'Demo Mode: $remaining / $_maxFreePrompts Queries Remaining',
                      style: TextStyle(
                        color: widget.isPaidUser
                            ? Colors.amberAccent
                            : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (!widget.isPaidUser)
                  ActionChip(
                    label: const Text(
                      'Upgrade to Pro',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.zero,
                    onPressed: _showUpgradePaywall,
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isThinking) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'AI Advisor generating financial blueprint...',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 620),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF064E3B)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isUser
                            ? const Color(0xFF10B981).withValues(alpha: 0.5)
                            : Colors.white10,
                      ),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _quickPrompts
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(right: 6, bottom: 8),
                      child: ActionChip(
                        label: Text(
                          p,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        backgroundColor: const Color(0xFF1E293B),
                        onPressed: () => _sendQuery(p),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (!widget.isPaidUser && _usedDemoPrompts >= _maxFreePrompts)
            Container(
              padding: const EdgeInsets.all(14),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    color: Colors.amberAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Demo queries exhausted. Upgrade to Pro to continue asking.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                    ),
                    onPressed: _showUpgradePaywall,
                    child: const Text(
                      'Unlock Pro',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Ask any investment, tax, or SWP question...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _sendQuery,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Color(0xFF10B981),
                    ),
                    onPressed: () => _sendQuery(_queryController.text),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProFeatureRow extends StatelessWidget {
  final String title;
  const _ProFeatureRow(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
