import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static SettingsService get instance => _instance;

  ThemeMode _themeMode = ThemeMode.dark;
  double _fontScale = 1.0;
  String _defaultCurrency = 'INR (₹)';
  double _defaultStepUpPercent = 10.0;
  double _defaultExpectedReturn = 12.0;
  String _taxRegime = 'New Regime (FY 2025-26)';

  bool _isMonteCarloEnabled = false;
  bool _isMultiSegmentInflationEnabled = false;
  bool _isBlackSwanModeEnabled = false;
  bool _isTaxHarvestingEnabled = false;
  bool _isInstitutionalPdfEnabled = false;

  bool _isSorrEnabled = false;
  bool _isTaxAwareSwpEnabled = false;
  bool _isGuardrailsEnabled = false;
  bool _isSwpPdfEnabled = false;

  ThemeMode get themeMode => _themeMode;
  double get fontScale => _fontScale;
  String get defaultCurrency => _defaultCurrency;
  double get defaultStepUpPercent => _defaultStepUpPercent;
  double get defaultExpectedReturn => _defaultExpectedReturn;
  String get taxRegime => _taxRegime;
  bool get isOldRegime => _taxRegime.contains('Old Regime');

  bool get isMonteCarloEnabled => _isMonteCarloEnabled;
  bool get isMultiSegmentInflationEnabled => _isMultiSegmentInflationEnabled;
  bool get isBlackSwanModeEnabled => _isBlackSwanModeEnabled;
  bool get isTaxHarvestingEnabled => _isTaxHarvestingEnabled;
  bool get isInstitutionalPdfEnabled => _isInstitutionalPdfEnabled;

  bool get isSorrEnabled => _isSorrEnabled;
  bool get isTaxAwareSwpEnabled => _isTaxAwareSwpEnabled;
  bool get isGuardrailsEnabled => _isGuardrailsEnabled;
  bool get isSwpPdfEnabled => _isSwpPdfEnabled;

  bool get isIndianCurrency =>
      _defaultCurrency.contains('INR') || _defaultCurrency.contains('₹');

  static const List<String> supportedCurrencies = [
    'INR (₹)',
    'USD (\$)',
    'EUR (€)',
    'GBP (£)',
    'SGD (S\$)',
    'AED (د.إ)',
    'JPY (¥)',
    'CNY (¥)',
    'KRW (₩)',
    'MYR (RM)',
  ];

  String get currencySymbol {
    if (_defaultCurrency.contains('SGD')) return 'S\$';
    if (_defaultCurrency.contains('MYR')) return 'RM';
    if (_defaultCurrency.contains('JPY') || _defaultCurrency.contains('CNY')) {
      return '¥';
    }
    if (_defaultCurrency.contains('KRW')) return '₩';
    if (_defaultCurrency.contains('AED')) return '\u200EAED ';
    if (_defaultCurrency.contains('(') && _defaultCurrency.contains(')')) {
      return _defaultCurrency.split('(')[1].replaceAll(')', '').trim();
    }
    return '₹';
  }

  String formatCurrency(double val) {
    final sym = currencySymbol;
    if (isIndianCurrency) {
      if (val >= 10000000) {
        return '$sym${(val / 10000000).toStringAsFixed(2)} Cr';
      }
      if (val >= 100000) return '$sym${(val / 100000).toStringAsFixed(2)} L';
      if (val >= 1000) return '$sym${(val / 1000).toStringAsFixed(1)} K';
      return '$sym${val.round()}';
    }
    if (_defaultCurrency.contains('JPY') || _defaultCurrency.contains('KRW')) {
      if (val >= 1000000000) {
        return '$sym${(val / 1000000000).toStringAsFixed(2)}B';
      }
      if (val >= 1000000) return '$sym${(val / 1000000).toStringAsFixed(1)}M';
      if (val >= 1000) return '$sym${(val / 1000).toStringAsFixed(0)}K';
      return '$sym${val.round()}';
    }
    if (val >= 1000000000) {
      return '$sym${(val / 1000000000).toStringAsFixed(2)}B';
    }
    if (val >= 1000000) return '$sym${(val / 1000000).toStringAsFixed(2)}M';
    if (val >= 1000) return '$sym${(val / 1000).toStringAsFixed(1)}K';
    return '$sym${val.round()}';
  }

  double calculateAnnualHomeLoanTaxShield({
    required double annualInterestPaid,
    double taxSlabRate = 0.30,
  }) {
    const double maxInterestCap = 200000.0;
    final eligibleInterest = annualInterestPaid > maxInterestCap
        ? maxInterestCap
        : annualInterestPaid;
    return eligibleInterest * taxSlabRate;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 2;
    _themeMode = ThemeMode.values[themeIndex];
    _fontScale = prefs.getDouble('font_scale') ?? 1.0;
    _defaultCurrency = prefs.getString('default_currency') ?? 'INR (₹)';
    _defaultStepUpPercent = prefs.getDouble('default_step_up') ?? 10.0;
    _defaultExpectedReturn = prefs.getDouble('default_return') ?? 12.0;
    _taxRegime = prefs.getString('tax_regime') ?? 'New Regime (FY 2025-26)';

    _isMonteCarloEnabled = prefs.getBool('pro_monte_carlo') ?? false;
    _isMultiSegmentInflationEnabled =
        prefs.getBool('pro_multi_inflation') ?? false;
    _isBlackSwanModeEnabled = prefs.getBool('pro_black_swan') ?? false;
    _isTaxHarvestingEnabled = prefs.getBool('pro_tax_harvest') ?? false;
    _isInstitutionalPdfEnabled =
        prefs.getBool('pro_institutional_pdf') ?? false;

    _isSorrEnabled = prefs.getBool('pro_sorr') ?? false;
    _isTaxAwareSwpEnabled = prefs.getBool('pro_tax_aware_swp') ?? false;
    _isGuardrailsEnabled = prefs.getBool('pro_guardrails') ?? false;
    _isSwpPdfEnabled = prefs.getBool('pro_swp_pdf') ?? false;

    notifyListeners();
  }

  Future<void> setDefaultCurrency(String currency) async {
    _defaultCurrency = currency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_currency', currency);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_scale', scale);
  }

  Future<void> setDefaultReturn(double val) async {
    _defaultExpectedReturn = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('default_return', val);
  }

  Future<void> setDefaultStepUp(double val) async {
    _defaultStepUpPercent = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('default_step_up', val);
  }

  Future<void> setTaxRegime(String regime) async {
    _taxRegime = regime;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tax_regime', regime);
  }

  Future<void> setMonteCarloEnabled(bool value) async {
    _isMonteCarloEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pro_monte_carlo', value);
  }

  Future<void> setMultiSegmentInflationEnabled(bool value) async {
    _isMultiSegmentInflationEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pro_multi_inflation', value);
  }

  Future<void> setBlackSwanModeEnabled(bool value) async {
    _isBlackSwanModeEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pro_black_swan', value);
  }

  Future<void> setTaxHarvestingEnabled(bool value) async {
    _isTaxHarvestingEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pro_tax_harvest', value);
  }

  Future<void> setInstitutionalPdfEnabled(bool value) async {
    _isInstitutionalPdfEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pro_institutional_pdf', value);
  }

  Future<void> setSorrEnabled(bool value) async {
    _isSorrEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pro_sorr', value);
  }

  Future<void> setTaxAwareSwpEnabled(bool value) async {
    _isTaxAwareSwpEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pro_tax_aware_swp', value);
  }

  Future<void> setGuardrailsEnabled(bool value) async {
    _isGuardrailsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pro_guardrails', value);
  }

  Future<void> setSwpPdfEnabled(bool value) async {
    _isSwpPdfEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pro_swp_pdf', value);
  }
}
