import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/screens/home/service_detailed_page.dart';

class ServicesWidget extends ConsumerStatefulWidget {
  final String serviceType;
  const ServicesWidget(this.serviceType, {super.key});

  @override
  ConsumerState<ServicesWidget> createState() => _ServicesWidgetState();
}

class _ServicesWidgetState extends ConsumerState<ServicesWidget> {
  @override
  Widget build(BuildContext context) {
    final allServicesByServiceTypeAsync = ref.watch(
      getServicesByServiceTypeProvider(widget.serviceType),
    );
    return allServicesByServiceTypeAsync.when(
      data: (allServiceData) {
        if (allServiceData.isEmpty) {
          return Center(child: Text("No Services Available"));
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: allServiceData.length,
          itemBuilder: (context, index) {
            var data = allServiceData[index];
            return Card(
              color: Colors.white,
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: InkWell(
                onTap: () {
                  // Navigate to service details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ServiceDetailedPage(serviceData: data),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 20.h,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          data.serviceImage,
                          width: 100.w,
                          height: 100.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80.w,
                              height: 80.h,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[600],
                                size: 30.sp,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 80.w,
                              height: 80.h,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Service Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Service Title
                            Text(
                              data.serviceTitle,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Provider Name with Icon
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 16.sp,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    data.providerName,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            // Service Type Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                data.serviceType,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            // Price Section
                            Row(
                              children: [
                                // Discounted Price
                                Text(
                                  '₹${data.discountPrice}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                // Original Price (strikethrough)
                                if (data.discountPrice < data.originalPrice)
                                  Text(
                                    '₹${data.originalPrice}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey[500],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                SizedBox(width: 8.w),
                                // Discount Percentage
                                if (data.discountPrice < data.originalPrice)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[100],
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      '${(((data.originalPrice - data.discountPrice) / data.originalPrice) * 100).toInt()}% OFF',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Arrow Icon
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: Colors.grey[400],
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
    );
  }
}
