import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/models/services_model.dart';

class ServiceDetailedPage extends StatelessWidget {
  final ServicesModel serviceData;
  const ServiceDetailedPage({super.key, required this.serviceData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // ------------------ TOP IMAGE ------------------
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 320.h,
              width: 1.sw,
              child: Image.network(serviceData.serviceImage, fit: BoxFit.cover),
            ),
          ),

          // ------------------ BACK BUTTON ------------------
          Positioned(
            top: 40.h,
            left: 10.w,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // ------------------ BOTTOM CONTENT ------------------
          Positioned(
            top: 280.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
              ),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Title
                      Text(
                        serviceData.serviceTitle,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Service Type
                      Text(
                        serviceData.serviceType,
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 15.h),

                      // Pricing
                      Row(
                        children: [
                          Text(
                            "₹${serviceData.discountPrice}",
                            style: TextStyle(
                              fontSize: 22.sp,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "₹${serviceData.originalPrice}",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // Description
                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      Text(
                        serviceData.description,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Provider Name
                      Text(
                        "Provider Details",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      Text(
                        serviceData.providerName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 15.h),

                      // Provider Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              serviceData.providerAddress,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Provider Number
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.blue, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            serviceData.providerNumber,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // BOOK NOW BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "Book Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
