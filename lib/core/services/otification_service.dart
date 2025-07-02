import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extroza/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// --- Notification Service ---
// This service handles all push notification logic for the app.

// Function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // If you need to do work here, like marking a message as received, do it here.
  // For now, we just initialize Firebase.
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initializes the notification service, requests permissions, and sets up listeners.
  Future<void> initialize() async {
    // 1. Request Notification Permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Get the device's FCM token
    final token = await _fcm.getToken();
    if (token != null) {
      print('FCM Token: $token');
      _saveTokenToDatabase(token);
    }

    // 3. Listen for token refreshes
    _fcm.onTokenRefresh.listen(_saveTokenToDatabase);

    // 4. Set up foreground notification handling
    await _setupForegroundNotifications();

    // 5. Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Saves the user's FCM token to their profile in Firestore.
  Future<void> _saveTokenToDatabase(String token) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await _db.collection(_usersCollection).doc(userId).update({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // This might fail if the user document doesn't exist yet.
        // It's good practice to ensure the document exists before updating.
        print('Error saving FCM token: $e');
      }
    }
  }

  /// Configures and initializes flutter_local_notifications to show heads-up notifications
  /// when the app is in the foreground.
  Future<void> _setupForegroundNotifications() async {
    // Android notification channel setup
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    // Initialization settings for Android and iOS
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(initializationSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Listen for incoming messages while the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ),
        );
      }
    });
  }
}
