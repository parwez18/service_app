import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/screens/home/categories/categories_options_screen.dart';

import 'package:khujo_app/screens/home/home_screen.dart';
import 'package:khujo_app/screens/profile/profile_screen.dart';

class MScreen extends StatefulWidget {
  const MScreen({super.key});

  @override
  State<MScreen> createState() => _MScreenState();
}

class _MScreenState extends State<MScreen> {
  int selectedIndex = 0;
  List<Widget> navTabs = [
    HomeScreen(),
    Center(child: Text("index 1")),
    CategoriesOptionsScreen(),
    Center(child: Text("index 3")),
    ProfileScreen(),
  ];

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
            icon: Icon(Icons.home, size: 27.sp),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.location5, size: 27.sp),
            label: "Nearby",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.category5, size: 27.sp),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: 27.sp),
            label: "Wishlist",
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
