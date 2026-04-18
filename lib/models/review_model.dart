import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String bookedServiceId;
  final String bookingId;
  final String feedBack;
  final String serviceName;
  final int stars;
  final String userId;
  final String userName;
  final DateTime createdAt;

  ReviewModel({
    required this.bookedServiceId,
    required this.bookingId,
    required this.feedBack,
    required this.serviceName,
    required this.stars,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });

  /// Convert Firestore document → Model
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      bookedServiceId: map['bookedServiceId'] ?? '',
      bookingId: map['bookingId'] ?? '',
      feedBack: map['feedBack'] ?? '',
      serviceName: map['serviceName'] ?? '',
      stars: (map['stars'] ?? 0).toInt(),
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert Model → Firestore document
  Map<String, dynamic> toMap() {
    return {
      'bookedServiceId': bookedServiceId,
      'bookingId': bookingId,
      'feedBack': feedBack,
      'serviceName': serviceName,
      'stars': stars,
      'userId': userId,
      'userName': userName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
