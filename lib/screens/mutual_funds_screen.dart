import 'package:flutter/material.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/regulatory_disclaimer.dart';

class MutualFundsScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  const MutualFundsScreen({super.key, this.onMenuPressed});

  @override
  State<MutualFundsScreen> createState() => _MutualFundsScreenState();
}

class _MutualFundsScreenState extends State<MutualFundsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Categories';
  String _selectedAmc = 'All AMCs';

  final List<String> _categories = [
    'All Categories',
    'Large Cap Equity',
    'Flexi Cap Equity (Multi-Sector)',
    'Mid Cap Equity (High Alpha)',
    'Passive Large Cap Index',
    'Debt / Liquid',
  ];

  final List<String> _amcs = [
    'All AMCs',
    'Nippon India',
    'Parag Parikh',
    'HDFC Mutual Fund',
    'UTI Mutual Fund',
    'ICICI Prudential',
  ];

  final List<Map<String, dynamic>> _allFunds = [
    {
      'title': 'Nippon India Large Cap Fund - Direct Growth',
      'category': 'Large Cap Equity',
      'amc': 'Nippon India',
      'cagr3Y': '24.8% p.a.',
      'ter': '0.72%',
      'aum': '₹34,200 Cr',
    },
    {
      'title': 'Parag Parikh Flexi Cap Fund - Direct Growth',
      'category': 'Flexi Cap Equity (Multi-Sector)',
      'amc': 'Parag Parikh',
      'cagr3Y': '21.4% p.a.',
      'ter': '0.62%',
      'aum': '₹78,900 Cr',
    },
    {
      'title': 'HDFC Mid-Cap Opportunities - Direct Growth',
      'category': 'Mid Cap Equity (High Alpha)',
      'amc': 'HDFC Mutual Fund',
      'cagr3Y': '28.6% p.a.',
      'ter': '0.78%',
      'aum': '₹72,400 Cr',
    },
    {
      'title': 'UTI Nifty 50 Index Fund - Direct Growth',
      'category': 'Passive Large Cap Index',
      'amc': 'UTI Mutual Fund',
      'cagr3Y': '16.2% p.a.',
      'ter': '0.18%',
      'aum': '₹19,800 Cr',
    },
    {
      'title': 'ICICI Prudential Liquid Fund - Direct Growth',
      'category': 'Debt / Liquid',
      'amc': 'ICICI Prudential',
      'cagr3Y': '7.1% p.a.',
      'ter': '0.15%',
      'aum': '₹45,600 Cr',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredFunds {
    final query = _searchController.text.trim().toLowerCase();
    return _allFunds.where((fund) {
      final matchesCat = _selectedCategory == 'All Categories' ||
          fund['category'] == _selectedCategory;
      final matchesAmc =
          _selectedAmc == 'All AMCs' || fund['amc'] == _selectedAmc;
      final matchesQuery = query.isEmpty ||
          fund['title'].toLowerCase().contains(query) ||
          fund['category'].toLowerCase().contains(query) ||
          fund['amc'].toLowerCase().contains(query);
      return matchesCat && matchesAmc && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFunds;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: DashboardAppBar(
        title: 'Mutual Funds Intelligence & Screener',
        onMenuPressed: widget.onMenuPressed,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        children: [
          // India Market Notice Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('🇮🇳', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'AMFI Regulated Indian Mutual Funds',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'SEBI / NSE / BSE',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Direct and regular growth schemes mapped exclusively to Indian Asset Management Companies (AMCs) via AMFI real-time feeds.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search Field
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText:
                  'Search fund by keyword (e.g. Nippon, Nifty, Bluechip)...',
              hintStyle: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11.5,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF10B981),
                size: 17,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 15,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1E293B),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Dropdowns Row (Category & AMC)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      dropdownColor: const Color(0xFF1E293B),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 11.5),
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child:
                                    Text(cat, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null)
                          setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedAmc,
                      dropdownColor: const Color(0xFF1E293B),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 11.5),
                      items: _amcs
                          .map((amc) => DropdownMenuItem(
                                value: amc,
                                child:
                                    Text(amc, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedAmc = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filtered Fund Cards List
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              alignment: Alignment.center,
              child: const Text(
                'No matching mutual funds or schemes found',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            )
          else
            for (final fund in filtered) ...[
              _buildFundTile(
                title: fund['title'],
                category: fund['category'],
                cagr3Y: fund['cagr3Y'],
                ter: fund['ter'],
                aum: fund['aum'],
              ),
              const SizedBox(height: 8),
            ],

          const SizedBox(height: 16),
          const RegulatoryDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildFundTile({
    required String title,
    required String category,
    required String cagr3Y,
    required String ter,
    required String aum,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.show_chart,
                    color: Color(0xFF38BDF8), size: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      category,
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricBlock('3Y CAGR', cagr3Y, const Color(0xFF10B981)),
              _metricBlock('TER (Expense)', ter, const Color(0xFF38BDF8)),
              _metricBlock('Fund AUM', aum, const Color(0xFFA78BFA)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricBlock(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5)),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
