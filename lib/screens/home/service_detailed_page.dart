import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/models/services_model.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/repository/distance_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailedPage extends ConsumerStatefulWidget {
  final ServicesModel serviceData;

  const ServiceDetailedPage({super.key, required this.serviceData});

  @override
  ConsumerState<ServiceDetailedPage> createState() =>
      _ServiceDetailedPageState();
}

class _ServiceDetailedPageState extends ConsumerState<ServiceDetailedPage> {
  bool isFavourite = false;

  final currentUseruid = FirebaseAuth.instance.currentUser!.uid;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadFavouriteState();
  }

  Future<void> loadFavouriteState() async {
    final doc = await _firestore.collection("users").doc(currentUseruid).get();

    if (doc.exists && doc.data()!["favourites"] != null) {
      List favs = doc.data()!["favourites"];

      setState(() {
        isFavourite = favs.contains(widget.serviceData.id);
      });
    }
  }

  Future<void> toggleFavourite(String serviceId, bool newState) async {
    if (newState) {
      await _firestore.collection("users").doc(currentUseruid).update({
        "favourites": FieldValue.arrayUnion([serviceId]),
      });
    } else {
      await _firestore.collection("users").doc(currentUseruid).update({
        "favourites": FieldValue.arrayRemove([serviceId]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final currentUserDataAsync = ref
        .watch(userDataProvider(currentUserId))
        .value;
    // Calculate distance
    final distance = calculateDistance(
      currentUserDataAsync!.lat,
      currentUserDataAsync.lng,
      widget.serviceData.lat,
      widget.serviceData.lng,
    );
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
              child: Image.network(
                widget.serviceData.serviceImage,
                fit: BoxFit.cover,
              ),
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
                        widget.serviceData.serviceTitle,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Service Type
                      Text(
                        widget.serviceData.serviceType,
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
                            "₹${widget.serviceData.discountPrice}",
                            style: TextStyle(
                              fontSize: 22.sp,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "₹${widget.serviceData.originalPrice}",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Spacer(),
                          // Favourite section
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                isFavourite = !isFavourite;
                              });
                              await toggleFavourite(
                                widget.serviceData.id,
                                isFavourite,
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 15.w),
                              child: Icon(
                                isFavourite
                                    ? Icons.favorite
                                    : Icons.favorite_border_outlined,

                                color: isFavourite
                                    ? Colors.deepOrange
                                    : Colors.black,
                                size: 32.sp,
                              ),
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
                        widget.serviceData.description,
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
                        widget.serviceData.providerName,
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
                              widget.serviceData.providerAddress,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Distance
                      Padding(
                        padding: EdgeInsets.only(left: 30.w),
                        child: Text(
                          "${distance.toStringAsFixed(1)} km",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Provider Number
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.blue, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            widget.serviceData.providerNumber,
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
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25.r),
                                ),
                              ),
                              builder: (context) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 20.h,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // --- DRAG HANDLE ---
                                      Center(
                                        child: Container(
                                          width: 50.w,
                                          height: 5.h,
                                          margin: EdgeInsets.only(bottom: 15.h),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 10.h),

                                      // --- SERVICE PROVIDER NAME ---
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: Colors.blue,
                                            size: 22.sp,
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Text(
                                              widget.serviceData.providerName,
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 15.h),

                                      // --- CONTACT NUMBER ---
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            color: Colors.green,
                                            size: 22.sp,
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Text(
                                              widget.serviceData.providerNumber,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 20.h),

                                      // --- BUTTONS ---
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 12.h,
                                                ),
                                                backgroundColor:
                                                    Colors.deepOrange,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.r,
                                                      ),
                                                ),
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(
                                                "Close",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 12.h,
                                                ),
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.r,
                                                      ),
                                                ),
                                              ),
                                              onPressed: () {
                                                // CALL PROVIDER
                                                launchUrl(
                                                  Uri.parse(
                                                    "tel:${widget.serviceData.providerNumber}",
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                "Call Now",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 10.h),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
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
