import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Email/password login simulation
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (email.trim() == 'user@amerck.com' && password == 'password123') {
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
      _errorMessage = 'Invalid username or password';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Google Sign-In (Firebase)
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isAuthenticated = false;
        _errorMessage = 'Google Sign-In cancelled';
      } else {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);

        _isAuthenticated = true;
      }
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = 'Google Sign-In failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }
}
