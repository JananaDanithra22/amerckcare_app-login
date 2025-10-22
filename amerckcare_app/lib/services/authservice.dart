import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Use your real Okta info here
  final String issuer = 'https://trial-1216043.okta.com/oauth2/default';
  final String clientId = '0oawnrm4xbfj0DSri697';
  final String redirectUrl = 'com.amerckcare.app:/callback';

  // Start SSO login
  Future<void> signIn() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          issuer: issuer,
          scopes: ['openid', 'profile', 'offline_access'],
          promptValues: ['login'], // optional: forces login every time
        ),
      );

      if (result != null) {
        await _secureStorage.write(key: 'access_token', value: result.accessToken);
        await _secureStorage.write(key: 'id_token', value: result.idToken);
      } else {
        throw Exception('SSO sign-in failed: no result returned');
      }
    } catch (e) {
      throw Exception('SSO sign-in failed: $e');
    }
  }

  // Read tokens
  Future<String?> readAccessToken() async => await _secureStorage.read(key: 'access_token');
  Future<String?> readIdToken() async => await _secureStorage.read(key: 'id_token');

  // Sign out
  Future<void> signOut() async => await _secureStorage.deleteAll();
}
