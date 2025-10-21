import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Simulated SSO login - replace with real SSO/OAuth call later.
  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay / SSO handshake
      await Future.delayed(const Duration(seconds: 2));

      // Temporary local validation - for testing
      if (username == 'user@amerck.com' && password == 'password123') {
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _errorMessage = 'Invalid username or password';
      }
    } catch (e) {
      _errorMessage = 'Login failed. Try again.';
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
