import 'package:shared_preferences/shared_preferences.dart';

class ProService {
  static const String _keyIsPro = 'is_pro_unlocked';
  static const String _keyPlanName = 'pro_plan_name';
  static const String _keyUtr = 'pro_registered_utr';

  /// Check if the user currently has Pro access
  static Future<bool> isProUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPro) ?? false;
  }

  /// Activate Pro access locally
  static Future<void> activatePro({
    required String planName,
    required String utr,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPro, true);
    await prefs.setString(_keyPlanName, planName);
    await prefs.setString(_keyUtr, utr);
  }

  /// Get current active plan name
  static Future<String?> getActivePlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPlanName);
  }

  /// Reset to Free tier (useful for debugging/testing)
  static Future<void> resetToFree() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsPro);
    await prefs.remove(_keyPlanName);
    await prefs.remove(_keyUtr);
  }
}
