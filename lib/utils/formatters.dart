import 'package:intl/intl.dart';

String formatCompactCurrency(
  double amount, {
  String symbol = '₹',
  String countryCode = 'IN',
}) {
  if (amount == 0) return '${symbol}0';

  // 1. Indian System (K, Lakhs, Crores & Thousand Crores)
  if (symbol == '₹' || countryCode == 'IN') {
    // Multi-thousand Crores (>= 10,000 Cr -> e.g. ₹54.89k Cr)
    if (amount >= 100000000000) {
      return '$symbol${_trimDecimals(amount / 100000000000)}k Cr';
    }
    // Crores (>= 1 Cr)
    if (amount >= 10000000) {
      return '$symbol${_trimDecimals(amount / 10000000)} Cr';
    }
    // Lakhs (>= 1 Lakh)
    if (amount >= 100000) {
      return '$symbol${_trimDecimals(amount / 100000)} L';
    }
    // Thousands (>= 1 Thousand) -> e.g. ₹50 K
    if (amount >= 1000) {
      return '$symbol${_trimDecimals(amount / 1000)} K';
    }

    final indianFormatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 0,
      locale: 'en_IN',
    );
    return indianFormatter.format(amount);
  }

  // 2. International System (K, M, B, T)
  if (amount >= 1000000000000) {
    return '$symbol${_trimDecimals(amount / 1000000000000)} T';
  }
  if (amount >= 1000000000) {
    return '$symbol${_trimDecimals(amount / 1000000000)} B';
  }
  if (amount >= 1000000) {
    return '$symbol${_trimDecimals(amount / 1000000)} M';
  }
  if (amount >= 1000) {
    return '$symbol${_trimDecimals(amount / 1000)} K';
  }

  final standardFormatter = NumberFormat.currency(
    symbol: symbol,
    decimalDigits: 0,
    locale: 'en_US',
  );
  return standardFormatter.format(amount);
}

/// Helper to trim to max 2 decimals without unnecessary trailing zeros
String _trimDecimals(double val) {
  String str = val.toStringAsFixed(2);
  if (str.endsWith('.00')) {
    return str.substring(0, str.length - 3);
  } else if (str.endsWith('0')) {
    return str.substring(0, str.length - 1);
  }
  return str;
}
