import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/appconstants/appconstants.dart';

class LocationTopBarWidget extends StatelessWidget {
  final String address;
  final VoidCallback onTap;
  const LocationTopBarWidget({
    super.key,
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final parts = address.split("-");
    final mainPart = parts.length >= 2 ? "${parts[0]}- ${parts[1]}" : parts[0];
    return Container(
      color: AppConstants.primaryColor,
      child: Padding(
        padding: EdgeInsets.only(left: 20.w, bottom: 10.h, right: 80.w),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mainPart, // main part
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                    Text(
                      address, // full address
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.normal,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Icon(Icons.arrow_drop_down, color: Colors.white, size: 30.sp),
          ],
        ),
      ),
    );
  }
}
