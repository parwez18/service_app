import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/home/services_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final allCategoriesAsync = ref.watch(allCategoriesListProvider);

    return Scaffold(
      drawer: Drawer(),
      appBar: customAppBar("Home"),
      body: Padding(
        padding: EdgeInsets.only(left: 10.w),
        child: Column(
          children: [
            SizedBox(height: 15.h),
            allCategoriesAsync.when(
              data: (allCategoriesData) {
                if (allCategoriesData.isEmpty) {
                  return SizedBox();
                }
                // CURRENT SELECTED CATEGORY NAME
                final selectedServiceType =
                    allCategoriesData[selectedIndex].title;
                return Column(
                  children: [
                    SizedBox(
                      height: 50.h,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: allCategoriesData.length,
                        itemBuilder: (context, index) {
                          var data = allCategoriesData[index];
                          final isSelected = selectedIndex == index;
                          return Padding(
                            padding: EdgeInsets.only(right: 5.w),
                            child: GestureDetector(
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 13.w,
                                  ),
                                  child: Center(
                                    child: Text(
                                      data.title,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: ServicesWidget(selectedServiceType),
                    ),
                  ],
                );
              },
              error: (err, _) => Center(child: Text(err.toString())),
              loading: () => Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
