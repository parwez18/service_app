import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/screens/subscription/sp_subscription_mandate_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SPSubscriptionScreen extends StatefulWidget {
  const SPSubscriptionScreen({super.key});

  @override
  State<SPSubscriptionScreen> createState() => _SPSubscriptionScreenState();
}

class _SPSubscriptionScreenState extends State<SPSubscriptionScreen> {
  late Razorpay _razorpay;
  late String _uid;
  bool _isLoading = false;
  String _userPhone = '';

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
    _checkExistingProgress();
  }

  // If user already paid ₹8 before, skip to Page 2
  Future<void> _checkExistingProgress() async {
    final doc = await _firestore.collection('users').doc(_uid).get();
    final sub = doc.data()?['subscription'] as Map<String, dynamic>?;
    if (sub != null && sub['introPaid'] == true && mounted) {
      final phone = doc.data()?['phoneNumber'] as String? ?? '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SPSubscriptionMandateScreen(phone: phone),
        ),
      );
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // Page 1: Pay ₹8 intro fee
  Future<void> _payIntro() async {
    setState(() => _isLoading = true);
    try {
      final userDoc = await _firestore.collection('users').doc(_uid).get();
      _userPhone = userDoc.data()?['phoneNumber'] as String? ?? '';

      final response = await http.post(
        Uri.parse('$_serverBase/create-order-auto-pay'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': _uid, 'amount': 8}),
      );

      if (response.statusCode != 200) {
        throw Exception('Server error ${response.statusCode}. Check API URL.');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        _razorpay.open({
          'key': _razorpayKey,
          'amount': 800,
          'order_id': data['orderId'] as String,
          'name': 'Khujo App',
          'description': '₹8 activation fee',
          'method': {
            'upi': true,
            'card': true,
            'netbanking': true,
            'wallet': true,
          },
          'prefill': {'contact': _userPhone, 'email': 'provider@khujo.com'},
          'theme': {'color': '#E46612'},
        });
      } else {
        throw Exception(data['error'] ?? 'Failed to create order');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error: $e');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;
    setState(() => _isLoading = false);
    // ₹8 paid — navigate to Page 2 for autopay setup
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SPSubscriptionMandateScreen(phone: _userPhone),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);
    _showError('Payment failed. Please try again.');
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
                    'Activate Your\nService Provider Account',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Start getting bookings from customers near you.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Step indicator
                  StepIndicator(step: 1),
                  SizedBox(height: 28.h),

                  // Plan card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.primaryColor,
                          AppConstants.primaryColor.withOpacity(0.75),
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
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'First month only ₹8',
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
                  SizedBox(height: 22.h),

                  // Benefits
                  _Benefit('Get bookings from nearby customers'),
                  _Benefit('Manage all bookings in one place'),
                  _Benefit('Receive instant payment notifications'),
                  _Benefit('Cancel anytime'),
                  SizedBox(height: 24.h),

                  // Info box
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          color: Colors.green,
                          size: 22.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Step 1: Pay ₹8 activation fee',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "One-time intro fee. Next you'll set up ₹99/month UPI Autopay.",
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
                            .withOpacity(0.6),
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.r),
                        ),
                      ),
                      onPressed: _isLoading ? null : _payIntro,
                      child: Text(
                        'Pay ₹8 & Continue',
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
              color: Colors.black.withOpacity(0.45),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppConstants.primaryColor),
                    SizedBox(height: 16.h),
                    Text(
                      'Creating order...',
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

// ─────────────────────────────────────────────────────
// Step Indicator (shared)
// ─────────────────────────────────────────────────────
class StepIndicator extends StatelessWidget {
  final int step; // 1 or 2
  const StepIndicator({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _circle(1, 'Pay ₹8', step >= 1),
        Expanded(
          child: Container(
            height: 2,
            color: step >= 2 ? AppConstants.primaryColor : Colors.grey.shade300,
          ),
        ),
        _circle(2, 'Setup Autopay', step >= 2),
      ],
    );
  }

  Widget _circle(int n, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? AppConstants.primaryColor : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$n',
              style: TextStyle(
                color: active ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? AppConstants.primaryColor : Colors.grey.shade500,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
// Benefit row
// ─────────────────────────────────────────────────────
class _Benefit extends StatelessWidget {
  final String text;
  const _Benefit(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppConstants.primaryColor,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
