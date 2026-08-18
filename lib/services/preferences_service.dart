import 'package:shared_preferences/shared_preferences.dart';

class StrategyPreferences {
  static Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'initialLumpSum': prefs.getDouble('initialLumpSum') ?? 500000,
      'monthlySip': prefs.getDouble('monthlySip') ?? 50000,
      'stepUpPercent': prefs.getDouble('stepUpPercent') ?? 10,
      'equityPercent': prefs.getDouble('equityPercent') ?? 70,
      'equityReturnPercent': prefs.getDouble('equityReturnPercent') ?? 14.0,
      'debtReturnPercent': prefs.getDouble('debtReturnPercent') ?? 7.5,
      'inflationPercent': prefs.getDouble('inflationPercent') ?? 6.0,
      'totalYears': prefs.getInt('totalYears') ?? 5,
    };
  }

  static Future<void> save(String key, double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, val);
  }
}
