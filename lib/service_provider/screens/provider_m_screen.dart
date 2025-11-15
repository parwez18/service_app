import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:khujo_app/appconstants/appconstants.dart';

import 'package:khujo_app/screens/profile/profile_screen.dart';

import 'package:khujo_app/service_provider/screens/profile/provider_profile_screen.dart';
import 'package:khujo_app/service_provider/screens/provider_home_screen.dart';

class ProviderMScreen extends StatefulWidget {
  const ProviderMScreen({super.key});

  @override
  State<ProviderMScreen> createState() => _ProviderMScreenState();
}

class _ProviderMScreenState extends State<ProviderMScreen> {
  int selectedIndex = 0;
  List<Widget> navTabs = [ProviderHomeScreen(), ProviderProfileScreen()];

  void onTaped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("M Screen")),
      body: navTabs[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.add_circle, size: 27.sp),
            label: "Add Services",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.profile_circle, size: 27.sp),
            label: "Profile",
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: selectedIndex,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: const Color.fromARGB(255, 102, 102, 102),
        onTap: onTaped,
      ),
    );
  }
}
