import 'package:flutter/material.dart';
import 'package:lmb_online/splash_screen.dart';
import 'package:lmb_online/views/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: const ColorScheme.light(primary: Color(0xFF1A447F)),
      ),
      home: const LoginScreen(),
    );
  }
}
