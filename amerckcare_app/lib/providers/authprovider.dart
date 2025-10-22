// lib/providers/authprovider.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  // ----- REPLACE these with real values from your identity team -----
  // Example placeholders:
  static const String _clientId = 'kCw5BNfmAOyXPbwuOtg20qYe55YW4xIc';
  // redirectUri example: com.example.amerckcare_app://oauthredirect
  static const String _redirectUri =
      'com.example.amerckcare_app://callback';
  static const String _discoveryUrl =
      'https://dev-ozw4gpcw7oy5imcw.us.auth0.com/.well-known/openid-configuration'; // e.g. https://id.amerck.com/.well-known/openid-configuration
  static const List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
    'offline_access',
  ];
  // -------------------------------------------------------------------

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
      _isAuthenticated = false;
    } finally {
      notifyListeners();
    }
  }

  // Simulated username/password login for immediate testing
  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    if (username.trim() == 'user@amerck.com' && password == 'password123') {
      _isAuthenticated = true;
      await _secureStorage.write(key: 'access_token', value: 'demo_token');
    } else {
      _isAuthenticated = false;
      _errorMessage = 'Invalid username or password';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Real SSO login using flutter_appauth (Authorization Code Flow with PKCE)
  Future<void> loginWithSSO() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // If discovery URL or client id aren't set, bail gracefully
    if (_clientId.startsWith('kCw5BNfmAOyXPbwuOtg20qYe55YW4xIc') || _discoveryUrl.startsWith('dev-ozw4gpcw7oy5imcw.us.auth0.com')) {
      // fallback behavior: show message and return (do not crash)
      _isLoading = false;
      _errorMessage =
          'SSO not configured. Please provide client ID and discovery URL.';
      notifyListeners();
      return;
    }

    try {
      final AuthorizationTokenRequest request = AuthorizationTokenRequest(
        _clientId,
        _redirectUri,
        discoveryUrl: _discoveryUrl,
        scopes: _scopes,
        // preferEphemeralSession: true, // optional (iOS) if you want ephemeral session
      );

      final result = await _appAuth.authorizeAndExchangeCode(request);

      if (result != null && result.accessToken != null) {
        // Save tokens securely
        await _secureStorage.write(
          key: 'access_token',
          value: result.accessToken!,
        );
        if (result.refreshToken != null && result.refreshToken!.isNotEmpty) {
          await _secureStorage.write(
            key: 'refresh_token',
            value: result.refreshToken!,
          );
        }
        _isAuthenticated = true;
        _errorMessage = null;
      } else {
        _isAuthenticated = false;
        _errorMessage = 'SSO failed: no token received';
      }
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
      await _secureStorage.delete(key: 'refresh_token');
    } catch (_) {}
    notifyListeners();
  }
}
