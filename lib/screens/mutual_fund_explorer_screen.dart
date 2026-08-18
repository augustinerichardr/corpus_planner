import 'dart:async';
import 'package:flutter/material.dart';
import '../models/mutual_fund_model.dart';
import '../services/mf_service.dart';
import '../widgets/fund_card.dart';
import '../widgets/fund_detail_sheet.dart';
import '../widgets/selected_portfolio_sheet.dart';

class MutualFundExplorerScreen extends StatefulWidget {
  final String currencySymbol;
  final Function(double)? onAddSipToDashboard;
  final bool isPaidUser;

  const MutualFundExplorerScreen({
    super.key,
    this.currencySymbol = '₹',
    this.onAddSipToDashboard,
    this.isPaidUser = false,
  });

  @override
  State<MutualFundExplorerScreen> createState() =>
      _MutualFundExplorerScreenState();
}

class _MutualFundExplorerScreenState extends State<MutualFundExplorerScreen> {
  final _searchController = TextEditingController();
  List<MutualFundScheme> _allSchemes = [];
  final List<MutualFundScheme> _selectedSchemes = [];
  bool _isLoading = true;
  Timer? _debounce;
  String _selectedCategory = 'All Categories', _selectedAmc = 'All AMCs';

  final List<String> _topAmcs = [
    'All AMCs',
    'SBI',
    'HDFC',
    'ICICI',
    'Axis',
    'Nippon',
    'Kotak',
    'Parag Parikh',
    'UTI',
    'DSP',
    'Mirae',
    'Tata',
    'Quant',
  ];
  final List<String> _topCategories = [
    'All Categories',
    'Large Cap Equity',
    'Mid Cap Equity',
    'Small Cap Equity',
    'Flexi/Multi Cap',
    'Index Fund',
    'ELSS Tax Saver',
  ];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _fetch);
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    String input = _searchController.text.trim().toLowerCase();
    try {
      final raw = await MFService.searchFunds(
        input.isNotEmpty ? input : 'Small Cap',
      );
      if (mounted) {
        setState(() {
          _allSchemes = raw.where((s) {
            String name = s.schemeName.toLowerCase();
            bool mInput = input.isEmpty || name.contains(input);
            bool mAmc =
                _selectedAmc == 'All AMCs' ||
                name.contains(_selectedAmc.toLowerCase());
            bool mCat =
                _selectedCategory == 'All Categories' ||
                (_selectedCategory.contains('Small') &&
                    name.contains('small')) ||
                (_selectedCategory.contains('Mid') && name.contains('mid')) ||
                (_selectedCategory.contains('Large') &&
                    name.contains('large')) ||
                (_selectedCategory.contains('Flexi') &&
                    (name.contains('flexi') || name.contains('multi'))) ||
                (_selectedCategory.contains('Index') &&
                    (name.contains('index') || name.contains('nifty'))) ||
                (_selectedCategory.contains('ELSS') &&
                    (name.contains('elss') || name.contains('tax')));
            return mInput && mAmc && mCat;
          }).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _allSchemes = [];
          _isLoading = false;
        });
    }
  }

  void _openSheet(MutualFundScheme s) {
    bool isMidSmall =
        s.schemeName.toLowerCase().contains('mid') ||
        s.schemeName.toLowerCase().contains('small');
    bool isDirect = s.schemeName.toLowerCase().contains('direct');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FundDetailSheet(
        scheme: s,
        currencySymbol: widget.currencySymbol,
        details: {
          'return1Y': '${isMidSmall ? 21.4 : 14.8}%',
          'return5Y': '${isMidSmall ? 19.6 : 15.2}%',
          'return10Y': '${isMidSmall ? 17.2 : 14.1}%',
          'manager': 'Fund Management Team',
          'aum': '₹${(s.schemeCode % 15000 + 3500)} Cr',
          'expenseRatio': '${isDirect ? 0.65 : 1.45}%',
        },
        currentSelectedCount: _selectedSchemes.length,
        isPaidUser: widget.isPaidUser,
        onAdd: (val) => setState(() {
          double prev = s.allocatedSip;
          s.isAdded = true;
          s.allocatedSip = val;
          if (!_selectedSchemes.contains(s)) _selectedSchemes.add(s);
          widget.onAddSipToDashboard?.call(val - prev);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalSip = _selectedSchemes.fold(
      0,
      (sum, i) => sum + i.allocatedSip,
    );
    int maxAllowed = widget.isPaidUser ? 25 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Mutual Fund Explorer'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_selectedSchemes.isNotEmpty)
            InkWell(
              onTap: () => showModalBottomSheet(
                context: context,
                builder: (_) => SelectedPortfolioSheet(
                  selectedSchemes: _selectedSchemes,
                  currencySymbol: widget.currencySymbol,
                  onRemove: (s) {
                    setState(() {
                      widget.onAddSipToDashboard?.call(-s.allocatedSip);
                      s.isAdded = false;
                      s.allocatedSip = 0;
                      _selectedSchemes.remove(s);
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected (${_selectedSchemes.length}/$maxAllowed funds)',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${widget.currencySymbol}${totalSip.toInt()} / month',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Text(
                          'View List',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Color(0xFF10B981),
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search scheme name (e.g. icici, bluechip)...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF10B981),
                        ),
                        onPressed: _fetch,
                      ),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    _selectedCategory,
                    _topCategories,
                    (v) => setState(() {
                      _selectedCategory = v!;
                      _fetch();
                    }),
                    const Color(0xFF064E3B),
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown(
                    _selectedAmc,
                    _topAmcs,
                    (v) => setState(() {
                      _selectedAmc = v!;
                      _fetch();
                    }),
                    const Color(0xFF0C4A6E),
                    const Color(0xFF38BDF8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF10B981)),
                  )
                : _allSchemes.isEmpty
                ? const Center(
                    child: Text(
                      'No matching funds found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _allSchemes.length,
                    itemBuilder: (_, i) => FundCard(
                      scheme: _allSchemes[i],
                      return5Y: 'NAV: Live',
                      onTap: () => _openSheet(_allSchemes[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String val,
    List<String> items,
    ValueChanged<String?> onChanged,
    Color bg,
    Color border,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          isExpanded: true,
          onChanged: onChanged,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
