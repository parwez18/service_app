import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewsWidget extends ConsumerWidget {
  final String serviceId;
  const ReviewsWidget({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReviewsAsync = ref.watch(reviewByServiceIdProvider(serviceId));
    final averageRatingAsync = ref.watch(averageRatingProvider(serviceId));
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 247, 247),
      appBar: customAppBar("Customer Feedback"),
      body: Column(
        children: [
          SizedBox(height: 30.w),
          Text(
            "Overall Rating",

            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25.sp,
              color: const Color.fromARGB(255, 83, 83, 83),
            ),
          ),
          Text(
            averageRatingAsync.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 77.sp,
              height: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  Iconsax.star1,
                  size: 35.sp,
                  color: index < averageRatingAsync
                      ? Colors.amber
                      : Colors.grey.shade400,
                );
              }),
            ],
          ),
          Text(
            "Based on ${allReviewsAsync.value!.length.toString()} Reviews",
            style: TextStyle(fontSize: 18.sp),
          ),
          SizedBox(height: 10.h),
          allReviewsAsync.when(
            data: (reviewData) {
              return ListView.builder(
                itemCount: reviewData.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var data = reviewData[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 13.w,
                      vertical: 2.h,
                    ),
                    child: Card(
                      elevation: 4,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 15.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,

                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  child: Icon(Icons.person, size: 35.sp),
                                ),
                                SizedBox(width: 5.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.w),
                                      child: Text(
                                        data.userName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        ...List.generate(5, (index) {
                                          return Icon(
                                            Iconsax.star1,
                                            size: 20.sp,
                                            color: index < data.stars
                                                ? Colors.amber
                                                : Colors.grey.shade400,
                                          );
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Text(
                                  timeago.format(data.createdAt),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              data.feedBack,
                              style: TextStyle(
                                color: const Color.fromARGB(255, 99, 98, 98),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            error: (err, _) => Center(child: Text(err.toString())),
            loading: () => Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
