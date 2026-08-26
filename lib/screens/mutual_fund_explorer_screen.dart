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
  bool _isLoading = false;
  bool _hasSearched = false;
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
    'Bandhan',
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
    String input = _searchController.text.trim().toLowerCase();

    // Only search if user typed something or selected a specific AMC/Category
    if (input.isEmpty &&
        _selectedAmc == 'All AMCs' &&
        _selectedCategory == 'All Categories') {
      if (mounted) {
        setState(() {
          _allSchemes = [];
          _isLoading = false;
          _hasSearched = false;
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    String queryTerm = input.isNotEmpty
        ? input
        : (_selectedAmc != 'All AMCs' ? _selectedAmc.toLowerCase() : 'growth');

    try {
      final raw = await MFService.searchFunds(queryTerm);
      if (mounted) {
        setState(() {
          _allSchemes = raw.where((s) {
            String name = s.schemeName.toLowerCase();
            bool mInput = input.isEmpty || name.contains(input);
            bool mAmc = _selectedAmc == 'All AMCs' ||
                name.contains(_selectedAmc.toLowerCase());
            bool mCat = _selectedCategory == 'All Categories' ||
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
      if (mounted) {
        setState(() {
          _allSchemes = [];
          _isLoading = false;
        });
      }
    }
  }

  void _openSheet(MutualFundScheme s) {
    bool isMidSmall = s.schemeName.toLowerCase().contains('mid') ||
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
    double totalSip =
        _selectedSchemes.fold(0, (sum, i) => sum + i.allocatedSip);
    int maxAllowed = widget.isPaidUser ? 25 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
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
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.5),
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
                                color: Colors.grey, fontSize: 11),
                          ),
                          Text(
                            '${widget.currencySymbol}${totalSip.toInt()} / month',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                      const Row(
                        children: [
                          Text(
                            'View Strategy',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: Color(0xFF10B981), size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Compact Filter Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText:
                      'Search fund by keyword (e.g. Bandhan, Nifty, Bluechip)...',
                  hintStyle:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFF10B981), size: 18),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.grey, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            _fetch();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                ),
              ),
            ),

            // Dropdowns row
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
            const SizedBox(height: 6),

            // Results Area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF10B981)))
                  : !_hasSearched && _allSchemes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.manage_search_rounded,
                                  color: Colors.grey.withValues(alpha: 0.5),
                                  size: 48),
                              const SizedBox(height: 10),
                              const Text(
                                'Select an AMC or search scheme keywords to screen funds',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : _allSchemes.isEmpty
                          ? const Center(
                              child: Text(
                                'No matching mutual fund schemes found',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              itemCount: _allSchemes.length,
                              itemBuilder: (_, i) => FundCard(
                                scheme: _allSchemes[i],
                                return5Y: 'Live NAV',
                                onTap: () => _openSheet(_allSchemes[i]),
                              ),
                            ),
            ),
          ],
        ),
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
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border.withValues(alpha: 0.4)),
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
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
