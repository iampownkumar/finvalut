import 'package:intl/intl.dart';

class CurrencyUtils {
  // Global current currency (default to INR)
  static String _currentCurrency = 'INR';

  static const Map<String, String> _symbols = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
  };

  // Set global current currency (called by a provider or settings)
  static void setCurrentCurrency(String code) {
    if (_symbols.containsKey(code)) {
      _currentCurrency = code;
    } else {
      _currentCurrency = 'INR';
    }
  }

  static String get currentCurrency => _currentCurrency;

  static String symbolFor([String? currency]) {
    final code = currency ?? _currentCurrency;
    return _symbols[code] ?? '';
  }

  static String formatAmount(double amount, {String? currency}) {
    final code = currency ?? _currentCurrency;
    final symbol = _symbols[code] ?? '';

    NumberFormat formatter;
    if (code == 'INR') {
      // Indian numbering system
      formatter = NumberFormat('#,##,###.00');
    } else {
      // Western grouping
      formatter = NumberFormat('#,###.00');
    }

    return '$symbol${formatter.format(amount)}';
  }

  static String formatCompactAmount(double amount, {String? currency}) {
    final code = currency ?? _currentCurrency;
    final symbol = _symbols[code] ?? '';

    if (code == 'INR') {
      // Use Lakh and Crore for INR
      if (amount >= 10000000) {
        return '$symbol${(amount / 10000000).toStringAsFixed(1)}Cr';
      } else if (amount >= 100000) {
        return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
      }
    }

    // Western compact formatting
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${amount.toStringAsFixed(0)}';
    }
  }

  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  static String getAmountColor(double amount, {bool isExpense = false}) {
    if (isExpense) {
      return amount > 0 ? '#EF4444' : '#6B7280'; // Red for expenses
    } else {
      return amount > 0
          ? '#10B981'
          : '#EF4444'; // Green for positive, red for negative
    }
  }

  static double parseAmount(String amountString) {
    // Remove currency symbols and commas
    String cleaned = amountString.replaceAll(RegExp(r'[₹\$€£,]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
