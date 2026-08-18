import 'package:flutter/material.dart';
import '../models/portfolio_snapshot_model.dart';
import '../services/portfolio_storage_service.dart';
import '../widgets/dashboard_app_bar.dart';

class PortfolioManagerScreen extends StatefulWidget {
  final Function(double lumpSum, double monthlySip)? onSimulateInPlanner;
  final Function(double totalDebt)? onSimulateInArbitrage;

  const PortfolioManagerScreen({
    super.key,
    this.onSimulateInPlanner,
    this.onSimulateInArbitrage,
  });

  @override
  State<PortfolioManagerScreen> createState() => _PortfolioManagerScreenState();
}

class _PortfolioManagerScreenState extends State<PortfolioManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PortfolioSnapshot> _snapshots = [];
  PortfolioSnapshot? _activeSnapshot;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPortfolio();
  }

  void _loadPortfolio() async {
    final list = await PortfolioStorageService.getAllSnapshots();
    setState(() {
      _snapshots = list;
      _activeSnapshot = list.isNotEmpty ? list.first : null;
      _isLoading = false;
    });
  }

  String _formatINR(double val) {
    if (val >= 10000000 || val <= -10000000) {
      return '₹${(val / 10000000).toStringAsFixed(2)} Cr';
    } else if (val >= 100000 || val <= -100000) {
      return '₹${(val / 100000).toStringAsFixed(2)} L';
    } else if (val >= 1000 || val <= -1000) {
      return '₹${(val / 1000).toStringAsFixed(1)} K';
    }
    return '₹${val.toStringAsFixed(0)}';
  }

  void _saveCurrentSnapshot(String label) async {
    if (_activeSnapshot == null) return;
    final now = DateTime.now();
    final newSnap = PortfolioSnapshot(
      id: 'snapshot_${now.millisecondsSinceEpoch}',
      recordedDate: now,
      note: label.isNotEmpty
          ? label
          : 'Snapshot ${now.day}/${now.month}/${now.year}',
      assets: _activeSnapshot!.assets,
      liabilities: _activeSnapshot!.liabilities,
    );
    await PortfolioStorageService.saveSnapshot(newSnap);
    _loadPortfolio();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Portfolio snapshot saved successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF10B981)),
        ),
      );
    }

    final snap = _activeSnapshot;
    final double netWorth = snap?.netWorth ?? 0;
    final double totalAssets = snap?.totalAssets ?? 0;
    final double totalLiabilities = snap?.totalLiabilities ?? 0;
    final double totalMonthlySavings = snap?.totalMonthlySavings ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: DashboardAppBar(
        title: 'India Corpus & Debt Manager',
        onCountryChanged: (_) {},
      ),
      body: Column(
        children: [
          // Net Worth Summary Banner
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _summaryBadge(
                      'Total Assets (PPF, NPS, MF)',
                      _formatINR(totalAssets),
                      const Color(0xFF10B981),
                    ),
                    _summaryBadge(
                      'Total Debts / Loans',
                      _formatINR(totalLiabilities),
                      const Color(0xFFEF4444),
                    ),
                    _summaryBadge(
                      'Current Net Worth',
                      _formatINR(netWorth),
                      const Color(0xFF38BDF8),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.black,
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.rocket_launch, size: 14),
                        label: const Text(
                          'Simulate Assets in Planner',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          widget.onSimulateInPlanner?.call(
                            totalAssets,
                            totalMonthlySavings,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Transferred ${_formatINR(totalAssets)} assets & ${_formatINR(totalMonthlySavings)} SIP into Planner!',
                              ),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        },
                      ),
                    ),
                    if (totalLiabilities > 0) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF38BDF8)),
                            foregroundColor: const Color(0xFF38BDF8),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(
                            Icons.swap_horizontal_circle,
                            size: 14,
                          ),
                          label: const Text(
                            'Simulate Debt Arbitrage',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            widget.onSimulateInArbitrage?.call(
                              totalLiabilities,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Transferred ${_formatINR(totalLiabilities)} loan principal into Arbitrage Simulator!',
                                ),
                                backgroundColor: const Color(0xFF38BDF8),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: const Color(0xFF1E293B),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF10B981),
              labelColor: const Color(0xFF10B981),
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  text: 'India Assets',
                ),
                Tab(
                  icon: Icon(Icons.money_off_csred_outlined),
                  text: 'Loans & Debts',
                ),
                Tab(
                  icon: Icon(Icons.history_toggle_off),
                  text: 'Timeline & History',
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAssetsTab(),
                _buildDebtsTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsTab() {
    final assets = _activeSnapshot?.assets ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Indian Investment Instruments',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.add, size: 14),
                label: const Text(
                  'Add Instrument',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _showAddAssetDialog(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final a = assets[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF064E3B),
                          child: Icon(
                            _getAssetIcon(a.category),
                            color: const Color(0xFF10B981),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${a.category} • Expected: ${a.expectedReturnPercent}% p.a.',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatINR(a.currentVal),
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'SIP: ${_formatINR(a.monthlyContribution)}/mo',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDebtsTab() {
    final liabilities = _activeSnapshot?.liabilities ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Liabilities & Bank Loans',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.add, size: 14),
                label: const Text(
                  'Add Loan / Debt',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _showAddDebtDialog(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: liabilities.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final l = liabilities[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.4),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xFF7F1D1D),
                              child: Icon(
                                Icons.money_off,
                                color: Color(0xFFEF4444),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${l.loanType} • Interest: ${l.interestRatePercent}%',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatINR(l.principalRemaining),
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'EMI: ${_formatINR(l.monthlyEmi)}/mo',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Remaining Tenure: ${l.tenureRemainingMonths} months (~${(l.tenureRemainingMonths / 12).toStringAsFixed(1)} yrs)',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10.5,
                          ),
                        ),
                        Text(
                          'Payoff Date: ~${DateTime.now().add(Duration(days: l.tenureRemainingMonths * 30)).year}',
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Portfolio Snapshots & History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.black,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.camera_alt_outlined, size: 14),
                label: const Text(
                  'Capture Snapshot',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  final textCtrl = TextEditingController(
                    text:
                        'Snapshot ${DateTime.now().month}/${DateTime.now().year}',
                  );
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1E293B),
                      title: const Text(
                        'Save Portfolio Snapshot',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      content: TextField(
                        controller: textCtrl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Snapshot Label / Note',
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _saveCurrentSnapshot(textCtrl.text);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _snapshots.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final s = _snapshots[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.note,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Recorded: ${s.recordedDate.day}/${s.recordedDate.month}/${s.recordedDate.year}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Net: ${_formatINR(s.netWorth)}',
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Assets: ${_formatINR(s.totalAssets)} | Debt: ${_formatINR(s.totalLiabilities)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.grey,
                            size: 18,
                          ),
                          onPressed: () async {
                            await PortfolioStorageService.deleteSnapshot(s.id);
                            _loadPortfolio();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getAssetIcon(String cat) {
    switch (cat) {
      case 'PPF':
      case 'EPF':
      case 'SSY':
        return Icons.verified_user_outlined;
      case 'NPS':
        return Icons.savings_outlined;
      case 'Gold / SGB':
        return Icons.auto_awesome;
      default:
        return Icons.trending_up;
    }
  }

  void _showAddAssetDialog() {
    String name = '', category = 'PPF';
    double val = 0, sip = 0, ret = 7.1;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Add Investment Instrument',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'Name (e.g. SBI PPF, HDFC FlexiCap)',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (v) => name = v,
            ),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'Current Value (₹)',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (v) => val = double.tryParse(v) ?? 0,
            ),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'Monthly Inflow / SIP (₹)',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (v) => sip = double.tryParse(v) ?? 0,
            ),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'Expected Return % (p.a.)',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (v) => ret = double.tryParse(v) ?? 7.1,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (name.isNotEmpty && _activeSnapshot != null) {
                final newAsset = AssetEntry(
                  id: 'asset_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  category: category,
                  currentVal: val,
                  monthlyContribution: sip,
                  expectedReturnPercent: ret,
                );
                setState(() {
                  _activeSnapshot!.assets.add(newAsset);
                });
                _saveCurrentSnapshot('Updated Live Portfolio');
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddDebtDialog() {
    String name = '', loanType = 'Home Loan';
    double principal = 0, rate = 8.5, emi = 0;
    int tenure = 60;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Add Debt / Loan Entry',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'Loan Name (e.g. SBI Home Loan)',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (v) => name = v,
            ),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'Outstanding Principal (₹)',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (v) => principal = double.tryParse(v) ?? 0,
            ),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'Monthly EMI (₹)',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (v) => emi = double.tryParse(v) ?? 0,
            ),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'Remaining Months',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (v) => tenure = int.tryParse(v) ?? 60,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (name.isNotEmpty && _activeSnapshot != null) {
                final newLiability = LiabilityEntry(
                  id: 'debt_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  loanType: loanType,
                  principalRemaining: principal,
                  interestRatePercent: rate,
                  monthlyEmi: emi,
                  tenureRemainingMonths: tenure,
                );
                setState(() {
                  _activeSnapshot!.liabilities.add(newLiability);
                });
                _saveCurrentSnapshot('Updated Live Portfolio');
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add Loan'),
          ),
        ],
      ),
    );
  }
}
