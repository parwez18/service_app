import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/repository/helper_repository/helper_repo.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/login/send_otp_screen.dart';
import 'package:khujo_app/screens/profile/address_screen.dart';
import 'package:khujo_app/screens/profile/bookings/bookings_mscreen.dart';
import 'package:khujo_app/screens/profile/edit_profile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final currentUserAync = ref.watch(userDataProvider(currentUserId));
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 248, 248),
      appBar: customAppBar("Profile"),
      body: currentUserAync.when(
        data: (currentUserData) {
          return Padding(
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

                SizedBox(height: 5.h),
                // Edit Profile
                _buildSections(
                  icon: Icons.edit,
                  title: "Edit Profile",
                  onTap: () {
                    // Navigate to Edit Profile screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditProfileScreen(userData: currentUserData),
                      ),
                    );
                  },
                ),

                // Address / Location
                _buildSections(
                  icon: Icons.location_on,
                  title: "Location",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddressScreen(userData: currentUserData),
                      ),
                    );
                  },
                ),

                // Bookings
                _buildSections(
                  icon: Icons.book_outlined,
                  title: "Bookings",
                  onTap: () {
                    // Navigate to Edit Profile screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookingsMscreen(userData: currentUserData),
                      ),
                    );
                  },
                ),

                SizedBox(height: 5.h),
                // Help & Support
                _buildSections(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => HelpSupportScreen(
                    //       userGender: datas.gender.toString(),
                    //     ),
                    //   ),
                    // );
                  },
                ),
                SizedBox(height: 5.h),
                // Terms & Conditions
                _buildSections(
                  icon: Icons.description_outlined,
                  title: "Terms & Conditions",
                  onTap: () async {
                    try {
                      await HelperRepoServices.openTermsAndConditions();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open link')),
                      );
                    }
                  },
                ),
                SizedBox(height: 5.h),
                // Privacy Policy
                _buildSections(
                  icon: Icons.privacy_tip_outlined,
                  title: "Privacy Policy",
                  onTap: () async {
                    try {
                      await HelperRepoServices.openPrivacyPolicy();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open link')),
                      );
                    }
                  },
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
          );
        },
        error: (err, _) => Center(child: Text(err.toString())),
        loading: () => Center(child: CircularProgressIndicator()),
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
        elevation: 4,
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
