import 'package:cloud_firestore/cloud_firestore.dart';

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
    };
  }
}
