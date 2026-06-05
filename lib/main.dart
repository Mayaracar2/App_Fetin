import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SocorroFacilApp());
}

class SocorroFacilApp extends StatelessWidget {
  const SocorroFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Socorro Fácil',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const LoginScreen(),
    );
  }
}
