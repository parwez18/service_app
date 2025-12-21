import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/home/booking_service/booking_service_screen.dart';
import 'package:khujo_app/screens/home/travel_booking_screen.dart';
import 'package:khujo_app/screens/nearby/booking_nearby_widget.dart';
import 'package:khujo_app/screens/nearby/travel_nearby_widget.dart';

class NearbyMscreen extends StatefulWidget {
  const NearbyMscreen({super.key});

  @override
  State<NearbyMscreen> createState() => _NearbyMscreenState();
}

class _NearbyMscreenState extends State<NearbyMscreen> {
  List<String> parentCategories = ["Booking Service", "Travel & Market"];

  List<Widget> screens = [BookingNearbyWidget(), TravelNearbyWidget()];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.secondaryColor,
      appBar: customAppBar("Nearby"),
      body: Column(
        children: [
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(parentCategories.length, (index) {
                var data = parentCategories[index];
                final isSelecetd = selectedIndex == index;
                return Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7.w),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelecetd
                              ? AppConstants.primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        height: 44.h,
                        child: Center(
                          child: Text(
                            data,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20.sp,
                              color: isSelecetd ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(child: screens[selectedIndex]),
        ],
      ),
    );
  }
}
