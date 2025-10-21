import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/authprovider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!_formKey.currentState!.validate()) return;

    await auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
    if (auth.isAuthenticated) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _loginWithSSO() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.loginWithSSO();
    if (auth.isAuthenticated) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // if already logged in, redirect
    if (auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AmerckCare Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Username / Email',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Please enter username or email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Please enter password' : null,
                    ),
                    const SizedBox(height: 16),
                    if (auth.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          auth.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _submit,
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ---- SSO Button ----
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text('Sign in with Company SSO'),
                        onPressed: auth.isLoading ? null : _loginWithSSO,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // Placeholder: forgot password flow
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Forgot password flow not implemented.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
