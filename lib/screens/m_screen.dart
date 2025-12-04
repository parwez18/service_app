import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/Wishlist/wishlist_screen.dart';
import 'package:khujo_app/screens/categories/categories_options_screen.dart';
import 'package:khujo_app/screens/home/home_m_screen.dart';
import 'package:khujo_app/screens/home/booking_service_screen.dart';
import 'package:khujo_app/screens/nearby/nearby_screen.dart';
import 'package:khujo_app/screens/profile/profile_screen.dart';

class MScreen extends ConsumerStatefulWidget {
  const MScreen({super.key});

  @override
  ConsumerState<MScreen> createState() => _MScreenState();
}

class _MScreenState extends ConsumerState<MScreen> {
  int selectedIndex = 0;

  void onTaped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final currentUserAsync = ref.watch(userDataProvider(currentUserId));

    return currentUserAsync.when(
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        final favouriteIds = user?.favourites ?? [];

        /// 👇 Now navTabs is dynamic & correct
        List<Widget> navTabs = [
          HomeMScreen(),
          NearbyScreen(),
          CategoriesOptionsScreen(),
          WishlistScreen(favouriteIds),
          ProfileScreen(),
        ];

        return Scaffold(
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
      },
    );
  }
}
