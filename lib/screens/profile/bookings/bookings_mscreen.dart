import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/models/user_model.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/profile/bookings/completed_booking_widget.dart';
import 'package:khujo_app/screens/profile/bookings/ongoing_booking_widget.dart';
import 'package:khujo_app/screens/profile/bookings/pending_booking_widget.dart';
import 'package:khujo_app/screens/profile/bookings/rejected_booking_widget.dart';
import 'package:khujo_app/screens/profile/bookings/upcoming_booking_widget.dart';

class BookingsMscreen extends StatefulWidget {
  final UserModel userData;
  const BookingsMscreen({super.key, required this.userData});

  @override
  State<BookingsMscreen> createState() => _BookingsMscreenState();
}

class _BookingsMscreenState extends State<BookingsMscreen> {
  List<String> tabs = [
    "Pending",
    "Upcoming",
    "Ongoing",
    "Completed",
    "Rejected",
  ];
  List<Widget> screens = [
    PendingBookingWidget(),
    UpcomingBookingWidget(),
    OngoingBookingWidget(),
    CompletedBookingWidget(),
    RejectedBookingWidget(),
  ];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.secondaryColor,
      appBar: customAppBar("Booking Info"),
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
