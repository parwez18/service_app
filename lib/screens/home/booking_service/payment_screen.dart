import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/home/home_m_screen.dart';
import 'package:khujo_app/screens/m_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  const PaymentScreen({super.key, required this.bookingData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  bool isLoading = false;
  String selectedPaymentMethod = 'razorpay';

  @override
  void initState() {
    super.initState();

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

  // -----------------------------
  //  OPEN PAYMENT GATEWAY
  // -----------------------------
  void openCheckout() {
    var options = {
      "key": "rzp_test_5ZfjOX6tXm8cxU", // <-- replace with your key
      "amount": widget.bookingData['totalPrice'] * 100, // amount in paise
      "name": "Parwez",
      "description": "Service Booking Payment",
      "prefill": {"contact": "+919472485909", "email": "test@example.com"},
      "theme": {"color": "#FF5722"},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Razorpay Error: $e");
    }
  }

  // Genearte 6 digit OTP
  int generate6DigitOTP() {
    final random = Random();
    return 100000 + random.nextInt(900000);
  }

  // Handle Payment Success
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment Success: ${response.paymentId}");
    setState(() => isLoading = true);
    try {
      // 1. Save booking to Firestore
      final bookingRef = FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingData['bookingId']);

      // 🔐 Generate OTP (int)
      final int otp = generate6DigitOTP();

      Map<String, dynamic> finalBookingData = Map.from(widget.bookingData);
      finalBookingData['razorpayPaymentId'] = response.paymentId;
      finalBookingData['razorpayOrderId'] = response.orderId ?? '';
      finalBookingData['razorpaySignature'] = response.signature ?? '';
      finalBookingData['paymentMethod'] = 'razorpay';
      finalBookingData['paymentStatus'] = 'paid';
      finalBookingData['status'] = 'pending'; // Waiting for provider acceptance
      finalBookingData['otp'] = otp;
      finalBookingData['serviceProviderPaid'] = false;
      finalBookingData['refund'] = "Pending";
      finalBookingData['createdAt'] = Timestamp.now();
      await bookingRef.set(finalBookingData);
      print("✅ Booking saved: ${widget.bookingData['bookingId']}");
      // 2. Send notification to service provider
      await FirebaseFirestore.instance.collection('notifications').add({
        'recipientId': widget.bookingData['serviceProviderId'],
        'type': 'new_booking',
        'title': 'New Booking Request! 🎉',
        'body':
            'You have a new booking for ${widget.bookingData['serviceName']}',
        'bookingId': widget.bookingData['bookingId'],
        'serviceName': widget.bookingData['serviceName'],
        'totalPrice': widget.bookingData['totalPrice'],
        'bookingTime': widget.bookingData['bookingTime'],
        'createdAt': Timestamp.now(),
        'read': false,
      });
      print(
        "✅ Notification sent to provider: ${widget.bookingData['serviceProviderId']}",
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking Successful!"),
          backgroundColor: Colors.blue,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MScreen()),
      );
    } catch (e) {
      print("❌ Error: $e");
      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Handle Payment Error
  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    print("Payment Failed: ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed! Try Again."),
        backgroundColor: Colors.red,
      ),
    );
  }

  // External Issue
  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet Selected: ${response.walletName}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar("Payment"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Services
            Text(
              "Selected Services",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            ...widget.bookingData['selectedServices'].map(
              (service) => Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.deepOrange.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['name'],
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            service['duration'],
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${service['price']}",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            // Booking Summary
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Booking Summary",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  _buildSummaryRow(
                    "Service",
                    widget.bookingData['serviceName'],
                  ),
                  _buildSummaryRow(
                    "Date",
                    "${(widget.bookingData['bookingDate'] as Timestamp).toDate().day}/"
                        "${(widget.bookingData['bookingDate'] as Timestamp).toDate().month}/"
                        "${(widget.bookingData['bookingDate'] as Timestamp).toDate().year}",
                  ),
                  _buildSummaryRow2(
                    "Time",
                    widget.bookingData['bookingStartTime'],
                    widget.bookingData['bookingEndTime'],
                  ),
                  _buildSummaryRow(
                    "Duration",
                    widget.bookingData['totalDuration'],
                  ),
                  Divider(height: 20.h, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "₹${widget.bookingData['totalPrice']}",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            // Payment Method
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.r),
                ),
              ),
              onPressed: () {
                openCheckout();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Center(
                  child: Text(
                    "Pay Now",
                    style: TextStyle(color: Colors.white, fontSize: 18.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow2(String label, String value, String value2) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
          Row(
            children: [
              Text(
                "${value} - ",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              Text(
                value2,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
