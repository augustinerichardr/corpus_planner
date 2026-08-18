import 'package:flutter/material.dart';
import '../models/mutual_fund_model.dart';

class FundDetailSheet extends StatefulWidget {
  final MutualFundScheme scheme;
  final String currencySymbol;
  final Map<String, String> details;
  final int currentSelectedCount;
  final bool isPaidUser;
  final Function(double) onAdd;

  const FundDetailSheet({
    super.key,
    required this.scheme,
    required this.currencySymbol,
    required this.details,
    required this.currentSelectedCount,
    this.isPaidUser = false,
    required this.onAdd,
  });

  @override
  State<FundDetailSheet> createState() => _FundDetailSheetState();
}

class _FundDetailSheetState extends State<FundDetailSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.scheme.allocatedSip > 0
          ? widget.scheme.allocatedSip.toInt().toString()
          : '5000',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.details;
    final int maxAllowed = widget.isPaidUser ? 25 : 2;
    final bool limitReached =
        !widget.scheme.isAdded && widget.currentSelectedCount >= maxAllowed;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.scheme.schemeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  widget.scheme.category,
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (limitReached)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Free plan limit reached ($maxAllowed funds max). Upgrade to Pro to add up to 25 funds!',
                      style: const TextStyle(
                        color: Color(0xFFFCA5A5),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              _statBox('1Y Return', d['return1Y'] ?? '18%'),
              const SizedBox(width: 8),
              _statBox('5Y Return', d['return5Y'] ?? '20%'),
              const SizedBox(width: 8),
              _statBox('10Y Return', d['return10Y'] ?? '16%'),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _infoRow(Icons.person, 'Manager', d['manager'] ?? 'N/A'),
                const Divider(color: Colors.white10, height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _infoRow(
                        Icons.pie_chart,
                        'AUM',
                        d['aum'] ?? 'N/A',
                      ),
                    ),
                    Expanded(
                      child: _infoRow(
                        Icons.percent,
                        'Expense',
                        d['expenseRatio'] ?? 'N/A',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (!limitReached) ...[
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                prefixText: '${widget.currencySymbol} ',
                prefixStyle: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                widget.onAdd(double.tryParse(_controller.text) ?? 0);
                Navigator.pop(context);
              },
              child: Text(
                widget.scheme.isAdded
                    ? 'Update SIP Amount'
                    : 'Add to SIP Strategy',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.star, color: Colors.black, size: 18),
              label: const Text(
                'Upgrade to Pro (25 Funds)',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pro Subscription feature coming soon!'),
                    backgroundColor: Color(0xFFF59E0B),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _statBox(String l, String v) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(l, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            v,
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _infoRow(IconData i, String l, String v) => Row(
    children: [
      Icon(i, size: 14, color: Colors.grey),
      const SizedBox(width: 6),
      Text('$l: ', style: const TextStyle(color: Colors.grey, fontSize: 11)),
      Expanded(
        child: Text(
          v,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
