import 'package:flutter/material.dart';
import 'package:gift_bouqet/pages/user/dashboard_user.dart';
import 'package:gift_bouqet/pages/user/profile.dart';
import 'package:gift_bouqet/pages/user/shop_location_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gift_bouqet/pages/notification.dart';
import 'package:gift_bouqet/model/userModel.dart';
import 'package:gift_bouqet/service/local_storage_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _selectedIndex = 0;
  Map<String, dynamic> userData = {
    'userId': '',
    'username': '',
    'email': '',
    'profilePicture': '',
  };
  bool _isLoading = true;

  double _accelerometerX = 0.0;
  double _accelerometerY = 0.0;
  double _accelerometerZ = 0.0;
  DateTime? _lastShakeTime;
  static const double _shakeThreshold = 30.0;
  static const Duration _shakeCooldown = Duration(seconds: 10);
  bool _isFirstAccelerometerEvent = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeNotifications();
    _startAccelerometerListener();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) async {
        // Handle tap notifikasi (jika perlu)
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> _showPromoNotification() async {
    // Add a 5-second delay before showing the notification
    // You can change this to 10 seconds or any other duration
    await Future.delayed(const Duration(seconds: 5));

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'promo_channel_id',
          'Promo Channel',
          channelDescription: 'Notifikasi untuk promo khusus',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      1,
      'Selamat! Anda Mendapat Promo!',
      'Goyangkan lagi besok untuk promo menarik lainnya!',
      platformChannelSpecifics,
      payload: 'promo_goyang',
    );
  }

  Future<void> _saveNotification(String title, String message) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];
    final newNotification =
        '${DateTime.now().toIso8601String()}|$title|$message';
    notifications.insert(0, newNotification); // Add to the beginning
    await prefs.setStringList('notifications', notifications);
  }

  StreamSubscription? _accelerometerSubscription;

  void _startAccelerometerListener() {
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      if (_isFirstAccelerometerEvent) {
        _accelerometerX = event.x;
        _accelerometerY = event.y;
        _accelerometerZ = event.z;
        _isFirstAccelerometerEvent = false;
        return; // Skip shake detection for the very first event
      }

      final double deltaX = event.x - _accelerometerX;
      final double deltaY = event.y - _accelerometerY;
      final double deltaZ = event.z - _accelerometerZ;

      _accelerometerX = event.x;
      _accelerometerY = event.y;
      _accelerometerZ = event.z;

      final double shakeForce =
          (deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);

      if (shakeForce > _shakeThreshold) {
        if (_lastShakeTime == null ||
            DateTime.now().difference(_lastShakeTime!) > _shakeCooldown) {
          _lastShakeTime = DateTime.now();
          _showPromoNotification();
          _saveNotification(
            'Selamat! Anda Mendapat Promo!',
            'Goyangkan lagi besok untuk promo menarik lainnya!',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Promo Ditemukan! Cek Notifikasi Anda.'),
            ),
          );
        }
      }
    });
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final User? user = await LocalStorageService().getUserData();

      if (user == null || user.id == null) {
        throw Exception('User data not found or incomplete in local storage');
      }

      setState(() {
        userData = {
          'userId': user.id.toString(),
          'username': user.username ?? 'Guest',
          'email': user.email ?? '',
          'profilePicture': user.profilePicture ?? '',
        };
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (e is TypeError) {
        debugPrint(
          'TypeError: Pastikan tipe data di SharedPreferences konsisten',
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProfilePage() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userData['userId'].isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'User data not available',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return ProfilePage(userData: userData);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      DashboardUser(username: userData['username']),
      NotificationPage(),
      const ShopLocationPage(),
      _buildProfilePage(),
    ];

    const List<BottomNavigationBarItem> navItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(
        icon: Icon(Icons.notifications),
        label: 'Notifikasi',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Lokasi'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gift_Bouqet',
                  style: TextStyle(
                    color: Color(0xff233743),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          automaticallyImplyLeading: false,
          toolbarHeight: 60,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: Colors.white,
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: navItems,
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.black26,
          selectedFontSize: 12.0,
          selectedItemColor: const Color(0xff233743),
          onTap: (index) {
            if (index == 3 && userData['userId'].isEmpty) {
              _loadUserData();
            }
            setState(() => _selectedIndex = index);
          },
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.payload != null) {
    debugPrint(
      'background notification payload: ${notificationResponse.payload}',
    );
  }
}
