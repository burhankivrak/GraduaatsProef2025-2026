
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../navigation/tab_navigator.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const TabNavigator();
        }

        return const AuthScreen();
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;

  @override
  Widget build(BuildContext context) {
    return _isLoginMode
        ? LoginScreen(
      onSwitchToRegister: () {
        setState(() {
          _isLoginMode = false;
        });
      },
    )
        : RegisterScreen(
      onSwitchToLogin: () {
        setState(() {
          _isLoginMode = true;
        });
      },
    );
  }
}