import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/categories/categories_options_screen.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/login/send_otp_screen.dart';
import 'package:khujo_app/screens/profile/profile_screen.dart';
import 'package:khujo_app/service_provider/screens/booking_service/add_booking_service_screen.dart';
import 'package:khujo_app/service_provider/screens/booking_service/booking_service_widget.dart';
import 'package:khujo_app/service_provider/screens/travel_and_market_service.dart/add_services_screen.dart';
import 'package:khujo_app/service_provider/screens/travel_and_market_service.dart/edit_service_screen.dart';
import 'package:khujo_app/service_provider/screens/travel_and_market_service.dart/travel_and_market_widget.dart';

class ProviderHomeScreen extends ConsumerStatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  ConsumerState<ProviderHomeScreen> createState() => _AddServicesScreenState();
}

class _AddServicesScreenState extends ConsumerState<ProviderHomeScreen> {
  List<String> parentCategories = ["Booking Service", "Travel & Market"];
  List<Widget> screens = [BookingServiceWidget(), TravelAndMarketWidget()];

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final currentUserData = ref.watch(userDataProvider(currentUserId));
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 246, 246),
      appBar: customAppBar("Services"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryColor,
        onPressed: () {
          // Show Bottom Sheets
          showModalBottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 30),
                  Text(
                    "Select Category",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to Booking Service Data
                        Navigator.pop(context); // Close Bottom Sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddBookingServiceScreen(),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),

                          side: BorderSide(width: 1, color: Colors.grey),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.book),
                              Text(
                                "Booking Service",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap: () async {
                        // Navigate to Travel & Market Data
                        Navigator.pop(context); // Close Bottom Sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddServicesScreen(),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),

                          side: BorderSide(width: 1, color: Colors.grey),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.travel_explore),
                              Text(
                                "Travel & Market",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                ],
              );
            },
          );
        },
        child: Icon(Iconsax.add, color: Colors.white),
      ),
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
      drawer: _drawarWidget(
        ref: ref,
        currentUserName: currentUserData.value?.name ?? "User",
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
                SizedBox(height: 40.h),
                Image.asset(
                  "assets/images/user2.png",
                  fit: BoxFit.cover,
                  height: 130.h,
                ),
                Text(
                  currentUserName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23.sp,
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
            icon: Iconsax.add,
            title: "Add Service",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddServicesScreen()),
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
