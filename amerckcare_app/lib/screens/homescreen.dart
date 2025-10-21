import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/authprovider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Guard: if not authenticated, redirect to login
    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AmerckCare Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome — this is a protected home page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
