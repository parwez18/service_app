import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/login/send_otp_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Profile"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          children: [
            SizedBox(height: 40.w),

            // Image Section
            CircleAvatar(
              radius: 80,
              child: Image.asset('assets/images/user2.png'),
            ),
            SizedBox(height: 20.h),
            // Edit Profile
            _buildSections(
              icon: Icons.edit,
              title: "Edit Profile",
              onTap: () {},
            ),
            SizedBox(height: 10.h),
            Container(
              height: 2.h,
              width: 1.sw,
              color: const Color.fromARGB(255, 194, 193, 193),
            ),
            SizedBox(height: 10.h),
            // Logout
            GestureDetector(
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
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 60.w,
                    top: 10.h,
                    bottom: 10.h,
                    right: 40.w,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 30.sp),
                      SizedBox(width: 15.w),
                      Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(
            left: 60.w,
            top: 10.h,
            bottom: 10.h,
            right: 40.w,
          ),
          child: Row(
            children: [
              Icon(icon, size: 28.sp),
              SizedBox(width: 15.w),
              Text(
                title,
                style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w500),
              ),
              Spacer(),
              Text(
                ">",
                style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
