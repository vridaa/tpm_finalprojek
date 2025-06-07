import 'package:flutter/material.dart';
import 'package:gift_bouqet/pages/auth/splash.dart';
import 'package:gift_bouqet/pages/user/testimoni.dart';
import 'package:gift_bouqet/service/local_storage_service.dart';
import 'package:timezone/data/latest.dart' as tz; // Import timezone

// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService().init();
  tz.initializeTimeZones(); // Initialize time zones
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan tulisan debug
      title: 'GiftBouqet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFF61313)),
        useMaterial3: true, // kalau pakai Material 3
      ),
      home: const Splashscreen(), // Halaman pertama
    );
  }
}
