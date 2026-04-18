import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:khujo_app/main.dart';
import 'package:khujo_app/service_provider/screens/provider_booking_detail_screen.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static String? _pendingBookingId; // Store pending navigation

  // Initialize
  static Future<void> initialize() async {
    // Request Permission
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Initialize local notification
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Get FCM token (saving is handled after login in splash/verify screens)
    String? token = await _messaging.getToken();
    if (token != null) {
      print("FCM Token: $token");
    }

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message: ${message.notification?.title}");
      _showLocalNotification(message);
    });

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(
      _handleBackgroundNotificationTap,
    );

    // Check if app was opened from a notification
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundNotificationTap(initialMessage);
    }
  }

  // Handle foreground notification tap
  static void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      _navigateToBookingDetail(response.payload!);
    }
  }

  // Handle background/terminated app notification tap
  static void _handleBackgroundNotificationTap(RemoteMessage message) {
    final bookingId = message.data['bookingId'];
    if (bookingId != null) {
      _navigateToBookingDetail(bookingId);
    }
  }

  // Navigate to booking detail screen
  static void _navigateToBookingDetail(String bookingId) {
    final context = navigatorKey.currentContext;
    if (context != null && navigatorKey.currentState != null) {
      // Context is available, navigate immediately
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => ProviderBookingDetailScreen(bookingId: bookingId),
        ),
      );
    } else {
      // Context not available yet (app is still initializing), store for later
      _pendingBookingId = bookingId;
    }
  }

  // Call this method after splash screen navigation completes
  static void handlePendingNavigation() {
    if (_pendingBookingId != null && navigatorKey.currentState != null) {
      final bookingId = _pendingBookingId!;
      _pendingBookingId = null;

      // Add a small delay to ensure the home screen is fully loaded
      Future.delayed(Duration(milliseconds: 500), () {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (_) => ProviderBookingDetailScreen(bookingId: bookingId),
            ),
          );
        }
      });
    }
  }

  // Save FCM token to user document
  static Future<void> saveFCMToken(String token) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'fcmToken': token},
        );
        print("Token saved for user: $userId");
      } else {
        print("User not logged in yet. Token will be saved after login.");
      }
    } catch (e) {
      print("Error saving token: $e");
    }
  }

  // Show local notifications
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'booking_notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      details,
      payload: message.data['bookingId'],
    );
  }

  // Send Notification data to Firebasestore
  static Future<void> sendBookingNotification({
    required String serviceProviderId,
    required String bookingId,
    required String serviceName,
    required String userName,
  }) async {
    try {
      // Save notification to firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'recipientId': serviceProviderId,
        'type': 'new_booking',
        'title': 'New Booking Request!',
        'body': '$userName booked $serviceName',
        'bookingId': bookingId,
        'createdAt': Timestamp.now(),
        'read': false,
      });
      print("Notification saved to Firestore for provider: $serviceProviderId");
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}
