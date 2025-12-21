import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:khujo_app/models/booking_model.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';

class BookingDetailedSPScreen extends StatefulWidget {
  final BookingModel bookingData;

  const BookingDetailedSPScreen({super.key, required this.bookingData});

  @override
  State<BookingDetailedSPScreen> createState() => _BookingDetailedScreenState();
}

class _BookingDetailedScreenState extends State<BookingDetailedSPScreen> {
  late BookingModel booking;

  @override
  void initState() {
    super.initState();
    booking = widget.bookingData;
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
          _buildProviderCard(),
          _buildBookingInfoCard(),
          _buildServicesCard(),
          widget.bookingData.status == "completed"
              ? _buildPaymentSummaryCard()
              : SizedBox.shrink(),
          SizedBox(height: 5.h),
          SizedBox(height: 30.h),
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

  Widget _buildProviderCard() {
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

  Widget _buildPaymentSummaryCard() {
    return _buildCard(
      icon: Icons.payment,
      title: 'Service Provider Payment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: widget.bookingData.serviceProviderPaid
                    ? Colors.green
                    : Colors.deepOrange,
              ),
              SizedBox(width: 12.w),
              Text('Payment Status'),
            ],
          ),
          SizedBox(height: 12.w),
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 30.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: widget.bookingData.serviceProviderPaid
                      ? Colors.green.withOpacity(0.1)
                      : Colors.deepOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: widget.bookingData.serviceProviderPaid
                        ? Colors.green
                        : Colors.deepOrange,
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.bookingData.serviceProviderPaid ? "PAID" : "PENDING",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.bookingData.serviceProviderPaid
                        ? Colors.green
                        : Colors.deepOrange,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.w),
          const Divider(),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount Paid',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '₹${booking.totalPrice}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
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

  Widget _buildPaymentStatusRow(String label, String value) {
    Color statusColor = value.toLowerCase() == 'paid'
        ? Colors.green
        : Colors.orange;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20.sp, color: statusColor),
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
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
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
