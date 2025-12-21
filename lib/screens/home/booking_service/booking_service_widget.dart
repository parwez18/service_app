import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/repository/distance_helper.dart';
import 'package:khujo_app/screens/home/booking_service/booking_service_detailed_screen.dart';

class BookingServiceWidget extends ConsumerStatefulWidget {
  final String serviceCategoryName;
  const BookingServiceWidget({super.key, required this.serviceCategoryName});

  @override
  ConsumerState<BookingServiceWidget> createState() =>
      _BookingServiceWidgetState();
}

class _BookingServiceWidgetState extends ConsumerState<BookingServiceWidget> {
  final TextEditingController searchController = TextEditingController();

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final currentUserDataAsync = ref
        .watch(userDataProvider(currentUserId))
        .value;
    final bookingServiceAsync = ref.watch(
      getBookingServiceProvider(widget.serviceCategoryName),
    );
    return Column(
      children: [
        TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search by name",
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value.trim().toLowerCase();
            });
          },
        ),
        SizedBox(height: 10.h),
        bookingServiceAsync.when(
          data: (datas) {
            // 🔎 FILTER LIST BASED ON SEARCH
            final filteredList = datas.where((service) {
              return service.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
            }).toList();

            if (filteredList.isEmpty) {
              return const Center(child: Text("No matching services found"));
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: filteredList.length,

              itemBuilder: (context, index) {
                var data = filteredList[index];
                final distance = calculateDistance(
                  currentUserDataAsync!.lat,
                  currentUserDataAsync.lng,
                  data.lat,
                  data.lng,
                );
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  // margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                              BookingServiceDetailedScreen(data: data),
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
                              data.imageUrl,
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
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 80.w,
                                      height: 80.h,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
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
                                  data.name,
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
                                        data.serviceCategory,
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

                                SizedBox(height: 8.h),

                                // Distance
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.red),

                                    Text(
                                      "${distance.toStringAsFixed(1)} km",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
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
        ),
      ],
    );
  }
}
