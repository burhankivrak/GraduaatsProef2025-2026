import 'package:flutter/material.dart';
import 'authentication/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: const AuthWrapper(),
    );
  }
}


