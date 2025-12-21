import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/screens/login/send_otp_screen.dart';
import 'package:khujo_app/screens/m_screen.dart';
import 'package:khujo_app/service_provider/screens/provider_m_screen.dart';
import 'package:khujo_app/services/notifiction_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  // To Check that User is loged in or not
  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    final user = _auth.currentUser;

    if (user == null) {
      // Not logged in → go to OTP screen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SendOtpScreen()),
      );
      return;
    }

    try {
      // User logged in → fetch user data directly from Firestore
      debugPrint("Fetching user data for UID: ${user.uid}");

      // Update FCM token for logged-in user
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await NotificationService.saveFCMToken(token);
        debugPrint("FCM Token updated in splash screen");
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception("Timeout fetching user data from Firestore");
            },
          );

      if (!userDoc.exists) {
        debugPrint("User document does not exist in Firestore");
        throw Exception("User document not found");
      }

      final userData = userDoc.data();
      final userType = userData?['userType'] as String?;

      debugPrint("User data loaded - UserType: $userType");

      if (!mounted) return;

      if (userType == "Customer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MScreen()),
        );
        // Handle any pending notification navigation
        NotificationService.handlePendingNavigation();
      } else if (userType == "Service Provider") {
        // Navigate to ServiceProvider Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProviderMScreen()),
        );
        // Handle any pending notification navigation
        NotificationService.handlePendingNavigation();
      } else {
        // Invalid or missing userType
        debugPrint("Invalid userType: $userType");
        throw Exception("Invalid user type");
      }
    } catch (e) {
      // Handle errors (user not found, network issues, etc.)
      debugPrint("Error loading user data: $e");
      // Navigate to login screen on error
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SendOtpScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 1.sh,
        width: 1.sw,
        color: AppConstants.primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/applogo2.png',
              width: 320.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10.h),
            Text(
              "Khujo App",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
