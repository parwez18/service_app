import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/models/user_model.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/home/location_search_screen.dart';

class AddressScreen extends ConsumerStatefulWidget {
  final UserModel userData;
  const AddressScreen({super.key, required this.userData});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  // TextEditingController _addressController = TextEditingController();

  // double? selectedLat;
  // double? selectedLng;

  // @override
  // void initState() {
  //   super.initState();
  //   _addressController = TextEditingController(
  //     text: widget.userData.userAddress,
  //   );
  //   selectedLat = widget.userData.lat;
  //   selectedLng = widget.userData.lng;
  // }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final currentUserData = ref.watch(userDataProvider(currentUserId));
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 246, 246),
      appBar: customAppBar("Location"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 40.h),

            /// ADDRESS BOX
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                currentUserData.value!.userAddress,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () {
                // Navigate to Location Search Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LocationSearchScreen()),
                );
              },
              child: Center(
                child: Text(
                  "Change Address",
                  style: TextStyle(color: Colors.white, fontSize: 18.sp),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
