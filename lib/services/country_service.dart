import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/country_model.dart';
import 'tax_rate_service.dart';

class CountryService {
  static const String _apiUrl =
      'https://restcountries.com/v3.1/all?fields=name,cca2,currencies';
  static const String _cacheKey = 'corpus_planner_countries_cache';
  static const String _selectedCountryKey = 'corpus_planner_selected_country';

  /// Primary Loader: Local Storage Cache -> Web Fetch -> Comprehensive Base
  static Future<List<CountryModel>> getCountries() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Check cached list
    final String? cachedJson = prefs.getString(_cacheKey);
    if (cachedJson != null) {
      try {
        final List<dynamic> decoded = json.decode(cachedJson);
        List<CountryModel> cachedList = decoded
            .map((item) => CountryModel.fromJson(item))
            .toList();

        _fetchAndCacheFromWeb(prefs);
        return cachedList;
      } catch (_) {}
    }

    // 2. Try fetching from web or fallback to base economy list
    return await _fetchAndCacheFromWeb(prefs);
  }

  static Future<List<CountryModel>> _fetchAndCacheFromWeb(
    SharedPreferences prefs,
  ) async {
    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);

        List<CountryModel> countries = rawData
            .map((item) => CountryModel.fromRestCountriesJson(item))
            .toList();

        countries.sort((a, b) => a.name.compareTo(b.name));

        final String encoded = json.encode(
          countries.map((c) => c.toJson()).toList(),
        );
        await prefs.setString(_cacheKey, encoded);

        return countries;
      }
    } catch (_) {}

    // Fallback if browser CORS blocks external API
    return _getDefaultEconomies();
  }

  static Future<void> saveSelectedCountry(CountryModel country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCountryKey, json.encode(country.toJson()));
  }

  static Future<CountryModel?> getSavedCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString(_selectedCountryKey);
    if (saved != null) {
      try {
        return CountryModel.fromJson(json.decode(saved));
      } catch (_) {}
    }
    return null;
  }

  /// Comprehensive baseline dataset for major financial markets with verified statutory tax rates
  static List<CountryModel> _getDefaultEconomies() {
    return [
      CountryModel(
        name: 'India',
        code: 'IN',
        currencyCode: 'INR',
        currencySymbol: '₹',
        defaultInflation: 6.0,
        ltcgTaxRate: TaxRateService.getRateForCountry('IN'),
        taxLabel: TaxRateService.getLabelForCountry('IN'),
        sipLabel: 'Step-Up SIP',
        swpLabel: 'SWP Simulator',
      ),
      CountryModel(
        name: 'United States',
        code: 'US',
        currencyCode: 'USD',
        currencySymbol: '\$',
        defaultInflation: 3.0,
        ltcgTaxRate: TaxRateService.getRateForCountry('US'),
        taxLabel: TaxRateService.getLabelForCountry('US'),
        sipLabel: 'Recurring Auto-Invest',
        swpLabel: 'Retirement Drawdown',
      ),
      CountryModel(
        name: 'United Kingdom',
        code: 'GB',
        currencyCode: 'GBP',
        currencySymbol: '£',
        defaultInflation: 2.5,
        ltcgTaxRate: TaxRateService.getRateForCountry('GB'),
        taxLabel: TaxRateService.getLabelForCountry('GB'),
        sipLabel: 'Regular Monthly Savings',
        swpLabel: 'Pension Drawdown',
      ),
      CountryModel(
        name: 'Germany / Eurozone',
        code: 'DE',
        currencyCode: 'EUR',
        currencySymbol: '€',
        defaultInflation: 2.2,
        ltcgTaxRate: TaxRateService.getRateForCountry('DE'),
        taxLabel: TaxRateService.getLabelForCountry('DE'),
        sipLabel: 'Monthly Investment Plan',
        swpLabel: 'Retirement Drawdown',
      ),
      CountryModel(
        name: 'Australia',
        code: 'AU',
        currencyCode: 'AUD',
        currencySymbol: 'A\$',
        defaultInflation: 3.0,
        ltcgTaxRate: TaxRateService.getRateForCountry('AU'),
        taxLabel: TaxRateService.getLabelForCountry('AU'),
        sipLabel: 'Regular Investment Plan',
        swpLabel: 'Super Drawdown',
      ),
      CountryModel(
        name: 'Canada',
        code: 'CA',
        currencyCode: 'CAD',
        currencySymbol: 'C\$',
        defaultInflation: 2.8,
        ltcgTaxRate: TaxRateService.getRateForCountry('CA'),
        taxLabel: TaxRateService.getLabelForCountry('CA'),
        sipLabel: 'Systematic Investment Plan',
        swpLabel: 'RRIF Drawdown',
      ),
      CountryModel(
        name: 'Singapore',
        code: 'SG',
        currencyCode: 'SGD',
        currencySymbol: 'S\$',
        defaultInflation: 2.0,
        ltcgTaxRate: TaxRateService.getRateForCountry('SG'),
        taxLabel: TaxRateService.getLabelForCountry('SG'),
        sipLabel: 'Monthly Investment Plan',
        swpLabel: 'CPF Drawdown',
      ),
      CountryModel(
        name: 'United Arab Emirates',
        code: 'AE',
        currencyCode: 'AED',
        currencySymbol: 'AED ',
        defaultInflation: 2.5,
        ltcgTaxRate: TaxRateService.getRateForCountry('AE'),
        taxLabel: TaxRateService.getLabelForCountry('AE'),
        sipLabel: 'Systematic Investment',
        swpLabel: 'Retirement Savings Drawdown',
      ),
      CountryModel(
        name: 'Japan',
        code: 'JP',
        currencyCode: 'JPY',
        currencySymbol: '¥',
        defaultInflation: 1.5,
        ltcgTaxRate: TaxRateService.getRateForCountry('JP'),
        taxLabel: TaxRateService.getLabelForCountry('JP'),
        sipLabel: 'Monthly Savings Plan',
        swpLabel: 'Pension Drawdown',
      ),
      CountryModel(
        name: 'Switzerland',
        code: 'CH',
        currencyCode: 'CHF',
        currencySymbol: 'CHF ',
        defaultInflation: 1.5,
        ltcgTaxRate: TaxRateService.getRateForCountry('CH'),
        taxLabel: TaxRateService.getLabelForCountry('CH'),
        sipLabel: 'Recurring Investment',
        swpLabel: 'Pillar 3a Drawdown',
      ),
    ];
  }
}
