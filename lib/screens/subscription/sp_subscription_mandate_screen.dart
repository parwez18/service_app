import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/screens/subscription/sp_subscription_screen.dart'
    show StepIndicator;
import 'package:khujo_app/service_provider/screens/provider_m_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SPSubscriptionMandateScreen extends StatefulWidget {
  final String phone;
  const SPSubscriptionMandateScreen({super.key, required this.phone});

  @override
  State<SPSubscriptionMandateScreen> createState() =>
      _SPSubscriptionMandateScreenState();
}

class _SPSubscriptionMandateScreenState
    extends State<SPSubscriptionMandateScreen> {
  late Razorpay _razorpay;
  late String _uid;
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _serverBase =
      'https://classes.indiandevelopers.org/v3/api/khujo';
  static const String _razorpayKey = 'rzp_live_SGO2tMhVaCYczw';

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // Page 2: Create subscription and open mandate screen
  Future<void> _setupAutopay() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$_serverBase/create-subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': _uid, 'monthlyAmount': 99}),
      );
      if (response.statusCode != 200) {
        throw Exception('Server error ${response.statusCode}. Check API URL.');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        _razorpay.open({
          'key': _razorpayKey,
          'subscription_id': data['subscriptionId'] as String,
          'name': 'Khujo Monthly Plan',
          'description': '₹99/month autopay',
          'prefill': {'contact': widget.phone, 'email': 'provider@khujo.com'},
          'theme': {'color': '#E46612'},
        });
      } else {
        throw Exception(data['error'] ?? 'Failed to create subscription');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Autopay setup failed: $e');
    }
  }

  // Mandate approved — wait for webhook to set status = active
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final listener = _firestore
        .collection('users')
        .doc(_uid)
        .snapshots()
        .listen((snap) {
          final status = snap.data()?['subscription']?['status'] as String?;
          if (status == 'active' && mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Subscription activated! Welcome to Khujo.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProviderMScreen()),
            );
          }
        });

    // Timeout after 30 seconds
    await Future.delayed(const Duration(seconds: 30));
    listener.cancel();

    if (!mounted) return;
    if (_isLoading) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autopay set up. Account being activated...'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProviderMScreen()),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);
    _showError('Autopay setup failed. Please try again.');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),

                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/applogo2.png',
                      height: 70.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Heading
                  Text(
                    'Set Up Monthly\nAutopay',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '₹8 paid! Now approve ₹99/month UPI Autopay.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Step indicator — step 2 active
                  StepIndicator(step: 2),
                  SizedBox(height: 28.h),

                  // Plan card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.primaryColor,
                          AppConstants.primaryColor.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Plan',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹99',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
                              child: Text(
                                '/month',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'Auto-renews every month',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Info box
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.autorenew, color: Colors.blue, size: 22.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Step 2: Set up ₹99/month Autopay',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '₹99 will be auto-deducted every month via UPI. Cancel anytime.',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        disabledBackgroundColor: AppConstants.primaryColor
                            .withValues(alpha: 0.6),
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.r),
                        ),
                      ),
                      onPressed: _isLoading ? null : _setupAutopay,
                      child: Text(
                        'Set Up ₹99/month Autopay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Center(
                    child: Text(
                      'Secured by Razorpay  •  Cancel anytime',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppConstants.primaryColor),
                    SizedBox(height: 16.h),
                    Text(
                      'Setting up autopay...',
                      style: TextStyle(color: Colors.white, fontSize: 15.sp),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
