import 'package:shared_preferences/shared_preferences.dart';

class StrategyPreferences {
  static Future<Map<String, dynamic>> load() async {
    final p = await SharedPreferences.getInstance();
    return {
      'initialLumpSum': p.getDouble('initialLumpSum') ?? 500000.0,
      'monthlySip': p.getDouble('monthlySip') ?? 50000.0,
      'stepUpPercent': p.getDouble('stepUpPercent') ?? 10.0,
      'equityPercent': p.getDouble('equityPercent') ?? 70.0,
      'equityReturnPercent': p.getDouble('equityReturnPercent') ?? 14.0,
      'debtReturnPercent': p.getDouble('debtReturnPercent') ?? 7.5,
      'inflationPercent': p.getDouble('inflationPercent') ?? 6.0,
      'totalYears': p.getInt('totalYears') ?? 5,
    };
  }

  static Future<void> save(String key, double val) async {
    final p = await SharedPreferences.getInstance();
    if (key == 'totalYears') {
      p.setInt(key, val.toInt());
    } else {
      p.setDouble(key, val);
    }
  }
}
