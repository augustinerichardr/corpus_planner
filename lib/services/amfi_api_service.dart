import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/mf_scheme_model.dart';

class AmfiApiService {
  static const String _baseUrl = 'https://api.mfapi.in/mf';

  // In-memory cache to prevent repeated network calls
  static final Map<String, MfSchemeDetail> _detailCache = {};
  static List<MfSchemeHeader>? _allSchemesCache;

  /// Fetches all 10,000+ AMFI schemes list or returns from cache
  static Future<List<MfSchemeHeader>> searchSchemes(String query) async {
    try {
      if (_allSchemesCache == null) {
        final res = await http.get(Uri.parse(_baseUrl));
        if (res.statusCode == 200) {
          final List<dynamic> data = json.decode(res.body);
          _allSchemesCache = data
              .map(
                (item) => MfSchemeHeader(
                  code: item['schemeCode'].toString(),
                  name: item['schemeName'].toString(),
                ),
              )
              .toList();
        }
      }

      if (_allSchemesCache == null) return [];

      final q = query.trim().toLowerCase();
      if (q.isEmpty) {
        return _allSchemesCache!
            .where(
              (s) =>
                  s.name.contains('Direct') &&
                  (s.name.contains('Small Cap') ||
                      s.name.contains('Flexi Cap') ||
                      s.name.contains('Index Fund') ||
                      s.name.contains('Liquid')),
            )
            .take(25)
            .toList();
      }

      return _allSchemesCache!
          .where((s) => s.name.toLowerCase().contains(q) || s.code.contains(q))
          .take(30)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetches complete daily NAV history and calculates accurate return metrics
  static Future<MfSchemeDetail?> fetchSchemeDetails(String schemeCode) async {
    if (_detailCache.containsKey(schemeCode)) {
      return _detailCache[schemeCode];
    }

    try {
      final res = await http.get(Uri.parse('$_baseUrl/$schemeCode'));
      if (res.statusCode != 200) return null;

      final data = json.decode(res.body);
      final meta = data['meta'] ?? {};
      final List<dynamic> rawNavList = data['data'] ?? [];

      if (rawNavList.isEmpty) return null;

      // API returns newest first (index 0 = latest, last = inception)
      List<HistoricalNavPoint> points = [];
      for (var row in rawNavList) {
        final navVal = double.tryParse(row['nav'].toString()) ?? 0.0;
        if (navVal > 0) {
          points.add(
            HistoricalNavPoint(dateStr: row['date'].toString(), nav: navVal),
          );
        }
      }

      if (points.isEmpty) return null;

      final double latestNav = points.first.nav;
      final int totalDays = points.length;

      // Calculate Real CAGRs based on ~248 trading days/yr (returns null if fund tenure is shorter)
      double? oneYearReturn = _calculateCagr(points, latestNav, 248, 1.0);
      double? threeYearCagr = _calculateCagr(points, latestNav, 248 * 3, 3.0);
      double? fiveYearCagr = _calculateCagr(points, latestNav, 248 * 5, 5.0);

      final double oldestNav = points.last.nav;
      final double totalYears = max(0.1, totalDays / 248.0);
      double sinceInceptionCagr = oldestNav > 0
          ? (pow(latestNav / oldestNav, 1 / totalYears) - 1) * 100
          : 0.0;

      final detail = MfSchemeDetail(
        code: meta['scheme_code']?.toString() ?? schemeCode,
        name: meta['scheme_name'] ?? 'Mutual Fund Scheme',
        fundHouse: meta['fund_house'] ?? 'Asset Management Company',
        category: meta['scheme_category'] ?? meta['scheme_type'] ?? 'Equity',
        currentNav: latestNav,
        oneYearReturn: oneYearReturn,
        threeYearCagr: threeYearCagr,
        fiveYearCagr: fiveYearCagr,
        sinceInceptionCagr: sinceInceptionCagr,
        inceptionDate: points.last.dateStr,
        historyNewestFirst: points,
      );

      _detailCache[schemeCode] = detail;
      return detail;
    } catch (e) {
      return null;
    }
  }

  /// Calculates annualized CAGR. Returns null if fund trading history is shorter than target days.
  static double? _calculateCagr(
    List<HistoricalNavPoint> points,
    double currentNav,
    int targetTradingDays,
    double years,
  ) {
    if (points.length <= targetTradingDays) {
      return null;
    }
    final pastNav = points[targetTradingDays].nav;
    if (pastNav <= 0) return null;
    return ((pow(currentNav / pastNav, 1 / years) - 1) * 100).toDouble();
  }
}
