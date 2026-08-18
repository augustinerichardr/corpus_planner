import 'dart:async';
import 'package:flutter/material.dart';
import '../models/mutual_fund_model.dart';
import '../services/mutual_funds_repository.dart';
import '../widgets/dashboard_app_bar.dart';

class MutualFundsScreen extends StatefulWidget {
  const MutualFundsScreen({super.key});

  @override
  State<MutualFundsScreen> createState() => _MutualFundsScreenState();
}

class _MutualFundsScreenState extends State<MutualFundsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController(
    text: 'quant',
  );

  List<MutualFundScheme> _schemes = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  String _selectedCategory = 'All';
  String _selectedPlan = 'Direct - Growth (Recommended)';
  String _selectedSort = 'Relevance';

  MutualFundDetails? _selectedFundDetails;
  int? _selectedSchemeCode;
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyScreenerFilters();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyScreenerFilters() {
    _debounceTimer?.cancel();
    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _selectedFundDetails = null;
      _selectedSchemeCode = null;
    });

    MutualFundsRepository.searchAmfiSchemes(
          query: _searchCtrl.text,
          categoryFilter: _selectedCategory,
          planFilter: _selectedPlan,
          sortBy: _selectedSort,
        )
        .then((results) {
          if (!mounted) return;
          setState(() {
            _schemes = results;
            _isSearching = false;
          });

          if (results.isNotEmpty && mounted) {
            _loadFundDetails(results.first);
          }
        })
        .catchError((_) {
          if (mounted) setState(() => _isSearching = false);
        });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _applyScreenerFilters();
    });
  }

  void _loadFundDetails(MutualFundScheme scheme) async {
    if (!mounted) return;
    setState(() {
      _selectedSchemeCode = scheme.schemeCode;
      _isLoadingDetails = true;
    });

    final details = await MutualFundsRepository.fetchFundDetails(
      scheme.schemeCode,
      scheme.schemeName,
    );

    if (mounted) {
      setState(() {
        _selectedFundDetails = details;
        _isLoadingDetails = false;
      });
    }
  }

  void _onSchemeTapped(MutualFundScheme scheme, bool isWide) {
    if (isWide) {
      _loadFundDetails(scheme);
    } else {
      _openMobileModal(scheme);
    }
  }

  void _openMobileModal(MutualFundScheme scheme) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      ),
    );

    final details = await MutualFundsRepository.fetchFundDetails(
      scheme.schemeCode,
      scheme.schemeName,
    );

    if (mounted) {
      Navigator.pop(context);
      if (details != null) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color(0xFF0F172A),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => Container(
            height: MediaQuery.of(context).size.height * 0.90,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: FundDetailsView(
                details: details,
                onClose: () => Navigator.pop(context),
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: DashboardAppBar(
        title: 'Mutual Funds Intelligence & AMFI Screener',
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
              tabs: const [
                Tab(
                  icon: Icon(Icons.saved_search),
                  text: 'Live AMFI Screener (10,000+ Schemes)',
                ),
                Tab(
                  icon: Icon(Icons.menu_book),
                  text: 'How Mutual Funds Work & Top Brokers',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildLiveScreenerSplitView(), _buildEducationTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveScreenerSplitView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 920;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 480, child: _buildSchemesListPanel(isWide: true)),
              const VerticalDivider(color: Colors.white10, width: 1),
              Expanded(
                child: Container(
                  color: const Color(0xFF0F172A),
                  padding: const EdgeInsets.all(20),
                  child: _isLoadingDetails
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF10B981),
                          ),
                        )
                      : _selectedFundDetails != null
                      ? SingleChildScrollView(
                          child: FundDetailsView(
                            details: _selectedFundDetails!,
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Select a fund from the left to view full analysis.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                ),
              ),
            ],
          );
        }

        return _buildSchemesListPanel(isWide: false);
      },
    );
  }

  Widget _buildSchemesListPanel({required bool isWide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Color(0xFF10B981),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'Search any AMC (e.g. quant, dsp, tata, sbi, hdfc)...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    if (_isSearching)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF10B981),
                        ),
                      )
                    else if (_searchCtrl.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.grey,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          _applyScreenerFilters();
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildFilterDropdown(
                      label: 'Category',
                      value: _selectedCategory,
                      items: const [
                        'All',
                        'Large Cap',
                        'Mid Cap',
                        'Small Cap',
                        'Large & Mid Cap',
                        'Flexi / Multi Cap',
                        'ELSS Tax Saver',
                        'Hybrid / Multi-Asset',
                        'Sectoral / Thematic',
                        'Debt / Liquid',
                      ],
                      onChanged: (val) {
                        setState(() => _selectedCategory = val!);
                        _applyScreenerFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: _buildFilterDropdown(
                      label: 'Plan & Option',
                      value: _selectedPlan,
                      items: const [
                        'Direct - Growth (Recommended)',
                        'Direct - All',
                        'Regular - Growth',
                        'All Plans & IDCW',
                      ],
                      onChanged: (val) {
                        setState(() => _selectedPlan = val!);
                        _applyScreenerFilters();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AMFI Screener Results (${_schemes.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isWide
                        ? 'Active scheme loaded on right'
                        : 'Tap tile for details',
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: _schemes.isEmpty && !_isSearching
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(36),
                  alignment: Alignment.center,
                  child: const Text(
                    'No schemes match this combination. Try changing category to "All".',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _schemes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final scheme = _schemes[i];
                    final dynamicCat = MutualFundsRepository.deriveCategory(
                      scheme.schemeName,
                    );
                    final isDirect = scheme.schemeName.toLowerCase().contains(
                      'direct',
                    );
                    final isGrowth = scheme.schemeName.toLowerCase().contains(
                      'growth',
                    );
                    final Color catColor = _getCategoryColor(dynamicCat);
                    final bool isSelected =
                        scheme.schemeCode == _selectedSchemeCode;

                    return InkWell(
                      onTap: () => _onSchemeTapped(scheme, isWide),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF064E3B).withOpacity(0.4)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : (isDirect
                                      ? const Color(0xFF10B981).withOpacity(0.2)
                                      : const Color(0xFF334155)),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: catColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: catColor.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getCategoryIcon(dynamicCat),
                                        color: catColor,
                                        size: 10,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        dynamicCat,
                                        style: TextStyle(
                                          color: catColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _pill(
                                  isDirect ? 'Direct' : 'Regular',
                                  isDirect
                                      ? const Color(0xFF38BDF8)
                                      : Colors.orangeAccent,
                                  const Color(0xFF0F172A),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              scheme.schemeName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _pill(
                                      isGrowth ? 'Growth' : 'IDCW',
                                      isGrowth
                                          ? const Color(0xFFA855F7)
                                          : Colors.grey,
                                      const Color(0xFF0F172A),
                                    ),
                                    const SizedBox(width: 6),
                                    _pill(
                                      'Code: ${scheme.schemeCode}',
                                      Colors.grey,
                                      const Color(0xFF0F172A),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      isSelected ? 'Active' : 'Select',
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF10B981)
                                            : Colors.grey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: isSelected
                                          ? const Color(0xFF10B981)
                                          : Colors.grey,
                                      size: 9,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 8.5),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF10B981),
                size: 16,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    if (cat.contains('Small')) return const Color(0xFFEF4444);
    if (cat.contains('Mid')) return const Color(0xFF38BDF8);
    if (cat.contains('Large')) return const Color(0xFF10B981);
    if (cat.contains('Flexi')) return const Color(0xFFA855F7);
    if (cat.contains('Sectoral')) return Colors.tealAccent;
    if (cat.contains('Debt')) return Colors.orangeAccent;
    if (cat.contains('Index')) return Colors.tealAccent;
    return const Color(0xFF10B981);
  }

  IconData _getCategoryIcon(String cat) {
    if (cat.contains('Small')) return Icons.rocket_launch;
    if (cat.contains('Mid')) return Icons.trending_up;
    if (cat.contains('Large')) return Icons.shield_outlined;
    if (cat.contains('Flexi')) return Icons.auto_awesome;
    if (cat.contains('Sectoral')) return Icons.biotech_outlined;
    if (cat.contains('Debt')) return Icons.account_balance;
    if (cat.contains('Index')) return Icons.show_chart;
    return Icons.pie_chart;
  }

  Widget _pill(String text, Color textC, Color bgC) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bgC,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textC.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textC,
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEducationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is a Mutual Fund & How it Works',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF38BDF8).withOpacity(0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'A Mutual Fund pools capital from retail investors to purchase a professionally managed portfolio of stocks, bonds, or commodities according to SEBI regulations.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '• Direct vs Regular Plans: Direct plans carry zero distributor commission (0.5%–1.2% lower expense ratio), yielding 20%+ more wealth over 15 years.',
                  style: TextStyle(color: Color(0xFF10B981), fontSize: 11),
                ),
                SizedBox(height: 4),
                Text(
                  '• Growth vs IDCW (Dividend): Choose "Growth" so profits compound automatically tax-free until withdrawal.',
                  style: TextStyle(color: Colors.amberAccent, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Top SEBI-Registered Direct Investment Platforms in India',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _brokerCard(
            'Zerodha (Coin)',
            'Direct Mutual Funds',
            'Zero Brokerage',
            'Integrated Demat holding; UPI autopay mandates.',
            const Color(0xFF38BDF8),
          ),
          _brokerCard(
            'Groww',
            'Direct Mutual Funds',
            'Zero Commission',
            'Instant 1-click SIP mandates with BSE Star MF integration.',
            const Color(0xFF10B981),
          ),
          _brokerCard(
            'INDmoney',
            'Direct Mutual Funds + CAS',
            'Zero Commission',
            'Consolidated statement tracking for all external broker holdings.',
            const Color(0xFFA855F7),
          ),
          _brokerCard(
            'Kuvera',
            'Direct Mutual Funds',
            'Zero Commission',
            'Family portfolio aggregation and tax-loss harvesting features.',
            Colors.orangeAccent,
          ),
          _brokerCard(
            'ICICI Direct / HDFC Sky',
            'Full-Service 3-in-1',
            'Standard Direct',
            'Direct linkage with primary savings account.',
            Colors.tealAccent,
          ),
        ],
      ),
    );
  }

  Widget _brokerCard(
    String name,
    String type,
    String fee,
    String note,
    Color accent,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
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
                  fee,
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
          Text(note, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}

class FundDetailsView extends StatefulWidget {
  final MutualFundDetails details;
  final VoidCallback? onClose;

  const FundDetailsView({super.key, required this.details, this.onClose});

  @override
  State<FundDetailsView> createState() => _FundDetailsViewState();
}

class _FundDetailsViewState extends State<FundDetailsView> {
  String _selectedTimeline = '5Y';

  @override
  Widget build(BuildContext context) {
    final fund = widget.details;
    final chartPoints =
        fund.chartHistories[_selectedTimeline] ??
        fund.chartHistories['5Y'] ??
        [fund.nav];

    final double minNav = chartPoints.reduce((a, b) => a < b ? a : b);
    final double maxNav = chartPoints.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fund.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${fund.amc} • ${fund.category}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (widget.onClose != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: widget.onClose,
              ),
          ],
        ),
        const Divider(color: Colors.white10, height: 18),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live AMFI NAV',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      Text(
                        '₹${fund.nav.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: ['1D', '1M', '6M', '1Y', '3Y', '5Y', 'MAX'].map((
                      t,
                    ) {
                      final isSelected = _selectedTimeline == t;
                      return InkWell(
                        onTap: () => setState(() => _selectedTimeline = t),
                        child: Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.grey,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 130,
                width: double.infinity,
                child: CustomPaint(
                  painter: _SmoothNavLineChartPainter(
                    points: chartPoints,
                    lineColor: const Color(0xFF10B981),
                    gradientColor: const Color(0xFF10B981).withOpacity(0.25),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Period Low: ₹${minNav.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 9.5),
                  ),
                  Text(
                    'Period High: ₹${maxNav.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            _cagrBox(
              '1Y Return',
              '${fund.returnsCagr['1Y']}%',
              const Color(0xFF10B981),
            ),
            const SizedBox(width: 8),
            _cagrBox(
              '3Y CAGR',
              '${fund.returnsCagr['3Y']}%',
              const Color(0xFF10B981),
            ),
            const SizedBox(width: 8),
            _cagrBox(
              '5Y CAGR',
              '${fund.returnsCagr['5Y']}%',
              const Color(0xFF10B981),
            ),
            const SizedBox(width: 8),
            _cagrBox(
              'Since Inception',
              '${fund.returnsCagr['MAX']}%',
              const Color(0xFF38BDF8),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            _factBox(
              'Inception Date',
              '${fund.launchDate.day}/${fund.launchDate.month}/${fund.launchDate.year}',
            ),
            const SizedBox(width: 8),
            _factBox('Benchmark', fund.benchmark),
            const SizedBox(width: 8),
            _factBox('Expense Ratio', '${fund.expenseRatio}%'),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orangeAccent.withOpacity(0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orangeAccent,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Exit Load Policy',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                fund.exitLoad,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        const Text(
          'Top 10 Underlying Portfolio Holdings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: fund.topHoldings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (ctx, i) {
            final h = fund.topHoldings[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.stockName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                      Text(
                        h.sector,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${h.percentage}%',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _cagrBox(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 9),
            ),
            const SizedBox(height: 2),
            Text(
              val,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _factBox(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 9),
            ),
            const SizedBox(height: 2),
            Text(
              val,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SmoothNavLineChartPainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;
  final Color gradientColor;

  _SmoothNavLineChartPainter({
    required this.points,
    required this.lineColor,
    required this.gradientColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double minVal = points.reduce((a, b) => a < b ? a : b);
    final double maxVal = points.reduce((a, b) => a > b ? a : b);
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height * 0.25),
      Offset(size.width, size.height * 0.25),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.50),
      Offset(size.width, size.height * 0.50),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.75),
      gridPaint,
    );

    if (points.length == 1) {
      final y = size.height / 2;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = lineColor
          ..strokeWidth = 2,
      );
      return;
    }

    final List<Offset> offsets = [];
    final double dx = size.width / (points.length - 1);
    for (int i = 0; i < points.length; i++) {
      final normY = (points[i] - minVal) / range;
      final y = size.height - (normY * (size.height - 20)) - 10;
      offsets.add(Offset(i * dx, y));
    }

    final path = Path();
    path.moveTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientColor, gradientColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawPath(path, linePaint);

    final last = offsets.last;
    canvas.drawCircle(last, 4.5, Paint()..color = lineColor);
    canvas.drawCircle(last, 2.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _SmoothNavLineChartPainter oldDelegate) => true;
}
