import 'package:intl/intl.dart';

String formatCompactCurrency(double amount) {
  if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
  if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(2)} L';
  return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(amount);
}
