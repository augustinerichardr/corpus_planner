class MfSchemeHeader {
  final String code;
  final String name;

  const MfSchemeHeader({required this.code, required this.name});
}

class HistoricalNavPoint {
  final String dateStr;
  final double nav;

  const HistoricalNavPoint({required this.dateStr, required this.nav});
}

class MfSchemeDetail {
  final String code;
  final String name;
  final String fundHouse;
  final String category;
  final double currentNav;
  final double? oneYearReturn;
  final double? threeYearCagr;
  final double? fiveYearCagr;
  final double sinceInceptionCagr;
  final String inceptionDate;
  final List<HistoricalNavPoint> historyNewestFirst;

  const MfSchemeDetail({
    required this.code,
    required this.name,
    required this.fundHouse,
    required this.category,
    required this.currentNav,
    required this.oneYearReturn,
    required this.threeYearCagr,
    required this.fiveYearCagr,
    required this.sinceInceptionCagr,
    required this.inceptionDate,
    required this.historyNewestFirst,
  });
}
