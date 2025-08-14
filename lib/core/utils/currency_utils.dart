import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatAmount(double amount, {String currency = 'INR'}) {
    if (currency == 'INR') {
      return '₹${NumberFormat('#,##,###.##').format(amount)}';
    } else if (currency == 'USD') {
      return '\$${NumberFormat('#,###.##').format(amount)}';
    }
    return '${amount.toStringAsFixed(2)}';
  }

  static String formatCompactAmount(double amount, {String currency = 'INR'}) {
    String symbol = currency == 'INR'
        ? '₹'
        : currency == 'USD'
            ? '\$'
            : '';

    if (amount >= 10000000) {
      // 1 crore
      return '$symbol${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      // 1 lakh
      return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      // 1 thousand
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
    String cleaned = amountString.replaceAll(RegExp(r'[₹\$,]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
