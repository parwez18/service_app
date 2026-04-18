import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/models/booking_model.dart';
import 'package:khujo_app/provider/helper_provider.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';

class RatingScreen extends ConsumerStatefulWidget {
  final BookingModel bookingData;
  RatingScreen({super.key, required this.bookingData});

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  final TextEditingController _ratingController = TextEditingController();

  final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> saveFeedBack(
    String currentUserId,
    String currentUserName,
    int stars,
    String feedBack,
  ) async {
    if (!_key.currentState!.validate()) return;
    try {
      // Use bookingId as document ID instead of userId
      // This allows multiple reviews per user for different bookings
      await FirebaseFirestore.instance
          .collection("bookingServices")
          .doc(widget.bookingData.bookedServiceId)
          .collection('reviews')
          .doc(widget.bookingData.bookingId)
          .set({
            'userId': currentUserId,
            'userName': currentUserName,
            'bookingId': widget.bookingData.bookingId,
            'bookedServiceId': widget.bookingData.bookedServiceId,
            'serviceName': widget.bookingData.serviceName,
            'stars': stars,
            'feedBack': feedBack,
            'createdAt': Timestamp.now(),
          });

      await FirebaseFirestore.instance
          .collection("bookings")
          .doc(widget.bookingData.bookingId)
          .collection('reviews')
          .doc(currentUserId)
          .set({
            'userId': currentUserId,
            'userName': currentUserName,
            'bookingId': widget.bookingData.bookingId,
            'bookedServiceId': widget.bookingData.bookedServiceId,
            'serviceName': widget.bookingData.serviceName,
            'stars': stars,
            'feedBack': feedBack,
            'createdAt': Timestamp.now(),
          });

      _ratingController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Rating submitted")));
      Navigator.pop(context); // Go back after successful submission
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting rating: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final currentUserData = ref.watch(userDataProvider(currentUserId));
    final ratingStars = ref.watch(ratingProvider);
    final isLoading = ref.watch(isLoadingProvider);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 229, 229),
      appBar: customAppBar("FeedBack"),
      body: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Container(
                color: Colors.white,
                // height: 200.h,
                width: 1.sw,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rate Your Experience",
                        style: TextStyle(fontSize: 28.sp),
                      ),
                      Text(
                        "Are you Satisfied with the Service?",
                        style: TextStyle(color: Colors.grey, fontSize: 15.sp),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              final currentRating = ref.read(ratingProvider);
                              if (currentRating == index + 1) {
                                // If clicking the same star, decrease by 1
                                ref.read(ratingProvider.notifier).state = index;
                              } else {
                                // Otherwise, set the new rating
                                ref.read(ratingProvider.notifier).state =
                                    index + 1;
                              }
                            },
                            child: Icon(
                              Iconsax.star1,
                              size: 55.sp,
                              color: index < ratingStars
                                  ? Colors.amber
                                  : Colors.grey.shade400,
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 10.h),
                      Divider(
                        color: const Color.fromARGB(255, 185, 185, 185),
                        thickness: 1,
                      ),
                      SizedBox(height: 5.h),
                      TextFormField(
                        controller: _ratingController,
                        maxLines: 7,
                        decoration: InputDecoration(
                          hintText: "Describe your experience",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please describe experience";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 15.h,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: () async {
                      // final currentRatingValue=ref.read(ratingProvider);
                      if (ratingStars == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Rate at least one star"),
                          ),
                        );
                        return;
                      }
                      ref.read(isLoadingProvider.notifier).state = true;
                      await Future.delayed(const Duration(seconds: 2));
                      await saveFeedBack(
                        currentUserData.value!.uid,
                        currentUserData.value!.name,
                        ratingStars,
                        _ratingController.text.trim(),
                      );
                      // reset
                      ref.read(ratingProvider.notifier).state = 0;
                      ref.read(isLoadingProvider.notifier).state = false;
                    },
                    child: Center(
                      child: isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3.2,
                            )
                          : Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
