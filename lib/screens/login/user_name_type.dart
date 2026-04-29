import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:khujo_app/repository/location_repository.dart';
import 'package:khujo_app/screens/m_screen.dart';
import 'package:khujo_app/service_provider/screens/provider_m_screen.dart';

class UserNameTypeScreen extends StatefulWidget {
  const UserNameTypeScreen({super.key});

  @override
  State<UserNameTypeScreen> createState() => _UserNameTypeScreenState();
}

class _UserNameTypeScreenState extends State<UserNameTypeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final LocationRepository _locationRepository = LocationRepository();

  String? selectedType;
  final _currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  final _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool isLoading = false;
  // Save User Name And Type
  Future<void> saveUserData() async {
    if (_key.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        isLoading = true;
      });
      try {
        await _firestore.collection('users').doc(_currentUserUid).update({
          'name': _nameController.text.trim(),
          'userType': selectedType,
        });
        // Save location safely (won't break flow if GPS fails)
        try {
          await _locationRepository.saveUserAddress(_currentUserUid);
        } catch (e) {
          print("Location not saved: $e");
        }
        // Navigate to screen
        if (selectedType == "Customer") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProviderMScreen()),
          );
        }
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _key,
            child: Column(
              children: [
                SizedBox(height: 100.h),
                Image.asset(
                  'assets/login/userdetails.png',
                  height: 260.h,
                  width: 1.sw,
                ),
                Text(
                  "Enter your name and select type",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 25.h),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Iconsax.profile_tick),
                    hintText: "Enter Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                DropdownButtonFormField2(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: "User Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      color: Colors.white, // dropdown menu bg
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: "Customer",
                      child: Text("Customer"),
                    ),
                    DropdownMenuItem(
                      value: "Service Provider",
                      child: Text("Service Provider"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select user type";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: () async {
                    await saveUserData();
                  },
                  child: Center(
                    child: isLoading
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.h),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Submit",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 19.sp,
                            ),
                          ),
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
