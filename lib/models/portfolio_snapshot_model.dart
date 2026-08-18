import 'dart:convert';

class AssetEntry {
  final String id;
  final String name;
  final String
  category; // 'Mutual Funds', 'PPF', 'EPF', 'NPS', 'SSY', 'ULIP', 'Gold / SGB', 'Real Estate', 'FD / Savings'
  final double currentVal;
  final double monthlyContribution;
  final double expectedReturnPercent;

  AssetEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.currentVal,
    required this.monthlyContribution,
    required this.expectedReturnPercent,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'currentVal': currentVal,
    'monthlyContribution': monthlyContribution,
    'expectedReturnPercent': expectedReturnPercent,
  };

  factory AssetEntry.fromMap(Map<String, dynamic> map) => AssetEntry(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    category: map['category'] ?? 'Mutual Funds',
    currentVal: (map['currentVal'] as num).toDouble(),
    monthlyContribution: (map['monthlyContribution'] as num).toDouble(),
    expectedReturnPercent: (map['expectedReturnPercent'] as num).toDouble(),
  );
}

class LiabilityEntry {
  final String id;
  final String name;
  final String
  loanType; // 'Home Loan', 'Car Loan', 'Personal Loan', 'Education Loan', 'Other'
  final double principalRemaining;
  final double interestRatePercent;
  final double monthlyEmi;
  final int tenureRemainingMonths;

  LiabilityEntry({
    required this.id,
    required this.name,
    required this.loanType,
    required this.principalRemaining,
    required this.interestRatePercent,
    required this.monthlyEmi,
    required this.tenureRemainingMonths,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'loanType': loanType,
    'principalRemaining': principalRemaining,
    'interestRatePercent': interestRatePercent,
    'monthlyEmi': monthlyEmi,
    'tenureRemainingMonths': tenureRemainingMonths,
  };

  factory LiabilityEntry.fromMap(Map<String, dynamic> map) => LiabilityEntry(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    loanType: map['loanType'] ?? 'Home Loan',
    principalRemaining: (map['principalRemaining'] as num).toDouble(),
    interestRatePercent: (map['interestRatePercent'] as num).toDouble(),
    monthlyEmi: (map['monthlyEmi'] as num).toDouble(),
    tenureRemainingMonths: (map['tenureRemainingMonths'] as num).toInt(),
  );
}

class PortfolioSnapshot {
  final String id;
  final DateTime recordedDate;
  final String note;
  final List<AssetEntry> assets;
  final List<LiabilityEntry> liabilities;

  PortfolioSnapshot({
    required this.id,
    required this.recordedDate,
    required this.note,
    required this.assets,
    required this.liabilities,
  });

  double get totalAssets => assets.fold(0.0, (sum, a) => sum + a.currentVal);
  double get totalLiabilities =>
      liabilities.fold(0.0, (sum, l) => sum + l.principalRemaining);
  double get netWorth => totalAssets - totalLiabilities;
  double get totalMonthlySavings =>
      assets.fold(0.0, (sum, a) => sum + a.monthlyContribution);
  double get totalMonthlyEmi =>
      liabilities.fold(0.0, (sum, l) => sum + l.monthlyEmi);

  Map<String, dynamic> toMap() => {
    'id': id,
    'recordedDate': recordedDate.toIso8601String(),
    'note': note,
    'assets': assets.map((a) => a.toMap()).toList(),
    'liabilities': liabilities.map((l) => l.toMap()).toList(),
  };

  factory PortfolioSnapshot.fromMap(Map<String, dynamic> map) =>
      PortfolioSnapshot(
        id: map['id'] ?? '',
        recordedDate: DateTime.parse(map['recordedDate']),
        note: map['note'] ?? '',
        assets: (map['assets'] as List<dynamic>)
            .map((x) => AssetEntry.fromMap(x))
            .toList(),
        liabilities: (map['liabilities'] as List<dynamic>)
            .map((x) => LiabilityEntry.fromMap(x))
            .toList(),
      );

  String toJson() => jsonEncode(toMap());
  factory PortfolioSnapshot.fromJson(String source) =>
      PortfolioSnapshot.fromMap(jsonDecode(source));
}
