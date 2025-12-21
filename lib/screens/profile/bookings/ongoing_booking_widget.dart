import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/screens/profile/bookings/booking_detailed_screen.dart';

class OngoingBookingWidget extends ConsumerStatefulWidget {
  const OngoingBookingWidget({super.key});

  @override
  ConsumerState<OngoingBookingWidget> createState() =>
      _PendingBookingWidgetState();
}

class _PendingBookingWidgetState extends ConsumerState<OngoingBookingWidget> {
  String formatDate(DateTime date) {
    return DateFormat('EEE, dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final ongoingBookingsAsync = ref.watch(ongoingBookingsProvider(userId));
    return ongoingBookingsAsync.when(
      data: (bookingData) {
        if (bookingData.isEmpty) {
          return Center(child: Text("No Ongoing Booking"));
        }
        return ListView.builder(
          itemCount: bookingData.length,
          itemBuilder: (contex, index) {
            var data = bookingData[index];
            return GestureDetector(
              onTap: () {
                // Navigate to Booking Details screen for users
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingDetailedScreen(bookingData: data),
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 20.h,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              data.serviceImage,
                              width: 100.w,
                              height: 100.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80.w,
                                  height: 80.h,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[600],
                                    size: 30.sp,
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 80.w,
                                      height: 80.h,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Service Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Service Title
                                Text(
                                  data.serviceName,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // Provider Name with Icon
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 16.sp,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4.w),
                                    Flexible(
                                      // ✔ Safe alternative, no crash
                                      child: Text(
                                        data.serviceCategory,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 4.h),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  color: Colors.deepOrange.withOpacity(0.7),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15.w,
                                      vertical: 5.h,
                                    ),
                                    child: Text(
                                      "Ongoing",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                              ],
                            ),
                          ),
                          // Arrow Icon
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                    // -------------------- BOOKING INFO --------------------
                    Padding(
                      padding: EdgeInsets.only(left: 15.w, bottom: 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16.sp,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                formatDate(data.bookingDate),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 6.h),

                          // Time
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16.sp,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                "${data.bookingStartTime} - ${data.bookingEndTime}",
                                style: TextStyle(fontSize: 13.sp),
                              ),
                            ],
                          ),

                          SizedBox(height: 6.h),

                          // Duration
                          Row(
                            children: [
                              Icon(
                                Icons.timelapse,
                                size: 16.sp,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                "Duration: ${data.totalDuration}",
                                style: TextStyle(fontSize: 13.sp),
                              ),
                            ],
                          ),

                          SizedBox(height: 6.h),

                          // Price
                          Row(
                            children: [
                              Icon(
                                Icons.currency_rupee,
                                size: 16.sp,
                                color: Colors.green,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "₹${data.totalPrice}",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      error: (err, _) => Center(child: Text(err.toString())),
      loading: () => Center(child: CircularProgressIndicator()),
    );
  }
}
