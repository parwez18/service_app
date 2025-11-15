import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/home/categories/categories_full_list.dart';
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
                crossAxisCount: 2,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // your radius
                      side: BorderSide(
                        color: AppConstants.primaryColor,
                        width: 1,
                      ),
                    ),
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        data.title,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w400,
                        ),
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
