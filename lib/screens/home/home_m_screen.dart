import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/categories/categories_options_screen.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/home/booking_service/booking_service_screen.dart';
import 'package:khujo_app/screens/home/location_search_screen.dart';
import 'package:khujo_app/screens/home/location_top_bar_widget.dart';
import 'package:khujo_app/screens/home/travel_booking_screen.dart';
import 'package:khujo_app/screens/login/send_otp_screen.dart';
import 'package:khujo_app/screens/profile/profile_screen.dart';

class HomeMScreen extends ConsumerStatefulWidget {
  const HomeMScreen({super.key});

  @override
  ConsumerState<HomeMScreen> createState() => _HomeMScreenState();
}

class _HomeMScreenState extends ConsumerState<HomeMScreen> {
  List<String> parentCategories = ["Booking Service", "Travel & Market"];
  List<Widget> screens = [BookingServiceScreen(), TravelBookingScreen()];

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final currentUserData = ref.watch(userDataProvider(currentUserId));
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 246, 246),
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LocationTopBarWidget(
              address: currentUserData.value!.userAddress,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LocationSearchScreen()),
                );
              },
            ),
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: screens[selectedIndex],
              ),
            ),
          ],
        ),
      ),
      drawer: _drawarWidget(
        ref: ref,
        currentUserName: currentUserData.value!.name,
      ),
    );
  }
}

class _drawarWidget extends StatelessWidget {
  final WidgetRef ref;
  final String currentUserName;
  const _drawarWidget({
    super.key,
    required this.ref,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: 230.h,
            width: 1.sw,
            decoration: BoxDecoration(color: AppConstants.primaryColor),

            child: Column(
              children: [
                SizedBox(height: 30.h),
                Image.asset(
                  "assets/images/user2.png",
                  fit: BoxFit.cover,
                  height: 140.h,
                ),
                Text(
                  currentUserName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          _buildSections(
            icon: Icons.home,
            title: "Home",
            onTap: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 7.h),
          _buildSections(
            icon: Iconsax.profile_circle5,
            title: "Profile",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
          SizedBox(height: 7.h),
          _buildSections(
            icon: Iconsax.category5,
            title: "Categories",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoriesOptionsScreen()),
              );
            },
          ),
          SizedBox(height: 10.h),
          Divider(thickness: 1, color: AppConstants.primaryColor),
          SizedBox(height: 10.h),
          _buildSections(
            icon: Icons.logout,
            title: "Logout",
            onTap: () async {
              // Logout Logic
              try {
                final logOutProvider = ref.read(authRepositoryProvider);
                await logOutProvider.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => SendOtpScreen()),
                );
              } catch (e) {
                print("Error during signout user :  ${e.toString()}");
              }
            },
          ),
        ],
      ),
    );
  }
}

// Common/Helper Widget
class _buildSections extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _buildSections({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          color: AppConstants.primaryColor,
          child: Padding(
            padding: EdgeInsets.only(top: 6.h, bottom: 6.h, left: 40.w),
            child: Row(
              children: [
                Icon(icon, size: 23.sp, color: Colors.white),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
