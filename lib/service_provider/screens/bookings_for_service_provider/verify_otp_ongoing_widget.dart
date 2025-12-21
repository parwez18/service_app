import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:khujo_app/models/booking_model.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';

class VerifyOtpOngoingWidget extends StatefulWidget {
  final BookingModel bookingData;

  const VerifyOtpOngoingWidget({super.key, required this.bookingData});

  @override
  State<VerifyOtpOngoingWidget> createState() => _BookingDetailedScreenState();
}

class _BookingDetailedScreenState extends State<VerifyOtpOngoingWidget> {
  late BookingModel booking;

  @override
  void initState() {
    super.initState();
    booking = widget.bookingData;
  }

  final _key = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

  // For Verifying OTP to mark completed
  bool isLoading = false;
  Future<void> verifyOTPAndUpdate(StateSetter setModalState) async {
    if (!_key.currentState!.validate()) return;

    setModalState(() => isLoading = true);
    try {
      final int enterOTP = int.parse(_otpController.text.trim());
      await Future.delayed(const Duration(seconds: 4));
      if (widget.bookingData.otp == enterOTP) {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingData.bookingId)
            .update({'status': "completed", 'updatedAt': Timestamp.now()});

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking Completed'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
        _otpController.clear();
      } else {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid OTP'),
            backgroundColor: Colors.deepOrange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setModalState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _otpController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: customAppBar("Booking Details"),
      body: _buildBookingContent(),
    );
  }

  Widget _buildBookingContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderCard(),
          SizedBox(height: 16.h),
          _buildUserCard(),
          _buildBookingInfoCard(),
          _buildServicesCard(),
          SizedBox(height: 15.h),
          // To Verify Otp to mark as completed
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 10, 138, 243),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () {
                // Bottom Sheet to verify OTP
                showModalBottomSheet(
                  backgroundColor: Colors.white,
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 25.w,
                            right: 25.w,
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: Form(
                            key: _key,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 45.h),
                                Text(
                                  "Verify OTP",
                                  style: TextStyle(
                                    fontSize: 23.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                TextFormField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.domain_verification),
                                    hintText: "Enter 6 digit OTP",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.r),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter OTP";
                                    }
                                    if (value.length < 6) {
                                      return "Please enter 6 digit OTP";
                                    }
                                    if (value.length > 6) {
                                      return "Please enter 6 digit OTP";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 25.h),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      10,
                                      138,
                                      243,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                          // Verify OTP Method Logic
                                          await verifyOTPAndUpdate(
                                            setModalState,
                                          );
                                        },
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8.h,
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : Text(
                                              "Verify",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 25.h),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Center(
                  child: Text(
                    "Verify OTP",
                    style: TextStyle(color: Colors.white, fontSize: 18.sp),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 50.h),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        children: [
          if (booking.serviceImage.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.network(
                  booking.serviceImage,
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200.h,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              children: [
                Text(
                  booking.serviceName,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    booking.serviceCategory,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                _buildStatusBadge(booking.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return _buildCard(
      icon: Icons.store_outlined,
      title: 'User Info',
      child: Column(
        children: [
          _buildInfoRow(Icons.location_on, 'Location', booking.userAddress),
          _buildInfoRow(Icons.person, 'Name', booking.userName),
        ],
      ),
    );
  }

  Widget _buildBookingInfoCard() {
    return _buildCard(
      icon: Icons.event_note,
      title: 'Booking Information',
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_today,
            'Date',
            DateFormat('dd MMM yyyy, EEEE').format(booking.bookingDate),
          ),
          _buildInfoRow(Icons.access_time, 'Time', booking.bookingTime),
          _buildInfoRow(Icons.schedule, 'Duration', booking.totalDuration),
          _buildInfoRow(
            Icons.timer_outlined,
            'Start Time',
            booking.bookingStartTime,
          ),
          _buildInfoRow(
            Icons.timer_off_outlined,
            'End Time',
            booking.bookingEndTime,
          ),
          _buildInfoRow(
            Icons.confirmation_number,
            'Booking ID',
            booking.bookingId,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCard() {
    return _buildCard(
      icon: Icons.list_alt,
      title: 'Services Booked',
      child: Column(
        children: [
          ...booking.selectedServices.asMap().entries.map((entry) {
            final index = entry.key;
            final service = entry.value;
            return Column(
              children: [
                if (index > 0) const Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14.sp,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  service.duration,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${service.price}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const Divider(thickness: 2),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${booking.totalPrice}',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        text = 'Pending Approval';
        icon = Icons.pending;
        break;
      case 'accepted':
        color = Colors.blue;
        text = 'Upcoming';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        icon = Icons.cancel;
        break;
      case 'ongoing':
        color = Colors.purple;
        text = 'In Progress';
        icon = Icons.autorenew;
        break;
      case 'completed':
        color = Colors.green;
        text = 'Completed';
        icon = Icons.check_circle_outline;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.info;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: Colors.blue, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.sp, color: Colors.blue),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
