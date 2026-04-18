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
import 'package:khujo_app/screens/subscription/sp_subscription_mandate_screen.dart';
import 'package:khujo_app/screens/subscription/sp_subscription_screen.dart';
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

  // To Check that User is logged in or not
  Future<void> _checkLogin() async {
    final user = _auth.currentUser;

    if (user == null) {
      // Show splash briefly for branding, then go to OTP screen
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SendOtpScreen()),
      );
      return;
    }

    try {
      debugPrint("Fetching user data for UID: ${user.uid}");

      // Run splash delay and Firestore fetch in parallel
      final results = await Future.wait([
        Future.delayed(const Duration(seconds: 1)),
        _firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception("Timeout fetching user data from Firestore");
              },
            ),
      ]);

      final userDoc = results[1] as DocumentSnapshot;

      // Update FCM token in the background (don't block navigation)
      FirebaseMessaging.instance.getToken().then((token) {
        if (token != null) {
          NotificationService.saveFCMToken(token);
        }
      });

      if (!userDoc.exists) {
        debugPrint("User document does not exist in Firestore");
        throw Exception("User document not found");
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      final userType = userData?['userType'] as String?;

      debugPrint("User data loaded - UserType: $userType");

      if (!mounted) return;

      if (userType == "Customer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MScreen()),
        );
        NotificationService.handlePendingNavigation();
      } else if (userType == "Service Provider") {
        final sub =
            userData?['subscription'] as Map<String, dynamic>? ?? {};
        final subStatus = sub['status'] as String? ?? 'inactive';
        final introPaid = sub['introPaid'] as bool? ?? false;
        final phone = userData?['phoneNumber'] as String? ?? '';

        if (subStatus == 'active') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProviderMScreen()),
          );
        } else if (introPaid) {
          // ₹8 already paid — skip to autopay setup page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SPSubscriptionMandateScreen(phone: phone),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SPSubscriptionScreen()),
          );
        }
      } else {
        debugPrint("Invalid userType: $userType");
        throw Exception("Invalid user type");
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
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
            SizedBox(height: 8.h),
            Text(
              "Khujo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 35.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
