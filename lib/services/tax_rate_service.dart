class TaxRateService {
  static final Map<String, Map<String, dynamic>> _taxData = {
    'IN': {'rate': 12.5, 'label': '12.5% LTCG'},
    'GB': {'rate': 24.0, 'label': '24% Higher-Rate CGT'},
    'UK': {'rate': 24.0, 'label': '24% Higher-Rate CGT'},
    'US': {'rate': 15.0, 'label': '15% Federal LTCG'},
    'DE': {'rate': 26.375, 'label': '26.38% Abgeltungsteuer'},
    'AU': {'rate': 22.5, 'label': '22.5% Effective CGT'},
    'CA': {'rate': 16.5, 'label': '50% Inclusion CGT'},
    'SG': {'rate': 0.0, 'label': '0% Capital Gains'},
    'AE': {'rate': 0.0, 'label': '0% Personal Income/CGT'},
    'JP': {'rate': 20.315, 'label': '20.32% National/Local Tax'},
    'CH': {'rate': 0.0, 'label': '0% Tax (Private Assets)'},
  };

  static double getRateForCountry(String countryCode) {
    final code = countryCode.toUpperCase();
    if (_taxData.containsKey(code)) {
      return (_taxData[code]!['rate'] as num).toDouble();
    }
    return 15.0; // Default international estimate
  }

  static String getLabelForCountry(String countryCode) {
    final code = countryCode.toUpperCase();
    if (_taxData.containsKey(code)) {
      return _taxData[code]!['label'] as String;
    }
    return '15% Est. CGT';
  }
}
