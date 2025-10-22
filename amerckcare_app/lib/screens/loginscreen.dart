import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/authprovider.dart';
import '../services/authservice.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  String? _usernameError;
  String? _passwordError;

  get onPressed => null;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() {
      _usernameError = null;
      _passwordError = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Local validation first
    if (!_formKey.currentState!.validate()) return;

    // Call auth login
    await auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text);

    if (auth.isAuthenticated) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Map backend response to field-level errors
      // This assumes your AuthProvider sets errorMessage to:
      // "invalid_username", "incorrect_password", or "both_invalid"
      setState(() {
        switch (auth.errorMessage) {
          case 'invalid_username':
            _usernameError = 'Invalid username';
            break;
          case 'incorrect_password':
            _passwordError = 'Incorrect password';
            break;
          case 'both_invalid':
            _usernameError = 'Invalid username';
            _passwordError = 'Incorrect password';
            break;
          default:
            // Fallback generic error
            _usernameError = null;
            _passwordError = null;
            if (auth.errorMessage != null && auth.errorMessage!.isNotEmpty) {
              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
            }
        }
      });
    }
  }

  void _loginWithSSO() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.loginWithSSO();
    if (auth.isAuthenticated) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }

    const buttonWidth = 220.0;
    const buttonHeight = 50.0;
    const borderRadius = 10.0;
    const fontStyle = TextStyle(fontSize: 16);
    const inputColor = Color(0xFFE0E0E0);

    const loginColor = Colors.blue;
    final ssoColor = Colors.blue.shade800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign in',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Username / Email', style: fontStyle),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _usernameCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        errorText: _usernameError,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Please enter username or email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Password', style: fontStyle),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        errorText: _passwordError,
                      ),
                      validator:
                          (v) =>
                              (v == null || v.isEmpty)
                                  ? 'Please enter password'
                                  : null,
                    ),
                    const SizedBox(height: 30),
                    // Login Button
                    SizedBox(
                      width: buttonWidth,
                      height: buttonHeight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: loginColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                        ),
                        onPressed: auth.isLoading ? null : _submit,
                        child:
                            auth.isLoading
                                ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Sign in',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
// SSO Login Button
SizedBox(
  width: buttonWidth,
  height: buttonHeight,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: ssoColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    onPressed: auth.isLoading
        ? null
        : () async {
            // Create AuthService with your real Okta domain and client info
            final authService = AuthService(
              issuer: 'https://trial-1216043.okta.com/oauth2/default',
              clientId: '0oawnrm4xbfj0DSri697',
              redirectUrl: 'com.amerckcare.app:/callback',
            );

            try {
              // Start the SSO sign-in flow
              await authService.signIn();

              // Read the access token from secure storage
              final token = await authService.readAccessToken();

              if (token != null) {
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SSO login failed')),
                );
              }
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('SSO login error: $e')),
              );
            }
          },
    child: const Text(
      'Sign in with SSO',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
  ),
),

                    const SizedBox(height: 16),
                    // Forgot Password
                    SizedBox(
                      width: buttonWidth,
                      height: 40,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                            side: BorderSide.none,
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Forgot password flow not implemented.',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
