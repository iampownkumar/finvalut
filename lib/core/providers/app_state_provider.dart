import 'package:flutter/material.dart';

class AppStateProvider extends ChangeNotifier {
  int _currentBottomNavIndex = 0;
  bool _isLoading = false;
  String? _error;

  int get currentBottomNavIndex => _currentBottomNavIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setBottomNavIndex(int index) {
    _currentBottomNavIndex = index;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
