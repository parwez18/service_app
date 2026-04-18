import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
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

  // Step 1: Create order on YOUR server first
  Future<void> createOrderAndPay() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
          'https://classes.indiandevelopers.org/v3/api/khujo/create-order',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': widget.bookingData['totalPrice'],
          'bookingId': widget.bookingData['bookingId'],
          'userId': widget.bookingData['userId'],
          'bookingData': _sanitizeBookingData(widget.bookingData),
        }),
      );

      if (kDebugMode) {
        debugPrint("amount :- ${widget.bookingData['totalPrice']}");
        debugPrint("bookingId :- ${widget.bookingData['bookingId']}");
        debugPrint("userId :- ${widget.bookingData['userId']}");
        debugPrint(
          "bookingData :- ${_sanitizeBookingData(widget.bookingData)}",
        );
      }

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        // Now open Razorpay with the order ID
        _openCheckout(data['orderId']);
      } else {
        throw Exception(data['error'] ?? 'Failed to create order');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Convert Timestamp to String for JSON serialization
  Map<String, dynamic> _sanitizeBookingData(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);

    // Convert Timestamp to ISO string for JSON
    if (sanitized['bookingDate'] is Timestamp) {
      sanitized['bookingDate'] = (sanitized['bookingDate'] as Timestamp)
          .toDate()
          .toIso8601String();
    }

    return sanitized;
  }

  // Step 2: Open Razorpay with order_id from server
  void _openCheckout(String orderId) {
    var options = {
      "key": "rzp_live_SGO2tMhVaCYczw",
      "amount": widget.bookingData['totalPrice'] * 100,
      "name": "Khujo App",
      "description": "Service Booking Payment",
      "order_id": orderId,
      "prefill": {
        "contact": widget.bookingData['userPhone'] ?? "",
        "email": "user@example.com",
      },
      "theme": {"color": "#FF5722"},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => isLoading = false);
      print("Razorpay Error: $e");
    }
  }

  // Step 3: On success, listen to Firestore for webhook confirmation
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment Success: ${response.paymentId}");
    setState(() => isLoading = true);

    final bookingId = widget.bookingData['bookingId'];

    // Listen to Firestore for booking created by webhook
    final subscription = FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists && mounted) {
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
          }
        });

    // Timeout after 30 seconds if webhook hasn't processed
    await Future.delayed(const Duration(seconds: 30));
    subscription.cancel();

    if (!mounted) return;
    if (isLoading) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment received. Booking is being processed..."),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MScreen()),
      );
    }
  }

  // Handle Payment Error
  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Failed: ${response.message}");
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Payment Failed! Try Again."),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Handle External Wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet Selected: ${response.walletName}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar("Payment"),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selected Services
                Text(
                  "Selected Services",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
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
                          "${service['price']}",
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
                            "${widget.bookingData['totalPrice']}",
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
                // Pay Now Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.r),
                    ),
                  ),
                  onPressed: isLoading ? null : createOrderAndPay,
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
          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              ),
            ),
        ],
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
                "$value - ",
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
