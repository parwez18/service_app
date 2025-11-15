import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final String userType; // e.g., "Service Provider" or "Customer"
  final String userAddress;
  final String userImage;
  final bool isVerified;
  final List<String> userRoles; // e.g., ["Plumber", "Electrician"]
  final Timestamp createdAt;
  final Timestamp updatedAt;

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
  });

  // ✅ Convert Firestore document to UserModel
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
    );
  }

  // ✅ Convert UserModel to Firestore map
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
    };
  }
}
