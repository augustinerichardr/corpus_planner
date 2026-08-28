import 'package:flutter/material.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/regulatory_disclaimer.dart';

class BondsScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const BondsScreen({super.key, this.onMenuPressed});

  @override
  State<BondsScreen> createState() => _BondsScreenState();
}

class _BondsScreenState extends State<BondsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'G-Sec (Central)',
    'State SDL',
    'T-Bills',
    'Corporate AAA',
  ];

  final List<BondItem> _allBonds = [
    BondItem(
      title: '7.18% GS 2033 (Benchmark 10Y G-Sec)',
      issuer: 'Government of India',
      category: 'G-Sec (Central)',
      ytm: '7.18% p.a.',
      coupon: '7.18% Semi-Annual',
      tenure: '7.2 Years',
      rating: 'SOV',
      minInvestment: '₹10,000',
      ratingColor: const Color(0xFF10B981),
    ),
    BondItem(
      title: '7.30% GS 2053 (30Y Ultra-Long Sovereign)',
      issuer: 'Government of India',
      category: 'G-Sec (Central)',
      ytm: '7.34% p.a.',
      coupon: '7.30% Semi-Annual',
      tenure: '27.4 Years',
      rating: 'SOV',
      minInvestment: '₹10,000',
      ratingColor: const Color(0xFF10B981),
    ),
    BondItem(
      title: '7.42% Tamil Nadu SDL 2034',
      issuer: 'State Government of Tamil Nadu',
      category: 'State SDL',
      ytm: '7.46% p.a.',
      coupon: '7.42% Semi-Annual',
      tenure: '8.1 Years',
      rating: 'SOV (State)',
      minInvestment: '₹10,000',
      ratingColor: const Color(0xFF10B981),
    ),
    BondItem(
      title: '7.48% Maharashtra SDL 2035',
      issuer: 'State Government of Maharashtra',
      category: 'State SDL',
      ytm: '7.49% p.a.',
      coupon: '7.48% Semi-Annual',
      tenure: '9.2 Years',
      rating: 'SOV (State)',
      minInvestment: '₹10,000',
      ratingColor: const Color(0xFF10B981),
    ),
    BondItem(
      title: '91-Day Treasury Bill (T-Bill)',
      issuer: 'Reserve Bank of India',
      category: 'T-Bills',
      ytm: '6.72% p.a.',
      coupon: 'Zero Coupon (Discounted)',
      tenure: '91 Days',
      rating: 'SOV',
      minInvestment: '₹25,000',
      ratingColor: const Color(0xFF10B981),
    ),
    BondItem(
      title: '364-Day Treasury Bill (T-Bill)',
      issuer: 'Reserve Bank of India',
      category: 'T-Bills',
      ytm: '6.84% p.a.',
      coupon: 'Zero Coupon (Discounted)',
      tenure: '364 Days',
      rating: 'SOV',
      minInvestment: '₹25,000',
      ratingColor: const Color(0xFF10B981),
    ),
    BondItem(
      title: 'HDFC Bank Tier-II Subordinated Bond',
      issuer: 'HDFC Bank Limited',
      category: 'Corporate AAA',
      ytm: '7.78% p.a.',
      coupon: '7.75% Annual',
      tenure: '9.4 Years',
      rating: 'CRISIL AAA',
      minInvestment: '₹1,00,000',
      ratingColor: const Color(0xFF38BDF8),
    ),
    BondItem(
      title: 'NABARD AAA Rural Infrastructure Bond',
      issuer: 'National Bank for Agriculture and Rural Dev.',
      category: 'Corporate AAA',
      ytm: '7.62% p.a.',
      coupon: '7.58% Annual',
      tenure: '4.8 Years',
      rating: 'ICRA AAA',
      minInvestment: '₹20,000',
      ratingColor: const Color(0xFF38BDF8),
    ),
    BondItem(
      title: 'REC Ltd 54EC Capital Gain Exemption Bond',
      issuer: 'Rural Electrification Corporation',
      category: 'Corporate AAA',
      ytm: '5.25% p.a.',
      coupon: '5.25% Annual (Tax Free)',
      tenure: '5.0 Years',
      rating: 'CARE AAA',
      minInvestment: '₹20,000',
      ratingColor: const Color(0xFFF59E0B),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BondItem> get _filteredBonds {
    final query = _searchController.text.trim().toLowerCase();
    return _allBonds.where((bond) {
      final matchesCat =
          _selectedCategory == 'All' || bond.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          bond.title.toLowerCase().contains(query) ||
          bond.issuer.toLowerCase().contains(query) ||
          bond.rating.toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBonds;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: DashboardAppBar(
        title: 'Bonds & Fixed Income Intelligence',
        onMenuPressed: widget.onMenuPressed,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🇮🇳', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'RBI Retail Direct & Indian Debt Market',
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
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'SOVEREIGN / AAA',
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
                  'Central Government Securities (G-Secs), State SDLs, T-Bills, and AAA Corporate Debt mapped exclusively to Indian exchanges.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Search Field
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search bond, issuer (e.g. Tamil Nadu, T-Bill, REC)...',
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
                vertical: 8,
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
          const SizedBox(height: 8),

          // Category Filter Chips
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected ? Colors.black : const Color(0xFF94A3B8),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFF1E293B),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : const Color(0xFF334155),
                  ),
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Filtered Bonds List
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              alignment: Alignment.center,
              child: const Text(
                'No matching bonds or securities found',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            )
          else
            for (final bond in filtered) ...[
              _buildBondTile(bond),
              const SizedBox(height: 6),
            ],

          const SizedBox(height: 12),
          const RegulatoryDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildBondTile(BondItem bond) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bond.ratingColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: bond.ratingColor,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bond.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bond.issuer,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: bond.ratingColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  bond.rating,
                  style: TextStyle(
                    color: bond.ratingColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricBlock('Indicative YTM', bond.ytm, const Color(0xFF10B981)),
              _metricBlock('Coupon Rate', bond.coupon, const Color(0xFF38BDF8)),
              _metricBlock('Tenure', bond.tenure, const Color(0xFFA78BFA)),
              _metricBlock('Min Outlay', bond.minInvestment, Colors.white70),
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
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class BondItem {
  final String title;
  final String issuer;
  final String category;
  final String ytm;
  final String coupon;
  final String tenure;
  final String rating;
  final String minInvestment;
  final Color ratingColor;

  BondItem({
    required this.title,
    required this.issuer,
    required this.category,
    required this.ytm,
    required this.coupon,
    required this.tenure,
    required this.rating,
    required this.minInvestment,
    required this.ratingColor,
  });
}
