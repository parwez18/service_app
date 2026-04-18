import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/categories/categories_options_screen.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/home/services_widget.dart';
import 'package:khujo_app/screens/login/send_otp_screen.dart';
import 'package:khujo_app/screens/profile/profile_screen.dart';

class TravelBookingScreen extends ConsumerStatefulWidget {
  const TravelBookingScreen({super.key});

  @override
  ConsumerState<TravelBookingScreen> createState() =>
      _TravelBookingScreenState();
}

class _TravelBookingScreenState extends ConsumerState<TravelBookingScreen> {
  int selectedIndex = 0;

  Widget _buildNetworkImage(String path, {double? height}) {
    if (path.startsWith('data:image')) {
      final base64String = path.split(',').last;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Image.memory(base64Decode(base64String), height: height),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Image.network(path, height: height),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTravelBookingCategoriesAsync = ref.watch(
      allTravelBookingCategoriesListProvider,
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 246, 246),
      body: allTravelBookingCategoriesAsync.when(
        data: (allCategoriesData) {
          if (allCategoriesData.isEmpty) {
            return SizedBox();
          }

          final displayedCategories = allCategoriesData.length > 8
              ? allCategoriesData.sublist(0, 8)
              : allCategoriesData;
          // CURRENT SELECTED CATEGORY NAME
          final selectedServiceType = displayedCategories[selectedIndex].title;
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to see all categories
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoriesOptionsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.r),
                            color: AppConstants.primaryColor,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          child: Text(
                            "See All",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: displayedCategories.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var data = displayedCategories[index];
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          setState(() {
                            selectedIndex = index;
                          });
                        });
                      },
                      child: Card(
                        color: isSelected
                            ? AppConstants.primaryColor
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildNetworkImage(
                                data.logoPath,
                                // height: 41.h,
                              ),
                              SizedBox(height: 3.h),
                              Center(
                                child: Text(
                                  data.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      selectedServiceType,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                ServicesWidget(selectedServiceType),
              ],
            ),
          );
        },
        error: (err, _) => Center(child: Text(err.toString())),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _drawarWidget extends StatelessWidget {
  final WidgetRef ref;
  const _drawarWidget({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          SizedBox(height: 40.h),
          CircleAvatar(
            backgroundColor: AppConstants.primaryColor,
            backgroundImage: AssetImage("assets/images/user2.png"),
            radius: 70,
          ),
          SizedBox(height: 15.h),
          Divider(thickness: 1, color: AppConstants.primaryColor),
          _buildSections(
            icon: Icons.home,
            title: "Home",
            onTap: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 10.h),
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
          SizedBox(height: 10.h),
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
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        color: AppConstants.primaryColor,
        child: Padding(
          padding: EdgeInsets.only(top: 6.h, bottom: 6.h, left: 30.w),
          child: Row(
            children: [
              Icon(icon, size: 25.sp, color: Colors.white),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
