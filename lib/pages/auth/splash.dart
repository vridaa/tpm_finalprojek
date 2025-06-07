import 'package:flutter/material.dart';
import 'package:gift_bouqet/pages/admin/dashboard_admin.dart';
import 'package:gift_bouqet/pages/user/homepage.dart';
import 'package:gift_bouqet/service/local_storage_service.dart';

import 'login.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final localStorageService = LocalStorageService();
    final token = await localStorageService.getAuthToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      final user = await localStorageService.getUserData();
      if (user != null && user.id != null) {
        // User data and token found, navigate to appropriate dashboard
        if (user.role) {
          // Assuming `true` for admin, `false` for user based on previous discussions
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        // Token exists but user data is incomplete or invalid, navigate to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      // No token found, navigate to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/background.png', width: 150),
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // Show a loading indicator
          ],
        ),
      ),
    );
  }
}
