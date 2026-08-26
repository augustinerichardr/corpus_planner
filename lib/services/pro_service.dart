import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProService {
  // Temporarily forced to true for the review and testing phase
  static final ValueNotifier<bool> isProNotifier = ValueNotifier<bool>(true);

  /// Load initial Pro status from SharedPreferences
  static Future<void> init() async {
    // Temporarily forced to true
    isProNotifier.value = true;

    // Uncomment this original logic once your Google Play IAP is fully live:
    // final sp = await SharedPreferences.getInstance();
    // isProNotifier.value = sp.getBool('is_pro_unlocked') ?? false;
  }

  /// Update Pro status globally across all screens and notify listeners
  static Future<void> setProUnlocked(bool unlocked) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('is_pro_unlocked', unlocked);
    isProNotifier.value = unlocked;
  }

  /// Force refresh from storage (useful after verification checks)
  static Future<void> refresh() async {
    // Temporarily forced to true
    isProNotifier.value = true;

    // Uncomment this original logic once your Google Play IAP is fully live:
    // final sp = await SharedPreferences.getInstance();
    // isProNotifier.value = sp.getBool('is_pro_unlocked') ?? false;
  }
}
