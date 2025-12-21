import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/models/booking_service_model.dart';
import 'package:khujo_app/models/service_item_model.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/home/booking_service/payment_screen.dart';

class BookingConfirmScreen extends StatefulWidget {
  final BookingServiceModel serviceData;
  final List<ServiceItem> selectedServices;
  final int totalPrice;
  final String totalDuration;
  const BookingConfirmScreen({
    super.key,
    required this.serviceData,
    required this.selectedServices,
    required this.totalPrice,
    required this.totalDuration,
  });

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  DateTime? selectedDate;
  String? selectedTimeSlot;
  bool isLoading = false;

  // Get list of working days
  List<int> get workingDaysIndices {
    final startDay = _getDayIndex(widget.serviceData.startDay);
    final endDay = _getDayIndex(widget.serviceData.endDay);

    List<int> days = [];
    for (int i = startDay; i <= endDay; i++) {
      days.add(i);
    }
    return days;
  }

  // Stream bookings for the selected date and service provider (real-time)
  Stream<List<Map<String, dynamic>>> _streamBookingsForDate(DateTime date) {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      return FirebaseFirestore.instance
          .collection('bookings')
          .where('serviceName', isEqualTo: widget.serviceData.name)
          .where(
            'bookingDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            'bookingDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
          )
          .snapshots()
          .map((snapshot) {
            // Filter by status in memory to avoid needing composite index
            return snapshot.docs
                .map((doc) => doc.data())
                .where(
                  (data) =>
                      data['status'] == 'pending' ||
                      data['status'] == 'confirmed',
                )
                .toList();
          });
    } catch (e) {
      print('Error streaming bookings: $e');
      return Stream.value([]);
    }
  }

  // Check if a time slot conflicts with existing bookings
  bool _isSlotBooked(String slot, List<Map<String, dynamic>> bookings) {
    final slotStart = _parseTime(slot);
    if (slotStart == null) return false;

    final serviceDuration = _extractMinutes(widget.totalDuration);
    final slotEnd = slotStart.add(Duration(minutes: serviceDuration));

    for (var booking in bookings) {
      final bookedStart = _parseTime(booking['bookingStartTime'] ?? '');
      final bookedEnd = _parseTime(booking['bookingEndTime'] ?? '');

      if (bookedStart == null || bookedEnd == null) continue;

      // Check for overlap
      // Slot overlaps if it starts before booked ends AND ends after booked starts
      if (slotStart.isBefore(bookedEnd) && slotEnd.isAfter(bookedStart)) {
        return true; // Slot is booked
      }
    }

    return false; // Slot is available
  }

  // Convert day name to index (Monday = 1, Sunday = 7)
  int _getDayIndex(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 1;
      case 'tuesday':
        return 2;
      case 'wednesday':
        return 3;
      case 'thursday':
        return 4;
      case 'friday':
        return 5;
      case 'saturday':
        return 6;
      case 'sunday':
        return 7;
      default:
        return 1;
    }
  }

  // Check if date is a working day
  bool isWorkingDay(DateTime date) {
    return workingDaysIndices.contains(date.weekday);
  }

  // Generate time slots based on opening/closing times (sync version)
  List<Map<String, dynamic>> _generateTimeSlotsSync(
    List<Map<String, dynamic>> existingBookings,
  ) {
    List<Map<String, dynamic>> slots = [];

    // Parse opening and closing times
    final openingTime = _parseTime(widget.serviceData.openingTime);
    final closingTime = _parseTime(widget.serviceData.closingTime);

    if (openingTime == null || closingTime == null) return slots;

    // Calculate total service duration in minutes
    final serviceDuration = _extractMinutes(widget.totalDuration);

    // Generate slots based on service duration
    DateTime currentSlot = openingTime;

    // Check if selected date is today
    final now = DateTime.now();
    final isToday = selectedDate != null &&
        selectedDate!.year == now.year &&
        selectedDate!.month == now.month &&
        selectedDate!.day == now.day;

    while (currentSlot
            .add(Duration(minutes: serviceDuration))
            .isBefore(closingTime) ||
        currentSlot
            .add(Duration(minutes: serviceDuration))
            .isAtSameMomentAs(closingTime)) {
      final slotTime = _formatTime(currentSlot);

      // Skip past time slots if the selected date is today
      if (isToday) {
        final slotDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          currentSlot.hour,
          currentSlot.minute,
        );

        // Only add slots that are in the future
        if (slotDateTime.isBefore(now)) {
          currentSlot = currentSlot.add(Duration(minutes: serviceDuration));
          continue;
        }
      }

      final isBooked = _isSlotBooked(slotTime, existingBookings);

      slots.add({'time': slotTime, 'isBooked': isBooked});

      currentSlot = currentSlot.add(Duration(minutes: serviceDuration));
    }

    return slots;
  }

  // Parse time string like "10:00 AM" to DateTime
  DateTime? _parseTime(String timeString) {
    try {
      timeString = timeString.trim();
      final parts = timeString.split(':');
      if (parts.length != 2) return null;

      int hour = int.parse(parts[0].trim());
      final minutePart = parts[1].trim();
      final minute = int.parse(minutePart.split(' ')[0]);
      final period = timeString.toUpperCase();

      // Handle 12-hour format
      if (period.contains('PM')) {
        if (hour != 12) hour += 12;
      } else if (period.contains('AM')) {
        if (hour == 12) hour = 0;
      }

      return DateTime(2000, 1, 1, hour, minute);
    } catch (e) {
      print('Error parsing time: $timeString - $e');
      return null;
    }
  }

  // Format DateTime to time string
  String _formatTime(DateTime time) {
    int hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Extract minutes from duration string
  int _extractMinutes(String duration) {
    int totalMinutes = 0;
    final hourMatch = RegExp(r'(\d+)\s*hour').firstMatch(duration);
    final minuteMatch = RegExp(r'(\d+)\s*minute').firstMatch(duration);

    if (hourMatch != null) {
      totalMinutes += int.parse(hourMatch.group(1)!) * 60;
    }
    if (minuteMatch != null) {
      totalMinutes += int.parse(minuteMatch.group(1)!);
    }

    return totalMinutes > 0 ? totalMinutes : 30;
  }

  // Pick date
  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      selectableDayPredicate: (date) => isWorkingDay(date),
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
        selectedTimeSlot = null; // Reset time when date changes
      });
    }
  }

  // Save booking to Firestore
  Future<void> _confirmBooking() async {
    if (selectedDate == null || selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final userData = userDoc.data() ?? {};

      // Generate unique booking ID
      final bookingId = FirebaseFirestore.instance
          .collection('bookings')
          .doc()
          .id;

      // Calculate end time
      final startTime = _parseTime(selectedTimeSlot!);
      final endTime = startTime?.add(
        Duration(minutes: _extractMinutes(widget.totalDuration)),
      );

      // Create booking data map
      final bookingData = {
        'bookingId': bookingId,
        'userId': userId,
        'userName': userData['name'] ?? '',
        'userPhone': userData['phoneNumber'] ?? '',
        'userAddress': userData['userAddress'] ?? '',
        'userImage': userData['userImage'] ?? '',
        'serviceProviderId': widget.serviceData.serviceProviderId,
        'serviceName': widget.serviceData.name,
        'serviceCategory': widget.serviceData.serviceCategory,
        'serviceImage': widget.serviceData.imageUrl,
        'providerAddress': widget.serviceData.providerAddress,
        'providerPhone': widget.serviceData.ownerNumber,
        'selectedServices': widget.selectedServices
            .map(
              (s) => {'name': s.name, 'price': s.price, 'duration': s.duration},
            )
            .toList(),
        'totalPrice': widget.totalPrice,
        'totalDuration': widget.totalDuration,
        'bookingDate': Timestamp.fromDate(selectedDate!),
        'bookingTime': selectedTimeSlot!,
        'bookingStartTime': selectedTimeSlot!,
        'bookingEndTime': _formatTime(endTime!),
      };

      // Navigate to payment screen with booking data
      if (!mounted) return;

      setState(() => isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(bookingData: bookingData),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar("Confirm Booking"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Info Card
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.deepOrange.shade200),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      widget.serviceData.imageUrl,
                      width: 60.w,
                      height: 60.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60.w,
                        height: 60.h,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.serviceData.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.serviceData.serviceCategory,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25.h),

            // Selected Services
            Text(
              "Selected Services",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            ...widget.selectedServices.map(
              (service) => Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.deepOrange.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            service.duration,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${service.price}",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Total Summary
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Duration", style: TextStyle(fontSize: 14.sp)),
                      Text(
                        widget.totalDuration,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
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
                        "₹${widget.totalPrice}",
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
            SizedBox(height: 25.h),

            // Date Selection
            Text(
              "Select Date",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 16.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20.sp,
                      color: Colors.deepOrange,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        selectedDate == null
                            ? "Choose date (${widget.serviceData.startDay} - ${widget.serviceData.endDay})"
                            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16.sp),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25.h),

            // Time Slot Selection
            Text(
              "Select Time Slot",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            if (selectedDate == null)
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    "Please select a date first",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _streamBookingsForDate(selectedDate!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          "Error loading time slots",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    );
                  }

                  final existingBookings = snapshot.data ?? [];
                  final timeSlots = _generateTimeSlotsSync(existingBookings);

                  if (timeSlots.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          "No available slots for this date",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: timeSlots.map((slotData) {
                      final slot = slotData['time'] as String;
                      final isBooked = slotData['isBooked'] as bool;
                      final isSelected = selectedTimeSlot == slot;

                      return InkWell(
                        onTap: isBooked
                            ? null // Disable tap for booked slots
                            : () => setState(() => selectedTimeSlot = slot),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: isBooked
                                ? Colors
                                      .grey
                                      .shade300 // Gray for booked
                                : isSelected
                                ? Colors
                                      .deepOrange // Orange for selected
                                : Colors.white, // White for available
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isBooked
                                  ? Colors.grey.shade400
                                  : isSelected
                                  ? Colors.deepOrange
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                slot,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isBooked
                                      ? Colors.grey.shade600
                                      : isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              if (isBooked) ...[
                                SizedBox(width: 6.w),
                                Icon(
                                  Icons.block,
                                  size: 16.sp,
                                  color: Colors.red,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            SizedBox(height: 30.h),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: isLoading ? null : _confirmBooking,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Confirm Booking",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
