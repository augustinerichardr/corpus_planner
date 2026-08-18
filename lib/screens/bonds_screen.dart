import 'package:flutter/material.dart';
import '../models/bond_model.dart';
import '../services/bonds_repository.dart';
import '../widgets/dashboard_app_bar.dart';

class BondsScreen extends StatefulWidget {
  const BondsScreen({super.key});

  @override
  State<BondsScreen> createState() => _BondsScreenState();
}

class _BondsScreenState extends State<BondsScreen> {
  String _selectedRatingFilter = 'All';
  String _selectedIssuerFilter = 'All';
  final List<BondModel> _bonds = BondsRepository.getBondsMarket();

  List<BondModel> get _filteredBonds {
    return _bonds.where((bond) {
      final matchesRating =
          _selectedRatingFilter == 'All' ||
          bond.creditRating.toUpperCase().contains(
            _selectedRatingFilter.toUpperCase(),
          );
      final matchesIssuer =
          _selectedIssuerFilter == 'All' ||
          bond.issuerType.toLowerCase().contains(
            _selectedIssuerFilter.toLowerCase(),
          );
      return matchesRating && matchesIssuer;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ratings = ['All', 'SOV', 'AAA', 'AA+', 'AA', 'A', 'BBB-'];
    final issuers = [
      'All',
      'Sovereign',
      'Public Sector',
      'Private Corporate',
      'NBFC',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: const DashboardAppBar(
        title: 'Indian Fixed Income & Bond Screener',
      ),
      body: Column(
        children: [
          // FILTER HEADER BAR
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Credit Rating Filter (SEBI Standardized)',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ratings.map((rating) {
                      final isSelected = _selectedRatingFilter == rating;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            rating,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF10B981),
                          backgroundColor: const Color(0xFF0F172A),
                          checkmarkColor: Colors.black,
                          onSelected: (_) =>
                              setState(() => _selectedRatingFilter = rating),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Issuer Category Filter',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: issuers.map((issuer) {
                      final isSelected = _selectedIssuerFilter == issuer;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            issuer,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF38BDF8),
                          backgroundColor: const Color(0xFF0F172A),
                          checkmarkColor: Colors.black,
                          onSelected: (_) =>
                              setState(() => _selectedIssuerFilter = issuer),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Matching Bonds (${_filteredBonds.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Yields referenced to daily market benchmarks',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // BONDS LIST
          Expanded(
            child: _filteredBonds.isEmpty
                ? const Center(
                    child: Text(
                      'No bonds match this credit rating or issuer filter.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBonds.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final bond = _filteredBonds[i];
                      final Color ratingColor = _getRatingColor(
                        bond.creditRating,
                      );

                      return Container(
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ratingColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: ratingColor.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    'Rating: ${bond.creditRating}',
                                    style: TextStyle(
                                      color: ratingColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  'YTM: ${bond.yieldToMaturity.toStringAsFixed(2)}% p.a.',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              bond.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Issuer: ${bond.issuerType} • Safety: ${bond.safetyLevel}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            const Divider(color: Colors.white10, height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _bondFact('Coupon', '${bond.couponRate}%'),
                                _bondFact(
                                  'Tenure',
                                  '${bond.tenureYears} Years',
                                ),
                                _bondFact('Payout', bond.frequency),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(String rating) {
    final upper = rating.toUpperCase();
    if (upper.contains('SOV') || upper.contains('AAA')) {
      return const Color(0xFF10B981);
    }
    if (upper.contains('AA')) return const Color(0xFF38BDF8);
    if (upper.contains('A')) return Colors.amberAccent;
    return Colors.redAccent;
  }

  Widget _bondFact(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9.5)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
