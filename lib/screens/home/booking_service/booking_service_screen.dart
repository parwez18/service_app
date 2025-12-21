import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/categories/categories_options_screen.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/home/booking_service/booking_service_widget.dart';
import 'package:khujo_app/screens/home/services_widget.dart';
import 'package:khujo_app/screens/login/send_otp_screen.dart';
import 'package:khujo_app/screens/profile/profile_screen.dart';

class BookingServiceScreen extends ConsumerStatefulWidget {
  const BookingServiceScreen({super.key});

  @override
  ConsumerState<BookingServiceScreen> createState() =>
      _BookingServiceScreenState();
}

class _BookingServiceScreenState extends ConsumerState<BookingServiceScreen> {
  int selectedIndex = 0;
  String selectedCategory = "Salon";
  @override
  Widget build(BuildContext context) {
    final allBookingServiceCategoriesAsync = ref.watch(
      allBookingServiceCategoriesListProvider,
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 246, 246),
      body: allBookingServiceCategoriesAsync.when(
        data: (allCategoriesData) {
          if (allCategoriesData.isEmpty) {
            return SizedBox();
          }

          final displayedCategories = allCategoriesData.length > 3
              ? allCategoriesData.sublist(0, 3)
              : allCategoriesData;

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10.h),
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    // childAspectRatio: 0.85,
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
                            selectedCategory = data.title;
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
                              Image.network(
                                data.logoPath,
                                height: 48.h,
                                color: isSelected
                                    ? Colors.white
                                    : AppConstants.primaryColor,
                                colorBlendMode: BlendMode.srcIn,
                              ),
                              SizedBox(height: 5.h),
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
                SizedBox(height: 20.h),
                BookingServiceWidget(serviceCategoryName: selectedCategory),
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
