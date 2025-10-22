import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final String issuer;
  final String clientId;
  final String redirectUrl;

  AuthService({
    required this.issuer,
    required this.clientId,
    required this.redirectUrl,
  });

  // Start SSO login
  Future<void> signIn() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          issuer: issuer,
          scopes: ['openid', 'profile', 'offline_access'],
        ),
      );

      if (result != null) {
        await _secureStorage.write(
          key: 'access_token',
          value: result.accessToken,
        );
        await _secureStorage.write(key: 'id_token', value: result.idToken);
      } else {
        throw Exception('SSO sign-in failed: no result returned');
      }
    } catch (e) {
      throw Exception('SSO sign-in failed: $e');
    }
  }

  Future<String?> readAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<String?> readIdToken() async {
    return await _secureStorage.read(key: 'id_token');
  }

  Future<void> signOut() async {
    await _secureStorage.deleteAll();
  }
}
