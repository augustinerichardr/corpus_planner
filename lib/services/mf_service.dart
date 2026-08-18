import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mutual_fund_model.dart';

class MFService {
  // Official free open AMFI / MFAPI endpoint
  static const String _baseUrl = 'https://api.mfapi.in/mf';

  // Curated master list of top popular AMFI funds for instant reliable fallback
  static final List<MutualFundScheme> _fallbackAmfiMaster = [
    MutualFundScheme(
      schemeCode: 120503,
      schemeName: 'SBI Small Cap Fund - Direct Plan - Growth',
    ),
    MutualFundScheme(
      schemeCode: 125497,
      schemeName: 'Nippon India Small Cap Fund - Direct Plan - Growth',
    ),
    MutualFundScheme(
      schemeCode: 125354,
      schemeName: 'Axis Small Cap Fund - Direct Plan - Growth',
    ),
    MutualFundScheme(
      schemeCode: 118989,
      schemeName: 'HDFC Small Cap Fund - Direct Plan - Growth',
    ),
    MutualFundScheme(
      schemeCode: 120505,
      schemeName: 'SBI Large & Midcap Fund - Direct Plan - Growth',
    ),
    MutualFundScheme(
      schemeCode: 120586,
      schemeName: 'ICICI Prudential Bluechip Fund - Direct Plan - Growth',
    ),
    MutualFundScheme(
      schemeCode: 122639,
      schemeName: 'Parag Parikh Flexi Cap Fund - Direct Plan - Growth',
    ),
    MutualFundScheme(
      schemeCode: 119598,
      schemeName: 'Mirae Asset Large Cap Fund - Direct Plan - Growth',
    ),
    MutualFundScheme(
      schemeCode: 120847,
      schemeName: 'Kotak Emerging Equity Fund - Direct Plan - Growth',
    ),
    MutualFundScheme(
      schemeCode: 120716,
      schemeName: 'Quant Active Fund - Direct Plan - Growth',
    ),
    MutualFundScheme(
      schemeCode: 120841,
      schemeName: 'UTI Nifty 50 Index Fund - Direct Plan - Growth',
    ),
    MutualFundScheme(
      schemeCode: 120166,
      schemeName: 'DSP Midcap Fund - Direct Plan - Growth',
    ),
    MutualFundScheme(
      schemeCode: 119062,
      schemeName: 'Tata Digital India Fund - Direct Plan - Growth',
    ),
    MutualFundScheme(
      schemeCode: 120251,
      schemeName: 'ICICI Prudential Multi-Asset Fund - Direct Plan - Growth',
    ),
  ];

  static Future<List<MutualFundScheme>> searchFunds(String query) async {
    final clean = query.trim().toLowerCase();
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(clean)}'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        if (data.isNotEmpty) {
          return data.map((j) => MutualFundScheme.fromJson(j)).toList();
        }
      }
    } catch (_) {}

    // Instant local AMFI filter if offline, blocked, or slow network
    return _fallbackAmfiMaster.where((s) {
      if (clean.isEmpty) return true;
      return s.schemeName.toLowerCase().contains(clean);
    }).toList();
  }

  static Future<MutualFundScheme> getFundDetails(MutualFundScheme fund) async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/${fund.schemeCode}'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final list = data['data'] as List<dynamic>? ?? [];
        if (list.isNotEmpty) {
          fund.nav = double.tryParse(list[0]['nav'].toString()) ?? 0.0;
          fund.date = list[0]['date'] ?? '';
        }
      }
    } catch (_) {}
    return fund;
  }
}
