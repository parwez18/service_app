import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/service_provider/screens/bookings_for_service_provider/canceled_booking_SP_widget.dart';

import 'package:khujo_app/service_provider/screens/bookings_for_service_provider/completed_bookings_SP_screen.dart';
import 'package:khujo_app/service_provider/screens/bookings_for_service_provider/new_booking_requests_widget.dart';
import 'package:khujo_app/service_provider/screens/bookings_for_service_provider/ongoing_booking_SP_widget.dart';
import 'package:khujo_app/service_provider/screens/bookings_for_service_provider/rejected_bookings_SP_widget.dart';
import 'package:khujo_app/service_provider/screens/bookings_for_service_provider/upcoming_bookings_SP_widget.dart';

class BookingMscreen extends StatefulWidget {
  const BookingMscreen({super.key});

  @override
  State<BookingMscreen> createState() => _BookingMscreenState();
}

class _BookingMscreenState extends State<BookingMscreen> {
  List<String> tabs = [
    "Booking Requests",
    "Upcoming",
    "Ongoing",
    "Completed",
    "Rejected",
    "Cancelled",
  ];
  List<Widget> screens = [
    NeBookingsRequestSPWidget(),
    UpcomingBookingsSPWidget(),
    OngoingBookingsSPWidget(),
    CompletedBookingsSPWidget(),
    RejectedBookingsSPWidget(),
    CanceledBookingSpWidget(),
  ];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.secondaryColor,
      appBar: customAppBar("Bookings"),
      body: Column(
        children: [
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.only(left: 15.w),
            child: SizedBox(
              height: 53.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  var data = tabs[index];
                  final isSelecetd = selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 5.w),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        color: isSelecetd
                            ? AppConstants.primaryColor
                            : Colors.white,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Center(
                            child: Text(
                              data,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 19.sp,
                                color: isSelecetd ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: screens[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
