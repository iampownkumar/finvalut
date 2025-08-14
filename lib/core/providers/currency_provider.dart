import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finvault/core/utils/currency_utils.dart';

class CurrencyProvider extends ChangeNotifier {
  static const String _currencyKey = 'global_currency_code';

  String _currencyCode = 'INR';
  String get currencyCode => _currencyCode;

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> setCurrency(String code) async {
    _currencyCode = code;
    CurrencyUtils.setCurrentCurrency(code);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, code);
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currencyCode = prefs.getString(_currencyKey) ?? 'INR';
    CurrencyUtils.setCurrentCurrency(_currencyCode);
    notifyListeners();
  }
}
