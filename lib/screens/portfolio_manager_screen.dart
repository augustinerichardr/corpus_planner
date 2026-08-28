// lib/screens/portfolio_manager_screen.dart
import 'package:flutter/material.dart';
import '../models/portfolio_models.dart';
import '../services/pro_service.dart';
import '../services/settings_service.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/regulatory_disclaimer.dart';
import '../widgets/portfolio/net_worth_hero_card.dart';
import '../widgets/portfolio/assets_tab_view.dart';
import '../widgets/portfolio/debts_tab_view.dart';
import '../widgets/portfolio/analytics_tab_view.dart';
import 'pricing_screen.dart';

class PortfolioManagerScreen extends StatefulWidget {
  final int initialTabIndex;
  final Function(double lumpSum, double monthlySip)? onSimulateInPlanner;
  final Function(double totalDebt)? onSimulateInArbitrage;
  final VoidCallback? onMenuPressed;

  const PortfolioManagerScreen({
    super.key,
    this.initialTabIndex = 0,
    this.onSimulateInPlanner,
    this.onSimulateInArbitrage,
    this.onMenuPressed,
  });

  @override
  State<PortfolioManagerScreen> createState() => _PortfolioManagerScreenState();
}

class _PortfolioManagerScreenState extends State<PortfolioManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AssetItem> _assets = PortfolioSampleData.getDefaultAssets();
  final List<DebtItem> _debts = PortfolioSampleData.getDefaultDebts();
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
    _isPro = ProService.isProNotifier.value;
    ProService.isProNotifier.addListener(_onProStatusChanged);
  }

  @override
  void didUpdateWidget(covariant PortfolioManagerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _tabController.animateTo(widget.initialTabIndex.clamp(0, 2));
    }
  }

  @override
  void dispose() {
    ProService.isProNotifier.removeListener(_onProStatusChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onProStatusChanged() {
    if (mounted) {
      setState(() => _isPro = ProService.isProNotifier.value);
    }
  }

  Future<void> _openPricingModal() async {
    await PricingModal.show(context);
  }

  double get _totalAssets =>
      _assets.fold(0.0, (sum, item) => sum + item.currentValue);
  double get _totalMonthlySip =>
      _assets.fold(0.0, (sum, item) => sum + item.monthlySip);
  double get _totalDebts =>
      _debts.fold(0.0, (sum, item) => sum + item.outstandingPrincipal);
  double get _totalMonthlyEmi =>
      _debts.fold(0.0, (sum, item) => sum + item.monthlyEmi);

  void _openAddAssetDialog(String currencySymbol) {
    final nameCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final sipCtrl = TextEditingController();
    final returnCtrl = TextEditingController(text: '12.0');
    String selectedCategory = 'Equity Funds';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Row(
            children: [
              Icon(Icons.add_chart, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 8),
              Text(
                'Add New Asset',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField(
                    nameCtrl,
                    'Asset Name',
                    'e.g. Nifty 50 Index Fund',
                    Icons.badge_outlined,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _dialogInputDecoration(
                      'Category',
                      Icons.category_outlined,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Equity Funds',
                        child: Text('Equity Mutual Funds'),
                      ),
                      DropdownMenuItem(
                        value: 'Alpha Growth',
                        child: Text('Mid / Small Cap Alpha'),
                      ),
                      DropdownMenuItem(
                        value: 'Govt EEE Scheme',
                        child: Text('PPF / Sovereign Debt'),
                      ),
                      DropdownMenuItem(
                        value: 'Tier-I Pension',
                        child: Text('NPS / Pension'),
                      ),
                      DropdownMenuItem(
                        value: 'Retirement Fixed',
                        child: Text('EPF / VPF'),
                      ),
                      DropdownMenuItem(
                        value: 'Instant Cash',
                        child: Text('Emergency Liquid Cash'),
                      ),
                      DropdownMenuItem(
                        value: 'Direct Stocks',
                        child: Text('Direct Listed Equities'),
                      ),
                      DropdownMenuItem(
                        value: 'Gold / SGB',
                        child: Text('Gold & Sovereign Bonds'),
                      ),
                    ],
                    onChanged: (val) => val != null
                        ? setDialogState(() => selectedCategory = val)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _buildDialogTextField(
                    valueCtrl,
                    'Current Balance / Value ($currencySymbol)',
                    'e.g. 500000',
                    Icons.account_balance_wallet_outlined,
                    isNumber: true,
                  ),
                  const SizedBox(height: 10),
                  _buildDialogTextField(
                    sipCtrl,
                    'Monthly Investment / SIP ($currencySymbol)',
                    'e.g. 10000 (0 if Lump Sum)',
                    Icons.savings_outlined,
                    isNumber: true,
                  ),
                  const SizedBox(height: 10),
                  _buildDialogTextField(
                    returnCtrl,
                    'Expected Return (% p.a.)',
                    'e.g. 12.0',
                    Icons.trending_up,
                    isNumber: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                final name = nameCtrl.text.trim();
                final val = double.tryParse(valueCtrl.text.trim()) ?? 0.0;
                final sip = double.tryParse(sipCtrl.text.trim()) ?? 0.0;
                final ret = double.tryParse(returnCtrl.text.trim()) ?? 10.0;
                if (name.isNotEmpty && val > 0) {
                  setState(() {
                    _assets.add(AssetItem(
                      name: name,
                      category: selectedCategory,
                      currentValue: val,
                      monthlySip: sip,
                      expectedReturn: ret,
                      icon: _getCategoryIcon(selectedCategory),
                      accentColor: _getCategoryColor(selectedCategory),
                      tooltip: '$selectedCategory compounding at $ret% p.a.',
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text(
                'Add Asset',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddDebtDialog(String currencySymbol) {
    final nameCtrl = TextEditingController();
    final principalCtrl = TextEditingController();
    final rateCtrl = TextEditingController(text: '8.5');
    final emiCtrl = TextEditingController();
    String selectedType = 'Secured Housing Loan';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Row(
            children: [
              Icon(Icons.credit_card_off, color: Color(0xFFEF4444), size: 20),
              SizedBox(width: 8),
              Text(
                'Add New Loan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField(
                    nameCtrl,
                    'Loan / Debt Name',
                    'e.g. Axis Home Loan',
                    Icons.badge_outlined,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    dropdownColor: const Color(0xFF0F172A),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _dialogInputDecoration(
                      'Loan Type',
                      Icons.category_outlined,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Secured Housing Loan',
                        child: Text('Home / Land Loan'),
                      ),
                      DropdownMenuItem(
                        value: 'Fixed Term Loan',
                        child: Text('Vehicle / Auto Loan'),
                      ),
                      DropdownMenuItem(
                        value: 'Personal Unsecured',
                        child: Text('Personal Loan'),
                      ),
                      DropdownMenuItem(
                        value: 'Education Loan',
                        child: Text('Education Loan'),
                      ),
                      DropdownMenuItem(
                        value: 'Revolving Credit',
                        child: Text('Credit Card / Overdraft'),
                      ),
                    ],
                    onChanged: (val) => val != null
                        ? setDialogState(() => selectedType = val)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _buildDialogTextField(
                    principalCtrl,
                    'Outstanding Principal ($currencySymbol)',
                    'e.g. 2000000',
                    Icons.money_off_rounded,
                    isNumber: true,
                  ),
                  const SizedBox(height: 10),
                  _buildDialogTextField(
                    rateCtrl,
                    'Interest Rate (% p.a.)',
                    'e.g. 8.5',
                    Icons.percent,
                    isNumber: true,
                  ),
                  const SizedBox(height: 10),
                  _buildDialogTextField(
                    emiCtrl,
                    'Monthly EMI ($currencySymbol)',
                    'e.g. 22000',
                    Icons.calendar_month,
                    isNumber: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final name = nameCtrl.text.trim();
                final principal =
                    double.tryParse(principalCtrl.text.trim()) ?? 0.0;
                final rate = double.tryParse(rateCtrl.text.trim()) ?? 8.5;
                final emi = double.tryParse(emiCtrl.text.trim()) ?? 0.0;
                if (name.isNotEmpty && principal > 0) {
                  setState(() {
                    _debts.add(DebtItem(
                      name: name,
                      type: selectedType,
                      outstandingPrincipal: principal,
                      interestRate: rate,
                      monthlyEmi: emi,
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text(
                'Add Loan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 16),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF10B981)),
      ),
    );
  }

  Widget _buildDialogTextField(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: _dialogInputDecoration(label, icon).copyWith(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
      ),
    );
  }

  IconData _getCategoryIcon(String c) {
    if (c.contains('Equity') || c.contains('Growth')) return Icons.trending_up;
    if (c.contains('Govt') || c.contains('Fixed')) {
      return Icons.verified_user_outlined;
    }
    if (c.contains('Pension')) return Icons.account_balance_outlined;
    if (c.contains('Cash')) return Icons.savings_outlined;
    if (c.contains('Gold')) return Icons.toll_outlined;
    return Icons.pie_chart_outline;
  }

  Color _getCategoryColor(String c) {
    if (c.contains('Equity')) return const Color(0xFF10B981);
    if (c.contains('Growth')) return const Color(0xFF38BDF8);
    if (c.contains('Govt')) return const Color(0xFF818CF8);
    if (c.contains('Pension')) return const Color(0xFFF59E0B);
    if (c.contains('Cash')) return const Color(0xFFA78BFA);
    return const Color(0xFF34D399);
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final sym = settings.currencySymbol;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: DashboardAppBar(
            title: 'Net Worth Portfolio & Balance Sheet',
            isPro: _isPro,
            onUpgradeTap: _openPricingModal,
            onMenuPressed: widget.onMenuPressed,
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Column(
              children: [
                NetWorthHeroCard(
                  totalAssets: _totalAssets,
                  totalDebts: _totalDebts,
                  totalMonthlySip: _totalMonthlySip,
                  onSimulateInPlanner: () => widget.onSimulateInPlanner
                      ?.call(_totalAssets, _totalMonthlySip),
                  onSimulateInArbitrage: () =>
                      widget.onSimulateInArbitrage?.call(_totalDebts),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade400,
                    labelStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: const [
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.grid_view_rounded, size: 14),
                              SizedBox(width: 6),
                              Text('Assets & SIPs'),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.credit_card, size: 14),
                              SizedBox(width: 6),
                              Text('Debts & Loans'),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.pie_chart_outline, size: 14),
                              SizedBox(width: 6),
                              Text('Allocation & Milestones'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      AssetsTabView(
                        assets: _assets,
                        totalMonthlySip: _totalMonthlySip,
                        onClearAll: () => setState(() => _assets = []),
                        onResetSample: () => setState(
                          () =>
                              _assets = PortfolioSampleData.getDefaultAssets(),
                        ),
                        onAddAsset: () => _openAddAssetDialog(sym),
                      ),
                      DebtsTabView(
                        debts: _debts,
                        totalMonthlyEmi: _totalMonthlyEmi,
                        onAddDebt: () => _openAddDebtDialog(sym),
                      ),
                      AnalyticsTabView(
                        netWorth: _totalAssets - _totalDebts,
                        totalAssets: _totalAssets,
                        totalMonthlySip: _totalMonthlySip,
                        totalMonthlyEmi: _totalMonthlyEmi,
                        assets: _assets,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const RegulatoryDisclaimer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
