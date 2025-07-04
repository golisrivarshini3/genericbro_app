import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generic Medicine App',
      theme: ThemeData(
        primaryColor: const Color(0xFF02899D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF02899D),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
