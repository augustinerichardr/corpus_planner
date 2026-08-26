import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/mf_scheme_model.dart';
import '../../services/amfi_api_service.dart';
import 'realistic_mf_chart.dart';

class MfScreenerTabView extends StatefulWidget {
  const MfScreenerTabView({super.key});

  @override
  State<MfScreenerTabView> createState() => _MfScreenerTabViewState();
}

class _MfScreenerTabViewState extends State<MfScreenerTabView> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounceTimer;

  List<MfSchemeHeader> _schemes = [];
  bool _isLoadingList = false;

  MfSchemeDetail? _activeSchemeDetail;
  bool _isLoadingDetail = false;
  String _selectedTimeframe = '5Y';

  @override
  void initState() {
    super.initState();
    _performSearch('quant small cap');
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoadingList = true);
    final results = await AmfiApiService.searchSchemes(query);
    if (!mounted) return;

    setState(() {
      _schemes = results;
      _isLoadingList = false;
    });

    if (results.isNotEmpty) {
      _loadSchemeDetail(results.first.code);
    }
  }

  Future<void> _loadSchemeDetail(String schemeCode) async {
    setState(() => _isLoadingDetail = true);
    final detail = await AmfiApiService.fetchSchemeDetails(schemeCode);
    if (!mounted) return;

    setState(() {
      _activeSchemeDetail = detail;
      _isLoadingDetail = false;
    });
  }

  String _detectPlanType(String schemeName) {
    final upper = schemeName.toUpperCase();
    final isDirect = upper.contains('DIRECT');
    final isIdcw = upper.contains('IDCW') || upper.contains('DIVIDEND');

    if (isDirect && isIdcw) return 'Direct IDCW';
    if (isDirect && !isIdcw) return 'Direct Growth';
    if (!isDirect && isIdcw) return 'Regular IDCW';
    return 'Regular Growth';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 920;
          return isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 360, child: _buildScreenerSidebar()),
                    const SizedBox(width: 14),
                    Expanded(child: _buildSchemeDetailView()),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 480, child: _buildScreenerSidebar()),
                      const SizedBox(height: 14),
                      _buildSchemeDetailView(),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildScreenerSidebar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
            decoration: InputDecoration(
              hintText: 'Search 10,000+ schemes (SBI, quant, Tata...)',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 11.5),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF10B981),
                size: 17,
              ),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 15,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        _searchCtrl.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF0F172A),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 10,
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
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live AMFI Results (${_schemes.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isLoadingList)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Color(0xFF10B981),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _schemes.isEmpty
                ? const Center(
                    child: Text(
                      'No schemes found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: _schemes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, idx) {
                      final item = _schemes[idx];
                      final isSelected = _activeSchemeDetail != null &&
                          item.code == _activeSchemeDetail!.code;

                      return InkWell(
                        onTap: () => _loadSchemeDetail(item.code),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF10B981)
                                    .withValues(alpha: 0.12)
                                : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF334155),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'AMFI Code: ${item.code}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeDetailView() {
    if (_isLoadingDetail) {
      return Container(
        height: 380,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF10B981)),
        ),
      );
    }

    final s = _activeSchemeDetail;
    if (s == null) {
      return Container(
        height: 380,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: const Center(
          child: Text(
            'Select an AMFI scheme to load live NAV trajectory',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${s.fundHouse} • ${s.category}',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Live AMFI NAV & Dynamic Polyline Chart
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
                        const SizedBox(height: 2),
                        Text(
                          '₹${s.currentNav.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: ['1M', '6M', '1Y', '3Y', '5Y', 'MAX'].map((tf) {
                        final isSel = tf == _selectedTimeframe;
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: InkWell(
                            onTap: () =>
                                setState(() => _selectedTimeframe = tf),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tf,
                                style: TextStyle(
                                  color: isSel ? Colors.black : Colors.grey,
                                  fontSize: 9.5,
                                  fontWeight: isSel
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: RealisticMfChart(
                    key: ValueKey('${s.code}_$_selectedTimeframe'),
                    scheme: s,
                    timeframe: _selectedTimeframe,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Real Verified CAGRs with Tenure Safety
          Row(
            children: [
              _metricTile(
                '1Y Return',
                s.oneYearReturn != null
                    ? '${s.oneYearReturn! >= 0 ? '+' : ''}${s.oneYearReturn!.toStringAsFixed(1)}%'
                    : 'N/A (<1Y)',
                (s.oneYearReturn ?? 0) >= 0
                    ? const Color(0xFF10B981)
                    : Colors.red,
              ),
              const SizedBox(width: 8),
              _metricTile(
                '3Y CAGR',
                s.threeYearCagr != null
                    ? '${s.threeYearCagr! >= 0 ? '+' : ''}${s.threeYearCagr!.toStringAsFixed(1)}%'
                    : 'N/A (<3Y)',
                (s.threeYearCagr ?? 0) >= 0
                    ? const Color(0xFF10B981)
                    : Colors.red,
              ),
              const SizedBox(width: 8),
              _metricTile(
                '5Y CAGR',
                s.fiveYearCagr != null
                    ? '${s.fiveYearCagr! >= 0 ? '+' : ''}${s.fiveYearCagr!.toStringAsFixed(1)}%'
                    : 'N/A (<5Y)',
                (s.fiveYearCagr ?? 0) >= 0
                    ? const Color(0xFF10B981)
                    : Colors.red,
              ),
              const SizedBox(width: 8),
              _metricTile(
                'Since Inception',
                '${s.sinceInceptionCagr >= 0 ? '+' : ''}${s.sinceInceptionCagr.toStringAsFixed(1)}%',
                s.sinceInceptionCagr >= 0
                    ? const Color(0xFF38BDF8)
                    : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _detailColumn('Inception Date', s.inceptionDate),
                _detailColumn('Category', s.category),
                _detailColumn('AMFI Code', s.code),
                _detailColumn('Plan & Option', _detectPlanType(s.name)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 9.5),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailColumn(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 9.5),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
