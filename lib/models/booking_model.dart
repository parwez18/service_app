import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khujo_app/models/booking_service_item.dart';

class BookingModel {
  final String bookingId;
  final String bookedServiceId;
  final DateTime bookingDate;
  final String bookingStartTime;
  final String bookingEndTime;
  final String bookingTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String paymentMethod;
  final String paymentStatus;
  final String refund;
  final int otp;
  final String providerAddress;
  final String providerPhone;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
  final List<BookingServiceItem> selectedServices;
  final String status;
  final String totalDuration;
  final num totalPrice;

  // User info
  final String userId;
  final String userName;
  final String userPhone;
  final String userAddress;
  final String userImage;

  // Service Provider info
  final String serviceProviderId;
  final String serviceName;
  final String serviceCategory;
  final String serviceImage;
  final bool serviceProviderPaid;

  // For Rating
  final double? userRating;
  final String? userReview;
  final DateTime? ratedAt;
  final bool hasRated;

  BookingModel({
    required this.bookingId,
    required this.bookedServiceId,
    required this.bookingDate,
    required this.bookingStartTime,
    required this.bookingEndTime,
    required this.bookingTime,
    required this.createdAt,
    required this.updatedAt,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.refund,
    required this.otp,
    required this.providerAddress,
    required this.providerPhone,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
    required this.selectedServices,
    required this.status,
    required this.totalDuration,
    required this.totalPrice,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
    required this.userImage,
    required this.serviceProviderId,
    required this.serviceName,
    required this.serviceCategory,
    required this.serviceImage,
    required this.serviceProviderPaid,
    required this.userRating,
    required this.userReview,
    required this.ratedAt,
    required this.hasRated,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'] ?? '',
      bookedServiceId: map['bookedServiceId'] ?? '',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      bookingStartTime: map['bookingStartTime'] ?? '',
      bookingEndTime: map['bookingEndTime'] ?? '',
      bookingTime: map['bookingTime'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : (map['createdAt'] as Timestamp).toDate(),

      paymentMethod: map['paymentMethod'] ?? '',
      paymentStatus: map['paymentStatus'] ?? '',
      refund: map['refund'] ?? '',
      otp: map['otp'] ?? 0,
      providerAddress: map['providerAddress'] ?? '',
      providerPhone: map['providerPhone'] ?? '',
      razorpayOrderId: map['razorpayOrderId'] ?? '',
      razorpayPaymentId: map['razorpayPaymentId'] ?? '',
      razorpaySignature: map['razorpaySignature'] ?? '',
      selectedServices: (map['selectedServices'] as List? ?? [])
          .map((e) => BookingServiceItem.fromMap(e))
          .toList(),
      status: map['status'] ?? 'pending',
      totalDuration: map['totalDuration'] ?? '',
      totalPrice: map['totalPrice'] ?? 0,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      userAddress: map['userAddress'] ?? '',
      userImage: map['userImage'] ?? '',
      serviceProviderId: map['serviceProviderId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      serviceCategory: map['serviceCategory'] ?? '',
      serviceImage: map['serviceImage'] ?? '',
      serviceProviderPaid: map['serviceProviderPaid'] ?? false,
      userRating: map['userRating']?.toDouble(),
      userReview: map['userReview'],
      ratedAt: map['ratedAt'] != null
          ? (map['ratedAt'] as Timestamp).toDate()
          : null,
      hasRated: map['hasRated'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'bookedServiceId': bookedServiceId,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'bookingStartTime': bookingStartTime,
      'bookingEndTime': bookingEndTime,
      'bookingTime': bookingTime,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'refund': refund,
      'otp': otp,
      'providerAddress': providerAddress,
      'providerPhone': providerPhone,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
      'selectedServices': selectedServices.map((e) => e.toMap()).toList(),
      'status': status,
      'totalDuration': totalDuration,
      'totalPrice': totalPrice,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'userImage': userImage,
      'serviceProviderId': serviceProviderId,
      'serviceName': serviceName,
      'serviceCategory': serviceCategory,
      'serviceImage': serviceImage,
      'serviceProviderPaid': serviceProviderPaid,
      'userRating': userRating, // ADD THIS
      'userReview': userReview, // ADD THIS
      'ratedAt': ratedAt != null
          ? Timestamp.fromDate(ratedAt!)
          : null, // ADD THIS
      'hasRated': hasRated, // ADD THIS
    };
  }
}
