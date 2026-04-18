import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String status; // inactive | active | cancelled | failed | expired
  final bool introPaid;
  final String introPaymentId;
  final Timestamp? introPaidAt;
  final String razorpaySubscriptionId;
  final String razorpayCustomerId;
  final Timestamp? startDate;
  final Timestamp? currentPeriodEnd;
  final Timestamp? nextBillingDate;
  final int cyclesCharged;
  final Timestamp? lastChargedAt;
  final Timestamp? cancelledAt;
  final String failureReason;

  SubscriptionModel({
    required this.status,
    required this.introPaid,
    required this.introPaymentId,
    this.introPaidAt,
    required this.razorpaySubscriptionId,
    required this.razorpayCustomerId,
    this.startDate,
    this.currentPeriodEnd,
    this.nextBillingDate,
    required this.cyclesCharged,
    this.lastChargedAt,
    this.cancelledAt,
    required this.failureReason,
  });

  bool get isActive => status == 'active';

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      status: map['status'] ?? 'inactive',
      introPaid: map['introPaid'] ?? false,
      introPaymentId: map['introPaymentId'] ?? '',
      introPaidAt: map['introPaidAt'] as Timestamp?,
      razorpaySubscriptionId: map['razorpaySubscriptionId'] ?? '',
      razorpayCustomerId: map['razorpayCustomerId'] ?? '',
      startDate: map['startDate'] as Timestamp?,
      currentPeriodEnd: map['currentPeriodEnd'] as Timestamp?,
      nextBillingDate: map['nextBillingDate'] as Timestamp?,
      cyclesCharged: map['cyclesCharged'] ?? 0,
      lastChargedAt: map['lastChargedAt'] as Timestamp?,
      cancelledAt: map['cancelledAt'] as Timestamp?,
      failureReason: map['failureReason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'introPaid': introPaid,
      'introPaymentId': introPaymentId,
      'introPaidAt': introPaidAt,
      'razorpaySubscriptionId': razorpaySubscriptionId,
      'razorpayCustomerId': razorpayCustomerId,
      'startDate': startDate,
      'currentPeriodEnd': currentPeriodEnd,
      'nextBillingDate': nextBillingDate,
      'cyclesCharged': cyclesCharged,
      'lastChargedAt': lastChargedAt,
      'cancelledAt': cancelledAt,
      'failureReason': failureReason,
    };
  }
}

class UserModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final String userType;
  final String userAddress;
  final String userImage;
  final bool isVerified;
  final List<String> userRoles;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  // short names
  final double lat;
  final double lng;

  // NEW — short name for favourites
  final List<String> favourites;
  final List<String> bookingFavourites;

  // Subscription (only relevant for Service Providers)
  final SubscriptionModel subscription;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.userType,
    required this.userAddress,
    required this.userImage,
    required this.isVerified,
    required this.userRoles,
    required this.createdAt,
    required this.updatedAt,
    required this.lat,
    required this.lng,
    required this.favourites,
    required this.bookingFavourites,
    required this.subscription,
  });

  factory UserModel.fromDoc(Map<String, dynamic> doc, String docId) {
    return UserModel(
      uid: docId,
      name: doc['name'] ?? '',
      phoneNumber: doc['phoneNumber'] ?? '',
      userType: doc['userType'] ?? '',
      userAddress: doc['userAddress'] ?? '',
      userImage: doc['userImage'] ?? '',
      isVerified: doc['isVerified'] ?? false,
      userRoles: List<String>.from(doc['userRoles'] ?? []),
      createdAt: doc['createdAt'] ?? Timestamp.now(),
      updatedAt: doc['updatedAt'] ?? Timestamp.now(),

      // short names
      lat: (doc['lat'] ?? 0).toDouble(),
      lng: (doc['lng'] ?? 0).toDouble(),

      // NEW
      favourites: List<String>.from(doc['favourites'] ?? []),
      bookingFavourites: List<String>.from(doc['bookingFavourites'] ?? []),

      // Subscription
      subscription: SubscriptionModel.fromMap(
        Map<String, dynamic>.from(doc['subscription'] ?? {}),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'userAddress': userAddress,
      'userImage': userImage,
      'isVerified': isVerified,
      'userRoles': userRoles,
      'createdAt': createdAt,
      'updatedAt': updatedAt,

      // short names
      'lat': lat,
      'lng': lng,

      // NEW
      'favourites': favourites,
      'bookingFavourites': bookingFavourites,

      // Subscription
      'subscription': subscription.toMap(),
    };
  }
}
