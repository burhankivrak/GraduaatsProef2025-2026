import 'package:flutter/material.dart';
import 'package:myseries/screens/home_screen.dart';

void main() {
  runApp(const MySeriesApp());
}

class MySeriesApp extends StatelessWidget {
  const MySeriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySeries',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
