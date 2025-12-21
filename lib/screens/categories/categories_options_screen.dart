import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/categories/categories_full_list.dart';
import 'package:khujo_app/screens/home/services_widget.dart';

class CategoriesOptionsScreen extends ConsumerStatefulWidget {
  const CategoriesOptionsScreen({super.key});

  @override
  ConsumerState<CategoriesOptionsScreen> createState() =>
      _CategoriesOptionsScreenState();
}

class _CategoriesOptionsScreenState
    extends ConsumerState<CategoriesOptionsScreen> {
  @override
  Widget build(BuildContext context) {
    final allCategoriesAsync = ref.watch(allCategoriesListProvider);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 246, 246),
      appBar: customAppBar("Categories"),
      body: allCategoriesAsync.when(
        data: (allCategoriesData) {
          if (allCategoriesData.isEmpty) {
            return Center(child: Text("No Categories Available"));
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6.w,
              ),
              itemCount: allCategoriesData.length,
              itemBuilder: (context, index) {
                var data = allCategoriesData[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CategoriesFullList(serviceType: data.title),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    color: Colors.white,
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
                            height: 43.h,
                            color: AppConstants.primaryColor,
                            colorBlendMode: BlendMode.srcIn,
                          ),
                          SizedBox(height: 3.h),
                          Center(
                            child: Text(
                              data.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.black,
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
          );
        },
        error: (err, _) => Center(child: Text(err.toString())),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
