import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:shared_preferences/shared_preferences.dart';

// Top-level function for background notification handling
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.payload != null) {
    debugPrint(
      'background notification payload: ${notificationResponse.payload}',
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<String> _notifications = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getStringList('notifications') ?? [];
    });
  }

  Future<void> _clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
    setState(() {
      _notifications = [];
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          'app_icon',
        ); // Make sure 'app_icon' exists in drawable

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
        // Handle notification tap
        if (notificationResponse.payload != null) {
          debugPrint('notification payload: ${notificationResponse.payload}');
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Request permissions for Android 13+
    final bool? result =
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();

    if (result == true) {
      debugPrint('Notification permissions granted');
    } else {
      debugPrint('Notification permissions denied');
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
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
      0, // Notification ID
      'Test Notification',
      'This is a test notification from your app!',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Notifikasi'),
        backgroundColor: const Color(0xff233743),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearNotifications,
            tooltip: 'Clear all notifications',
          ),
        ],
      ),
      body:
          _notifications.isEmpty
              ? const Center(child: Text('No notifications yet.'))
              : ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final parts = _notifications[index].split('|');
                  final timestamp = DateTime.parse(parts[0]);
                  final title = parts[1];
                  final message = parts[2];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(message),
                          const SizedBox(height: 4),
                          Text(
                            '${timestamp.toLocal().hour}:${timestamp.toLocal().minute} ${timestamp.toLocal().day}/${timestamp.toLocal().month}/${timestamp.toLocal().year}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
