import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/authprovider.dart';
import 'screens/loginscreen.dart';
import 'screens/homescreen.dart';
import 'screens/splashscreen.dart'; // ✅ Import splash screen

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AuthProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmerckCare Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
