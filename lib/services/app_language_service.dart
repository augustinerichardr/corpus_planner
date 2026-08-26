import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageService extends ChangeNotifier {
  static final AppLanguageService _instance = AppLanguageService._internal();
  factory AppLanguageService() => _instance;
  AppLanguageService._internal();

  static const String _geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  bool _isTranslating = false;
  bool get isTranslating => _isTranslating;

  bool get isProUser => true;
  int get freePreviewCountRemaining => 999;
  void unlockProAccess() {}

  Map<String, String> _activeTranslations = {};

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ta': 'தமிழ் (Tamil)',
    'hi': 'हिन्दी (Hindi)',
    'te': 'తెలుగు (Telugu)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'ml': 'മലയാളം (Malayalam)',
    'mr': 'मराठी (Marathi)',
    'bn': 'বাংলা (Bengali)',
    'gu': 'ગુજરાતી (Gujarati)',
    'zh': '中文 (Simplified Chinese)',
    'ja': '日本語 (Japanese)',
  };

  // Base English Dictionary (All UI & Educational content)
  static const Map<String, String> _baseEnglish = {
    // Navigation / Titles
    'title_planner': 'Wealth Planner',
    'title_networth': 'Net Worth Portfolio',
    'title_swp': 'SWP Simulator',
    'title_funds': 'Mutual Funds Screener',
    'title_bonds': 'Bonds & Fixed Income',
    'title_arbitrage': 'Arbitrage Engine',
    'title_guide': 'Financial Guide',
    'title_settings': 'App Settings',

    // Arbitrage Module
    'arb_tabHeader': 'Arbitrage Funds (Tax-Advantaged Cash Parking)',
    'arb_howItWorksTitle':
        'How Arbitrage Mutual Funds Generate Zero-Risk Returns',
    'arb_marketNeutralBadge': 'Market Neutral',
    'arb_howItWorksDesc':
        'Arbitrage funds exploit price mispricings between Cash Equity and Futures Markets to lock in risk-free spreads.',
    'arb_step1Title': '1. Buy Cash Stock',
    'arb_step1Desc': 'Buy Reliance at ₹3,000 in the cash market.',
    'arb_step2Title': '2. Sell Month Future',
    'arb_step2Desc': 'Simultaneously sell Reliance Future at ₹3,020.',
    'arb_step3Title': '3. Locked Expiry Gain',
    'arb_step3Desc':
        '₹20 locked spread is captured on expiry regardless of market direction.',
    'arb_taxAlphaTitle':
        'Post-Tax Alpha Comparator: Arbitrage vs. Bank FD vs. Liquid Debt',
    'arb_taxBadge': '30% Tax Slab Basis',
    'arb_arbLtcgTitle': 'Arbitrage Fund (> 1 Year)',
    'arb_arbLtcgSub': '12.5% Equity LTCG Rate',
    'arb_arbStcgTitle': 'Arbitrage Fund (< 1 Year)',
    'arb_arbStcgSub': '20% Equity STCG Rate',
    'arb_bankFdTitle': 'Bank Fixed Deposit (FD)',
    'arb_bankFdSub': 'Taxed at 30% Slab Rate',
    'arb_liquidDebtTitle': 'Liquid / Debt Fund',
    'arb_liquidDebtSub': 'Taxed at 30% Slab Rate',
    'arb_topFundsHeader': 'Top Direct Arbitrage Funds in India',
    'arb_topFundsBadge': 'Zero Lock-In',

    // Bonds Module
    'bond_tabHeader': 'How Bonds Work & RBI Retail Direct',
    'bond_basicsTitle': 'What is a Bond & How Fixed Income Works?',
    'bond_basicsBadge': 'Fixed Income 101',
    'bond_basicsDesc':
        'A Bond is a formal debt instrument where you lend money to the Government or Corporation at a fixed coupon rate.',
    'bond_faceValueTitle': 'Face Value (Par)',
    'bond_faceValueDesc': 'The nominal value of the bond repaid at maturity.',
    'bond_couponTitle': 'Coupon Rate',
    'bond_couponDesc':
        'The fixed annual percentage interest paid on the face value.',
    'bond_cleanDirtyTitle': 'Clean vs Dirty Price',
    'bond_cleanDirtyDesc':
        'Clean price is the quoted price; dirty includes accrued interest.',
    'bond_trivia':
        'The oldest functioning bond in the world was issued in 1648 and still pays interest today!',
    'bond_ytmTitle': 'Coupon Rate vs. YTM (Yield to Maturity)',
    'bond_ytmBadge': 'Valuation Metric',
    'bond_couponNominalTitle': 'Coupon Rate (Nominal Interest)',
    'bond_couponNominalB1':
        'Fixed annual cash payout printed on the certificate.',
    'bond_couponNominalB2':
        'Does not account for purchase discount or premium.',
    'bond_ytmRealTitle': 'YTM (Yield to Maturity)',
    'bond_ytmRealB1':
        'The true internal rate of return (IRR) if held until maturity.',
    'bond_ytmRealB2': 'Accounts for coupon payouts and capital gains at par.',
    'bond_seesawRule': 'Bond Prices and Yields move in opposite directions.',
    'bond_ratingTitle': 'Credit Rating Safety Ladder',
    'bond_ratingBadge': 'Risk Matrix',
    'bond_ratingSub':
        'Ratings assigned by SEBI-registered agencies (CRISIL, ICRA, CARE):',
    'bond_sovTitle': 'SOV (Sovereign)',
    'bond_sovDesc': '0.00% Default Risk · Central G-Secs, T-Bills, State SDLs',

    // Mutual Funds Module
    'mf_basicsTitle': 'What is a Mutual Fund & How Does It Work?',
    'mf_basicsBadge': 'Basics 101',
    'mf_basicsDesc':
        'A Mutual Fund pools money from retail investors to purchase a professionally managed portfolio of stocks or bonds.',
    'mf_unitsTitle': 'Units',
    'mf_unitsDesc':
        'Fractional ownership allocated per your investment amount.',
    'mf_navTitle': 'NAV (Net Asset Value)',
    'mf_navDesc':
        'Market value of 1 unit, recalculated daily at 11 PM by AMFI.',
    'mf_diversificationTitle': 'Instant Diversification',
    'mf_diversificationDesc':
        'A ₹500 SIP spreads your risk across 50+ companies.',
    'mf_trivia':
        'The world\'s first mutual fund was formed in 1774 in the Netherlands.',
    'mf_growthVsIdcwTitle': 'Growth vs. IDCW (Dividend Payout)',
    'mf_growthVsIdcwBadge': 'Compounding Option',
    'mf_growthTitle': 'Growth Option (Recommended)',
    'mf_growthB1': 'Profits automatically reinvest back into the fund.',
    'mf_growthB2': '100% uninterrupted exponential compounding.',
    'mf_growthB3': 'Zero annual tax; tax deferred until redemption.',
    'idcwTitle': 'IDCW Option (Income Distribution)',
    'idcwB1': 'Periodically pulls cash out of your NAV to your bank.',
    'idcwB2': 'NAV drops on payout record dates.',
    'idcwB3': 'Added to your annual income and taxed at your slab rate.',
    'mf_buffettTrivia':
        'Keeping 100% of profits in the fund compounds wealth exponentially over time.',
    'mf_roadmapTitle': '3-Step Broker-Free Roadmap: How to Start Direct SIPs',
    'mf_step1Num': '01',
    'mf_step1Tag': 'One-Time',
    'mf_step1Title': 'Paperless e-KYC',
    'mf_step1Desc': 'Complete 3-min digital identity check online.',
    'mf_step2Num': '02',
    'mf_step2Tag': '100% Value',
    'mf_step2Title': 'Pick "Direct - Growth"',
    'mf_step2Desc':
        'Always ensure the scheme title has "Direct" to bypass intermediary commission.',
    'mf_step3Num': '03',
    'mf_step3Tag': 'Automated',
    'mf_step3Title': 'Setup UPI AutoPay',
    'mf_step3Desc':
        'Automate a fixed monthly SIP date for hands-free discipline.',
  };

  String translate(String key) {
    if (_currentLanguage == 'en') return _baseEnglish[key] ?? key;
    return _activeTranslations[key] ?? _baseEnglish[key] ?? key;
  }

  List<String> get screenTitles => [
        translate('title_planner'),
        translate('title_networth'),
        translate('title_swp'),
        translate('title_funds'),
        translate('title_bonds'),
        translate('title_arbitrage'),
        translate('title_guide'),
        translate('title_settings'),
      ];

  Map<String, String> get arbitrageStrings => {
        'tabHeader': translate('arb_tabHeader'),
        'howItWorksTitle': translate('arb_howItWorksTitle'),
        'marketNeutralBadge': translate('arb_marketNeutralBadge'),
        'howItWorksDesc': translate('arb_howItWorksDesc'),
        'step1Title': translate('arb_step1Title'),
        'step1Desc': translate('arb_step1Desc'),
        'step2Title': translate('arb_step2Title'),
        'step2Desc': translate('arb_step2Desc'),
        'step3Title': translate('arb_step3Title'),
        'step3Desc': translate('arb_step3Desc'),
        'taxAlphaTitle': translate('arb_taxAlphaTitle'),
        'taxBadge': translate('arb_taxBadge'),
        'arbLtcgTitle': translate('arb_arbLtcgTitle'),
        'arbLtcgSub': translate('arb_arbLtcgSub'),
        'arbStcgTitle': translate('arb_arbStcgTitle'),
        'arbStcgSub': translate('arb_arbStcgSub'),
        'bankFdTitle': translate('arb_bankFdTitle'),
        'bankFdSub': translate('arb_bankFdSub'),
        'liquidDebtTitle': translate('arb_liquidDebtTitle'),
        'liquidDebtSub': translate('arb_liquidDebtSub'),
        'topFundsHeader': translate('arb_topFundsHeader'),
        'topFundsBadge': translate('arb_topFundsBadge'),
      };

  Map<String, String> get bondStrings => {
        'tabHeader': translate('bond_tabHeader'),
        'bondBasicsTitle': translate('bond_basicsTitle'),
        'bondBasicsBadge': translate('bond_basicsBadge'),
        'bondBasicsDesc': translate('bond_basicsDesc'),
        'faceValueTitle': translate('bond_faceValueTitle'),
        'faceValueDesc': translate('bond_faceValueDesc'),
        'couponTitle': translate('bond_couponTitle'),
        'couponDesc': translate('bond_couponDesc'),
        'cleanDirtyTitle': translate('bond_cleanDirtyTitle'),
        'cleanDirtyDesc': translate('bond_cleanDirtyDesc'),
        'trivia': translate('bond_trivia'),
        'ytmTitle': translate('bond_ytmTitle'),
        'ytmBadge': translate('bond_ytmBadge'),
        'couponNominalTitle': translate('bond_couponNominalTitle'),
        'couponNominalB1': translate('bond_couponNominalB1'),
        'couponNominalB2': translate('bond_couponNominalB2'),
        'ytmRealTitle': translate('bond_ytmRealTitle'),
        'ytmRealB1': translate('bond_ytmRealB1'),
        'ytmRealB2': translate('bond_ytmRealB2'),
        'seesawRule': translate('bond_seesawRule'),
        'ratingTitle': translate('bond_ratingTitle'),
        'ratingBadge': translate('bond_ratingBadge'),
        'ratingSub': translate('bond_ratingSub'),
        'sovTitle': translate('bond_sovTitle'),
        'sovDesc': translate('bond_sovDesc'),
      };

  Map<String, String> get mutualFundsStrings => {
        'mfBasicsTitle': translate('mf_basicsTitle'),
        'mfBasicsBadge': translate('mf_basicsBadge'),
        'mfBasicsDesc': translate('mf_basicsDesc'),
        'unitsTitle': translate('mf_unitsTitle'),
        'unitsDesc': translate('mf_unitsDesc'),
        'navTitle': translate('mf_navTitle'),
        'navDesc': translate('mf_navDesc'),
        'diversificationTitle': translate('mf_diversificationTitle'),
        'diversificationDesc': translate('mf_diversificationDesc'),
        'mfTrivia': translate('mf_trivia'),
        'growthVsIdcwTitle': translate('mf_growthVsIdcwTitle'),
        'growthVsIdcwBadge': translate('mf_growthVsIdcwBadge'),
        'growthTitle': translate('mf_growthTitle'),
        'growthB1': translate('mf_growthB1'),
        'growthB2': translate('mf_growthB2'),
        'growthB3': translate('mf_growthB3'),
        'idcwTitle': translate('idcwTitle'),
        'idcwB1': translate('idcwB1'),
        'idcwB2': translate('idcwB2'),
        'idcwB3': translate('idcwB3'),
        'buffettTrivia': translate('mf_buffettTrivia'),
        'roadmapTitle': translate('mf_roadmapTitle'),
        'step1Num': translate('mf_step1Num'),
        'step1Tag': translate('mf_step1Tag'),
        'step1Title': translate('mf_step1Title'),
        'step1Desc': translate('mf_step1Desc'),
        'step2Num': translate('mf_step2Num'),
        'step2Tag': translate('mf_step2Tag'),
        'step2Title': translate('mf_step2Title'),
        'step2Desc': translate('mf_step2Desc'),
        'step3Num': translate('mf_step3Num'),
        'step3Tag': translate('mf_step3Tag'),
        'step3Title': translate('mf_step3Title'),
        'step3Desc': translate('mf_step3Desc'),
      };

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('app_global_language') ?? 'en';
    if (savedLang != 'en') {
      await _loadLanguage(savedLang);
    }
  }

  Future<void> setLanguage(String langCode) async {
    if (!supportedLanguages.containsKey(langCode)) return;
    if (_currentLanguage == langCode && _activeTranslations.isNotEmpty) return;

    _currentLanguage = langCode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_global_language', langCode);

    if (langCode == 'en') {
      _activeTranslations = {};
      notifyListeners();
      return;
    }

    await _loadLanguage(langCode);
  }

  bool requestLanguageChange(String langCode, [BuildContext? context]) {
    setLanguage(langCode);
    return true;
  }

  Future<void> _loadLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'translation_cache_$langCode';
    final cachedJson = prefs.getString(cacheKey);

    if (cachedJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cachedJson);
        _activeTranslations = decoded.map((k, v) => MapEntry(k, v.toString()));
        notifyListeners();
        return;
      } catch (_) {}
    }

    await _translateWithLLM(langCode);
  }

  Future<void> _translateWithLLM(String targetLangCode) async {
    final targetLangName = supportedLanguages[targetLangCode] ?? targetLangCode;
    _isTranslating = true;
    notifyListeners();

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt = '''
You are a financial localization engine for India.
Translate the values in this JSON key-value dictionary into $targetLangName.
Keep standard Indian financial terms (SIP, SWP, NAV, LTCG, STCG, RBI, PPF, NPS, G-Sec, Index) accurate.
Keep all JSON keys identical. Output valid JSON only.

JSON:
${jsonEncode(_baseEnglish)}
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final rawText = response.text;

      if (rawText != null && rawText.isNotEmpty) {
        final Map<String, dynamic> parsed = jsonDecode(rawText);
        _activeTranslations = parsed.map((k, v) => MapEntry(k, v.toString()));

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('translation_cache_$targetLangCode',
            jsonEncode(_activeTranslations));
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }
}
