import 'package:flutter/material.dart';
import 'package:place_prep/screens/auth_page.dart';
import 'package:place_prep/screens/home_page.dart';
import 'package:place_prep/services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Placement Prep',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: AuthService.isAuthenticated ? const HomePage() : const AuthPage(),
    );
  }
}
