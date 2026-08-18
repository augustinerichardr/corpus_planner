import 'dart:convert';

class MutualFundScheme {
  final int schemeCode;
  final String schemeName;
  double? nav;
  String? date;

  // Portfolio tracking & allocation state
  bool isAdded;
  double allocatedSip;
  String category;

  MutualFundScheme({
    required this.schemeCode,
    required this.schemeName,
    this.nav,
    this.date,
    this.isAdded = false,
    this.allocatedSip = 0.0,
    String? category,
  }) : category = category ?? _deriveCategory(schemeName);

  /// Helper to categorize schemes dynamically based on scheme name keywords
  static String _deriveCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('small cap') || lower.contains('smallcap')) {
      return 'Small Cap Equity';
    } else if (lower.contains('mid cap') || lower.contains('midcap')) {
      return 'Mid Cap Equity';
    } else if (lower.contains('large') || lower.contains('bluechip')) {
      return 'Large Cap Equity';
    } else if (lower.contains('flexi') || lower.contains('multi')) {
      return 'Flexi/Multi Cap';
    } else if (lower.contains('elss') || lower.contains('tax')) {
      return 'ELSS Tax Saver';
    } else if (lower.contains('liquid') ||
        lower.contains('debt') ||
        lower.contains('bond')) {
      return 'Debt / Liquid';
    } else if (lower.contains('index') ||
        lower.contains('nifty') ||
        lower.contains('sensex')) {
      return 'Index Fund';
    }
    return 'Equity / Growth';
  }

  factory MutualFundScheme.fromJson(Map<String, dynamic> json) {
    return MutualFundScheme(
      schemeCode: json['schemeCode'] is int
          ? json['schemeCode'] as int
          : int.tryParse(json['schemeCode']?.toString() ?? '0') ?? 0,
      schemeName: json['schemeName'] as String? ?? 'Unknown Scheme',
      nav: (json['nav'] as num?)?.toDouble(),
      date: json['date'] as String?,
      isAdded: json['isAdded'] as bool? ?? false,
      allocatedSip: (json['allocatedSip'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemeCode': schemeCode,
    'schemeName': schemeName,
    'nav': nav,
    'date': date,
    'isAdded': isAdded,
    'allocatedSip': allocatedSip,
    'category': category,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MutualFundScheme &&
          runtimeType == other.runtimeType &&
          schemeCode == other.schemeCode;

  @override
  int get hashCode => schemeCode.hashCode;
}

// -------------------------------------------------------------
// Deep Analysis, Screener & Factsheet Extensions
// -------------------------------------------------------------

class FundHolding {
  final String stockName;
  final String sector;
  final double percentage;

  FundHolding({
    required this.stockName,
    required this.sector,
    required this.percentage,
  });
}

class FundManagerInfo {
  final String name;
  final String experienceYears;
  final String bio;
  final String otherFundsManaged;

  FundManagerInfo({
    required this.name,
    required this.experienceYears,
    required this.bio,
    required this.otherFundsManaged,
  });
}

class MutualFundDetails {
  final String id;
  final String name;
  final String amc;
  final String category;
  final String type;
  final double nav;
  final double aumInCr;
  final double expenseRatio;
  final String exitLoad;
  final DateTime launchDate;
  final String benchmark;
  final FundManagerInfo manager;
  final List<FundHolding> topHoldings;
  final Map<String, List<double>> chartHistories;
  final Map<String, double> returnsCagr;

  MutualFundDetails({
    required this.id,
    required this.name,
    required this.amc,
    required this.category,
    required this.type,
    required this.nav,
    required this.aumInCr,
    required this.expenseRatio,
    required this.exitLoad,
    required this.launchDate,
    required this.benchmark,
    required this.manager,
    required this.topHoldings,
    required this.chartHistories,
    required this.returnsCagr,
  });
}
