import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/settings_service.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/regulatory_disclaimer.dart';

class ArbitrageScreen extends StatefulWidget {
  const ArbitrageScreen({super.key});

  @override
  State<ArbitrageScreen> createState() => _ArbitrageScreenState();
}

class _ArbitrageScreenState extends State<ArbitrageScreen> {
  final SettingsService _settings = SettingsService();

  // Cash Parking State
  double _surplusCorpus = 500000;
  double _taxBracket = 30.0;

  // Loan vs Equity State
  double _monthlySurplus = 25000;
  double _homeLoanRate = 8.5;
  double _equityCagr = 13.5;
  double _tenureYears = 12;

  // Fixed to Indian Rupees for all Indian Market arbitrage simulations
  String _formatRupees(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(2)} Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)} L';
    } else {
      return '₹${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: const DashboardAppBar(
            title: 'Arbitrage Engine & Spread Intelligence',
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 850;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 12,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 16),

                      // Responsive Split Layout
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildRadarCard(),
                                  const SizedBox(height: 16),
                                  _buildCashParkingCard(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: _buildLoanPrepaymentCard()),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildRadarCard(),
                            const SizedBox(height: 16),
                            _buildCashParkingCard(),
                            const SizedBox(height: 16),
                            _buildLoanPrepaymentCard(),
                          ],
                        ),

                      const SizedBox(height: 20),
                      const RegulatoryDisclaimer(),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.swap_horizontal_circle_rounded,
                      color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Market-Neutral Spread Capture',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'ZERO DIRECTIONAL RISK',
                  style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Simulate simultaneous Spot-Futures mispricings, tax-efficient short term cash parking, and home loan prepayment opportunity costs.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarCard() {
    final radarData = [
      {
        'name': 'RELIANCE',
        'spot': 2984.5,
        'fut': 3002.8,
        'spread': 18.30,
        'yield': '8.61%'
      },
      {
        'name': 'HDFCBANK',
        'spot': 1682.1,
        'fut': 1692.4,
        'spread': 10.30,
        'yield': '8.60%'
      },
      {
        'name': 'INFY',
        'spot': 1845.0,
        'fut': 1856.3,
        'spread': 11.30,
        'yield': '8.60%'
      },
      {
        'name': 'ICICIBANK',
        'spot': 1248.6,
        'fut': 1256.2,
        'spread': 7.60,
        'yield': '8.54%'
      },
      {
        'name': 'TCS',
        'spot': 4210.0,
        'fut': 4235.8,
        'spread': 25.80,
        'yield': '8.60%'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
              const Row(
                children: [
                  Icon(Icons.radar_rounded, color: Color(0xFF38BDF8), size: 18),
                  SizedBox(width: 8),
                  Text(
                    '1. Cash-Futures Basis Radar (NSE Expiry)',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text('Annualised',
                  style: TextStyle(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                      fontSize: 9)),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          ...radarData.map((data) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] as String,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        'Spot: ₹${data['spot']} | Fut: ₹${data['fut']}',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 9.5),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+₹${(data['spread'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text('26D Expiry',
                          style: TextStyle(
                              color: Color(0xFF64748B), fontSize: 9.5)),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${data['yield']} p.a.',
                      style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCashParkingCard() {
    double grossFdYield = 7.0;
    double netFdYield = grossFdYield * (1 - (_taxBracket / 100));
    double grossArbYield = 7.3;
    double netArbYield = grossArbYield * (1 - 0.125); // 12.5% LTCG

    double fdNetValue = _surplusCorpus * (netFdYield / 100);
    double arbNetValue = _surplusCorpus * (netArbYield / 100);
    double taxAlpha = arbNetValue - fdNetValue;

    return Container(
      padding: const EdgeInsets.all(16),
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
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded,
                      color: Color(0xFF10B981), size: 18),
                  SizedBox(width: 8),
                  Text(
                    '2. Cash Parking: Arb vs. Bank FD',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Tax Alpha (Sec 112A)',
                    style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Parked Surplus Corpus:',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5)),
              Text(_formatRupees(_surplusCorpus),
                  style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _surplusCorpus,
            min: 100000,
            max: 5000000,
            divisions: 49,
            activeColor: const Color(0xFF10B981),
            inactiveColor: const Color(0xFF0F172A),
            onChanged: (val) => setState(() => _surplusCorpus = val),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Your Income Tax Bracket: ${_taxBracket.toStringAsFixed(0)}% Slab',
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 11.5)),
              Text('${_taxBracket.toStringAsFixed(0)}%',
                  style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _taxBracket,
            min: 0,
            max: 30,
            divisions: 3,
            activeColor: const Color(0xFF38BDF8),
            inactiveColor: const Color(0xFF0F172A),
            onChanged: (val) => setState(() => _taxBracket = val),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bank FD Net (After Tax)',
                          style: TextStyle(
                              color: Color(0xFF64748B), fontSize: 10)),
                      const SizedBox(height: 4),
                      Text(_formatRupees(fdNetValue),
                          style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Taxed at ${_taxBracket.toStringAsFixed(0)}% Slab',
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 9)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Arbitrage Fund Net',
                          style: TextStyle(
                              color: Color(0xFF64748B), fontSize: 10)),
                      const SizedBox(height: 4),
                      Text(_formatRupees(arbNetValue),
                          style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      const Text('12.5% Equity LTCG Rate',
                          style:
                              TextStyle(color: Color(0xFF64748B), fontSize: 9)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Net Tax Alpha Advantage:',
                    style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold)),
                Text('+${_formatRupees(taxAlpha)} / year',
                    style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanPrepaymentCard() {
    int totalMonths = (_tenureYears * 12).toInt();
    double rLoan = (_homeLoanRate / 100) / 12;
    double rEq = (_equityCagr / 100) / 12;

    double prepaySavingsFv = _monthlySurplus *
        ((pow(1 + rLoan, totalMonths) - 1) / rLoan) *
        (1 + rLoan);
    double equityWealthFv =
        _monthlySurplus * ((pow(1 + rEq, totalMonths) - 1) / rEq) * (1 + rEq);
    double netSpread = equityWealthFv - prepaySavingsFv;

    List<FlSpot> prepaySpots = [];
    List<FlSpot> equitySpots = [];

    for (int year = 0; year <= _tenureYears; year++) {
      int m = year * 12;
      double pVal = m == 0
          ? 0
          : _monthlySurplus * ((pow(1 + rLoan, m) - 1) / rLoan) * (1 + rLoan);
      double eVal = m == 0
          ? 0
          : _monthlySurplus * ((pow(1 + rEq, m) - 1) / rEq) * (1 + rEq);
      prepaySpots.add(FlSpot(year.toDouble(), pVal));
      equitySpots.add(FlSpot(year.toDouble(), eVal));
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
              const Row(
                children: [
                  Icon(Icons.balance_rounded,
                      color: Color(0xFFA78BFA), size: 18),
                  SizedBox(width: 8),
                  Text(
                    '3. Loan Prepay vs. Equity SIP',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFA78BFA).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Opportunity Cost Model',
                    style: TextStyle(
                        color: Color(0xFFA78BFA),
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monthly Surplus Cash Flow:',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5)),
              Text(_formatRupees(_monthlySurplus),
                  style: const TextStyle(
                      color: Color(0xFFA78BFA),
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _monthlySurplus,
            min: 5000,
            max: 200000,
            divisions: 39,
            activeColor: const Color(0xFFA78BFA),
            inactiveColor: const Color(0xFF0F172A),
            onChanged: (val) => setState(() => _monthlySurplus = val),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Home Loan Rate: ${_homeLoanRate.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 11.5)),
              Text('Equity CAGR: ${_equityCagr.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _homeLoanRate,
                  min: 6.0,
                  max: 12.0,
                  divisions: 12,
                  activeColor: Colors.white60,
                  inactiveColor: const Color(0xFF0F172A),
                  onChanged: (val) => setState(() => _homeLoanRate = val),
                ),
              ),
              Expanded(
                child: Slider(
                  value: _equityCagr,
                  min: 8.0,
                  max: 18.0,
                  divisions: 20,
                  activeColor: const Color(0xFF10B981),
                  inactiveColor: const Color(0xFF0F172A),
                  onChanged: (val) => setState(() => _equityCagr = val),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Remaining Tenure (Years):',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5)),
              Text('${_tenureYears.toStringAsFixed(0)} Yrs',
                  style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _tenureYears,
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: const Color(0xFF38BDF8),
            inactiveColor: const Color(0xFF0F172A),
            onChanged: (val) => setState(() => _tenureYears = val),
          ),
          const SizedBox(height: 12),

          // Dynamic Opportunity Cost Trajectory Graph
          Container(
            height: 140,
            padding:
                const EdgeInsets.only(right: 16, left: 4, top: 16, bottom: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: _tenureYears > 10 ? 5 : 2,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == _tenureYears) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text('Year ${value.toInt()}',
                              style: const TextStyle(
                                  color: Color(0xFF64748B), fontSize: 9)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isEquity = spot.barIndex == 0;
                        return LineTooltipItem(
                          '${isEquity ? "Equity" : "Loan Prepay"}: ${_formatRupees(spot.y)}',
                          TextStyle(
                            color: isEquity
                                ? const Color(0xFF10B981)
                                : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: equitySpots,
                    isCurved: true,
                    color: const Color(0xFF10B981),
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: prepaySpots,
                    isCurved: true,
                    color: Colors.white54,
                    barWidth: 2,
                    dashArray: [4, 4],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Opportunity Val (Prepay)',
                          style: TextStyle(
                              color: Color(0xFF64748B), fontSize: 10)),
                      const SizedBox(height: 4),
                      Text(_formatRupees(prepaySavingsFv),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                          'Guaranteed ${_homeLoanRate.toStringAsFixed(1)}% Base',
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 9)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Wealth Generated (Equity)',
                          style: TextStyle(
                              color: Color(0xFF64748B), fontSize: 10)),
                      const SizedBox(height: 4),
                      Text(_formatRupees(equityWealthFv),
                          style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Compounded at ${_equityCagr.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 9)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFA78BFA).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFFA78BFA).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Net Wealth Opportunity Spread:',
                    style: TextStyle(
                        color: Color(0xFFA78BFA),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold)),
                Text('+${_formatRupees(netSpread)}',
                    style: const TextStyle(
                        color: Color(0xFFA78BFA),
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
