import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/splash_screen.dart';
import '../auth/login_page.dart';
import '../screens/home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    final loggedIn    = prefs.getBool('loggedIn') ?? false;
    final currentUser = prefs.getString('currentUser') ?? '';

    bool accountExists = false;
    if (loggedIn && currentUser.isNotEmpty) {
      try {
        final raw = prefs.getString('users') ?? '';
        if (raw.isNotEmpty) {
          final users = jsonDecode(raw) as Map<String, dynamic>;
          accountExists = users.containsKey(currentUser);
        }
      } catch (_) {
        accountExists = false;
      }
    }

    final shouldGoHome = loggedIn && accountExists;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
        shouldGoHome ? const HomeScreen() : const LoginPage(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SplashScreen();
}