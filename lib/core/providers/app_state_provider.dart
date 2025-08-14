import 'package:flutter/material.dart';

class AppStateProvider extends ChangeNotifier {
  int _currentBottomNavIndex = 0;
  bool _isLoading = false;
  String? _error;

  // Global data version to notify listeners to refresh data-bound screens
  int _dataVersion = 0;
  int get dataVersion => _dataVersion;

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

  // Call this after any data mutation (e.g., adding/updating/deleting transactions)
  void bumpDataVersion() {
    _dataVersion++;
    notifyListeners();
  }
}
