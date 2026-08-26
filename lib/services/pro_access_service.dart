import 'package:shared_preferences/shared_preferences.dart';

class ProAccessService {
  static const String _proKey = 'corpus_planner_pro_unlocked_v1';

  static Future<bool> isProUser() async {
    // Temporarily forced to true for review and testing phase
    return true;

    // Uncomment this original logic once your Google Play IAP is fully live:
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getBool(_proKey) ?? false;
  }

  static Future<void> setProUser(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_proKey, value);
  }
}
