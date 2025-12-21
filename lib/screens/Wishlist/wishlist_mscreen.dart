import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/screens/Wishlist/booking_wishlist_widget.dart';
import 'package:khujo_app/screens/Wishlist/travel_wishlist_widget.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';

class WishlistMscreen extends ConsumerStatefulWidget {
  final List<String> favouriteIds;
  final List<String> bookingFavourites;
  const WishlistMscreen({
    super.key,
    required this.favouriteIds,
    required this.bookingFavourites,
  });

  @override
  ConsumerState<WishlistMscreen> createState() => _WishlistMscreenState();
}

class _WishlistMscreenState extends ConsumerState<WishlistMscreen> {
  List<String> parentCategories = ["Booking Service", "Travel & Market"];
  late List<Widget> screens;

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    screens = [
      BookingWishlistWidget(favouriteIds: widget.bookingFavourites),
      TravelWishlistWidget(favouriteIds: widget.favouriteIds),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 248, 248),
      appBar: customAppBar("Favourites"),

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
          SizedBox(height: 10.h),
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
