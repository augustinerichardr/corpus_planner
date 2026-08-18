class CountryModel {
  final String name;
  final String code; // e.g. "IN", "US", "GB"
  final String currencyCode; // e.g. "INR", "USD", "GBP"
  final String currencySymbol; // e.g. "₹", "$", "£"
  final double defaultInflation;
  final double ltcgTaxRate; // Capital Gains Tax rate
  final String taxLabel; // Label for metric card
  final String sipLabel;
  final String swpLabel;

  CountryModel({
    required this.name,
    required this.code,
    required this.currencyCode,
    required this.currencySymbol,
    required this.defaultInflation,
    double? ltcgTaxRate,
    String? taxLabel,
    required this.sipLabel,
    required this.swpLabel,
  }) : ltcgTaxRate = ltcgTaxRate ?? _getLtcgTaxRate(code),
       taxLabel = taxLabel ?? _getTaxLabel(code);

  factory CountryModel.fromRestCountriesJson(Map<String, dynamic> json) {
    final String countryCode = json['cca2'] ?? 'US';
    final String commonName = json['name']?['common'] ?? 'Unknown';

    String currCode = 'USD';
    String currSymbol = '\$';

    final currencies = json['currencies'] as Map<String, dynamic>?;
    if (currencies != null && currencies.isNotEmpty) {
      currCode = currencies.keys.first;
      currSymbol = currencies[currCode]?['symbol'] ?? currCode;
    }

    return CountryModel(
      name: commonName,
      code: countryCode,
      currencyCode: currCode,
      currencySymbol: currSymbol,
      defaultInflation: _getDefaultInflation(countryCode),
      ltcgTaxRate: _getLtcgTaxRate(countryCode),
      taxLabel: _getTaxLabel(countryCode),
      sipLabel: _getSipLabel(countryCode),
      swpLabel: _getSwpLabel(countryCode),
    );
  }

  static double _getLtcgTaxRate(String code) {
    switch (code.toUpperCase()) {
      case 'IN':
        return 12.5; // Indian LTCG
      case 'GB':
      case 'UK':
        return 24.0; // HMRC Capital Gains Tax (Higher Rate)
      case 'US':
        return 15.0; // US Federal LTCG
      case 'DE':
        return 26.375; // German Abgeltungsteuer (+ Soli)
      case 'AU':
        return 22.5; // Effective Australian CGT (50% Discount applied)
      case 'CA':
        return 16.5; // 50% Inclusion CGT
      case 'SG':
      case 'AE':
      case 'CH':
        return 0.0; // Zero CGT jurisdictions
      case 'JP':
        return 20.315; // Japanese National/Local Tax
      default:
        return 15.0; // Standard International Default
    }
  }

  static String _getTaxLabel(String code) {
    switch (code.toUpperCase()) {
      case 'IN':
        return '12.5% LTCG';
      case 'GB':
      case 'UK':
        return '24% CGT';
      case 'US':
        return '15% Federal LTCG';
      case 'DE':
        return '26.38% Abgeltungsteuer';
      case 'AU':
        return '22.5% Effective CGT';
      case 'CA':
        return '50% Inclusion CGT';
      case 'SG':
        return '0% Capital Gains';
      case 'AE':
        return '0% Personal Tax';
      case 'CH':
        return '0% Private Assets Tax';
      case 'JP':
        return '20.32% CGT';
      default:
        return '15% Est. CGT';
    }
  }

  static String _getSipLabel(String code) {
    switch (code.toUpperCase()) {
      case 'IN':
        return 'Step-Up SIP';
      case 'GB':
      case 'UK':
        return 'Regular Monthly Savings';
      case 'AU':
        return 'Regular Investment Plan';
      case 'DE':
        return 'Sparplan';
      default:
        return 'Recurring Auto-Invest';
    }
  }

  static String _getSwpLabel(String code) {
    switch (code.toUpperCase()) {
      case 'IN':
        return 'SWP Simulator';
      case 'GB':
      case 'UK':
        return 'Pension Drawdown';
      case 'AU':
        return 'Super Drawdown';
      case 'DE':
        return 'Entnahmeplan';
      default:
        return 'Retirement Drawdown';
    }
  }

  static double _getDefaultInflation(String code) {
    switch (code.toUpperCase()) {
      case 'IN':
        return 6.0;
      case 'GB':
      case 'UK':
      case 'EU':
      case 'DE':
        return 2.5;
      case 'US':
      case 'AU':
        return 3.0;
      case 'JP':
        return 1.5;
      default:
        return 3.0;
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'currencyCode': currencyCode,
    'currencySymbol': currencySymbol,
    'defaultInflation': defaultInflation,
    'ltcgTaxRate': ltcgTaxRate,
    'taxLabel': taxLabel,
    'sipLabel': sipLabel,
    'swpLabel': swpLabel,
  };

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    final String countryCode = json['code'] ?? 'US';

    return CountryModel(
      name: json['name'] ?? 'United States',
      code: countryCode,
      currencyCode: json['currencyCode'] ?? 'USD',
      currencySymbol: json['currencySymbol'] ?? '\$',
      defaultInflation:
          (json['defaultInflation'] as num?)?.toDouble() ??
          _getDefaultInflation(countryCode),
      ltcgTaxRate:
          (json['ltcgTaxRate'] as num?)?.toDouble() ??
          _getLtcgTaxRate(countryCode),
      taxLabel: json['taxLabel'] ?? _getTaxLabel(countryCode),
      sipLabel: json['sipLabel'] ?? _getSipLabel(countryCode),
      swpLabel: json['swpLabel'] ?? _getSwpLabel(countryCode),
    );
  }

  // Equality comparison for DropdownButton matching
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
