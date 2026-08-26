import 'package:shared_preferences/shared_preferences.dart';
import '../models/portfolio_snapshot_model.dart';

class PortfolioStorageService {
  static const String _snapshotsKey = 'corpus_planner_portfolio_snapshots_v1';

  static Future<List<PortfolioSnapshot>> getAllSnapshots() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? rawList = prefs.getStringList(_snapshotsKey);
    if (rawList == null || rawList.isEmpty) {
      return _getDefaultInitialPortfolio();
    }
    return rawList.map((s) => PortfolioSnapshot.fromJson(s)).toList()
      ..sort((a, b) => b.recordedDate.compareTo(a.recordedDate));
  }

  static Future<void> saveSnapshot(PortfolioSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final List<PortfolioSnapshot> all = await getAllSnapshots();
    all.removeWhere((s) => s.id == snapshot.id);
    all.insert(0, snapshot);
    final List<String> encoded = all.map((s) => s.toJson()).toList();
    await prefs.setStringList(_snapshotsKey, encoded);
  }

  static Future<void> deleteSnapshot(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<PortfolioSnapshot> all = await getAllSnapshots();
    all.removeWhere((s) => s.id == id);
    final List<String> encoded = all.map((s) => s.toJson()).toList();
    await prefs.setStringList(_snapshotsKey, encoded);
  }

  static List<PortfolioSnapshot> _getDefaultInitialPortfolio() {
    final now = DateTime.now();
    return [
      PortfolioSnapshot(
        id: 'snapshot_${now.millisecondsSinceEpoch}',
        recordedDate: now,
        note: 'Active Live Portfolio',
        assets: [
          AssetEntry(
            id: '1',
            name: 'Flexi & Large Cap MFs',
            category: 'Mutual Funds',
            currentVal: 1850000,
            monthlyContribution: 35000,
            expectedReturnPercent: 14.0,
          ),
          AssetEntry(
            id: '2',
            name: 'Mid & Small Cap MFs',
            category: 'Mutual Funds',
            currentVal: 950000,
            monthlyContribution: 15000,
            expectedReturnPercent: 16.0,
          ),
          AssetEntry(
            id: '3',
            name: 'Public Provident Fund (PPF)',
            category: 'PPF',
            currentVal: 850000,
            monthlyContribution: 12500,
            expectedReturnPercent: 7.1,
          ),
          AssetEntry(
            id: '4',
            name: 'National Pension System (NPS Tier-I)',
            category: 'NPS',
            currentVal: 1250000,
            monthlyContribution: 10000,
            expectedReturnPercent: 10.5,
          ),
          AssetEntry(
            id: '5',
            name: 'Employee Provident Fund (EPF/VPF)',
            category: 'EPF',
            currentVal: 1600000,
            monthlyContribution: 18000,
            expectedReturnPercent: 8.25,
          ),
          AssetEntry(
            id: '6',
            name: 'Sovereign Gold Bonds (SGB)',
            category: 'Gold / SGB',
            currentVal: 450000,
            monthlyContribution: 0,
            expectedReturnPercent: 9.0,
          ),
          AssetEntry(
            id: '7',
            name: 'Sukanya Samriddhi (SSY)',
            category: 'SSY',
            currentVal: 320000,
            monthlyContribution: 5000,
            expectedReturnPercent: 8.2,
          ),
        ],
        liabilities: [
          LiabilityEntry(
            id: 'l1',
            name: 'SBI Home Loan',
            loanType: 'Home Loan',
            principalRemaining: 2450000,
            interestRatePercent: 8.5,
            monthlyEmi: 28500,
            tenureRemainingMonths: 110,
          ),
          LiabilityEntry(
            id: 'l2',
            name: 'Car Loan (HDFC)',
            loanType: 'Car Loan',
            principalRemaining: 480000,
            interestRatePercent: 9.0,
            monthlyEmi: 14200,
            tenureRemainingMonths: 38,
          ),
        ],
      ),
    ];
  }
}
