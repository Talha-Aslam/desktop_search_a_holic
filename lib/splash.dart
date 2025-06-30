import 'package:flutter/material.dart';
import 'package:desktop_search_a_holic/auto_backup_service.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    try {
      // Small delay to ensure the widget tree is fully built
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize auto backup service after the app is properly mounted
      if (mounted) {
        await AutoBackupService().initialize();
      }
    } catch (e) {
      print('Failed to initialize auto backup service: $e');
      // Continue with app initialization even if backup service fails
    } finally {
      // Navigate to next screen regardless of initialization success
      if (mounted) {
        _navigateToNextScreen();
      }
    }
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2), () {});
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/logo.png'),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            const Text('Initializing...'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
