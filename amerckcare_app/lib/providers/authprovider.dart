import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token != null && token.isNotEmpty) {
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      // if secure storage isn't available for some reason, stay logged out
      _isAuthenticated = false;
    } finally {
      notifyListeners();
    }
  }

  /// Simulated username/password login for testing
  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2)); // simulate network

    if (username.trim() == 'user@amerck.com' && password == 'password123') {
      _isAuthenticated = true;
      // store a fake token so session persists across restarts
      await _secureStorage.write(key: 'access_token', value: 'demo_token');
    } else {
      _isAuthenticated = false;
      _errorMessage = 'Invalid username or password';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Placeholder SSO method.
  /// Currently NOT using flutter_appauth; this method either:
  ///  - performs the same simulated login for demo purposes, or
  ///  - sets a clear error telling devs SSO is not configured.
  Future<void> loginWithSSO() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace this block with real flutter_appauth implementation
      // once plugin is added and native setup is done.
      //
      // For now, we fall back to a simulated SSO behavior:
      await Future.delayed(const Duration(seconds: 2));
      // You can change this behavior to auto-login for demo:
      // _isAuthenticated = true;
      // await _secureStorage.write(key: 'access_token', value: 'sso_demo_token');

      // For safety, show a clear message that SSO is not configured:
      _isAuthenticated = false;
      _errorMessage = 'SSO not configured. Using simulated login instead.';
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = 'SSO error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _errorMessage = null;
    try {
      await _secureStorage.delete(key: 'access_token');
    } catch (_) {}
    notifyListeners();
  }
}
