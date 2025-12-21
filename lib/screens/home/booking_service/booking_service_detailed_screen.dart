import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/models/booking_service_model.dart';
import 'package:khujo_app/models/service_item_model.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/repository/distance_helper.dart';
import 'package:khujo_app/screens/home/booking_service/booking_confirm_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingServiceDetailedScreen extends ConsumerStatefulWidget {
  final BookingServiceModel data;
  const BookingServiceDetailedScreen({super.key, required this.data});

  @override
  ConsumerState<BookingServiceDetailedScreen> createState() =>
      _BookingServiceDetailedScreenState();
}

class _BookingServiceDetailedScreenState
    extends ConsumerState<BookingServiceDetailedScreen> {
  // Store selected services
  final List<ServiceItem> selectedServices = [];

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

    if (doc.exists && doc.data()!["bookingFavourites"] != null) {
      List favs = doc.data()!["bookingFavourites"];

      setState(() {
        isFavourite = favs.contains(widget.data.id);
      });
    }
  }

  Future<void> toggleFavourite(String serviceId, bool newState) async {
    if (newState) {
      await _firestore.collection("users").doc(currentUseruid).update({
        "bookingFavourites": FieldValue.arrayUnion([serviceId]),
      });
    } else {
      await _firestore.collection("users").doc(currentUseruid).update({
        "bookingFavourites": FieldValue.arrayRemove([serviceId]),
      });
    }
  }

  // Calculate total price
  int get totalPrice =>
      selectedServices.fold(0, (sum, service) => sum + service.price);

  // Calculate total duration in minutes
  int get totalDurationInMinutes {
    return selectedServices.fold(0, (sum, service) {
      // Extract minutes from duration string (e.g., "30 minutes" -> 30)
      final match = RegExp(r'(\d+)').firstMatch(service.duration);
      return sum + (match != null ? int.parse(match.group(1)!) : 0);
    });
  }

  // Format duration as "X hours Y minutes"
  String get formattedTotalDuration {
    if (totalDurationInMinutes == 0) return "0 minutes";
    final hours = totalDurationInMinutes ~/ 60;
    final minutes = totalDurationInMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return "$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes > 1 ? 's' : ''}";
    } else if (hours > 0) {
      return "$hours hour${hours > 1 ? 's' : ''}";
    } else {
      return "$minutes minute${minutes > 1 ? 's' : ''}";
    }
  }

  IconData _getServiceIcon(String category) {
    switch (category.toLowerCase()) {
      case 'salon':
        return Icons.content_cut;
      case 'doctor clinic':
        return Icons.medical_services;
      case 'medical store':
        return Icons.local_pharmacy;
      default:
        return Icons.miscellaneous_services;
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
      widget.data.lat,
      widget.data.lng,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 280.h,
            pinned: true,
            backgroundColor: Colors.deepOrange,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.data.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Category
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.name,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.shade50,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              widget.data.serviceCategory,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.w600,
                              ),
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
                                widget.data.id,
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
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.access_time,
                          title: "Working Hours",
                          subtitle:
                              "${widget.data.openingTime} - ${widget.data.closingTime}",
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today,
                          title: "Working Days",
                          subtitle:
                              "${widget.data.startDay} - ${widget.data.endDay}",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),

                  // Owner Info
                  Container(
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25.r,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Owner",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                widget.data.ownerName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Description
                  Text(
                    "About",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    widget.data.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 25.h),

                  // Services List
                  Text(
                    "Available Services",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.data.services.length,
                    itemBuilder: (context, index) {
                      final service = widget.data.services[index];
                      final isSelected = selectedServices.contains(service);
                      return Padding(
                        padding: EdgeInsets.only(bottom: 5.h),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          color: isSelected ? Colors.deepOrange : Colors.white,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedServices.remove(service);
                                } else {
                                  selectedServices.add(service);
                                }
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange.shade50,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Icon(
                                      _getServiceIcon(
                                        widget.data.serviceCategory,
                                      ),
                                      color: Colors.deepOrange,
                                      size: 28.sp,
                                    ),
                                  ),
                                  SizedBox(width: 15.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.name,
                                          style: TextStyle(
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 15.sp,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              service.duration,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "₹${service.price}",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.deepOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                  // Provider Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          widget.data.providerAddress,
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

                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Book Button
      floatingActionButton: selectedServices.isEmpty
          ? null
          : Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Summary Card
                  Container(
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(width: 2, color: Colors.deepOrange),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${selectedServices.length} Service${selectedServices.length > 1 ? 's' : ''} Selected",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              formattedTotalDuration,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Amount",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "₹$totalPrice",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        // Navigate to Booking Confirmation Screen with data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingConfirmScreen(
                              serviceData: widget.data,
                              selectedServices: selectedServices,
                              totalPrice: totalPrice,
                              totalDuration: formattedTotalDuration,
                            ),
                          ),
                        );
                      },
                      backgroundColor: Colors.deepOrange,
                      icon: const Icon(
                        Icons.event_available,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Book Now",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.sp, color: Colors.deepOrange),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
