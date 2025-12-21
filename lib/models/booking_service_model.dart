import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khujo_app/models/service_item_model.dart';

class BookingServiceModel {
  final String id; // 👈 NEW
  final String name;
  final String description;
  final String serviceProviderId; // 👈 Firebase Auth UID of provider
  final String ownerName;
  final String ownerNumber;
  final String parent;
  final String serviceCategory;
  final String openingTime;
  final String closingTime;
  final String startDay;
  final String endDay;
  final String imageUrl;
  final String providerAddress;
  final bool isOpen;
  final bool isActive;
  final double lat;
  final double lng;
  final DateTime createdAt;
  final List<ServiceItem> services;
  final double averageRating;
  final int totalRatings;
  final int totalReviews;

  BookingServiceModel({
    required this.id, // 👈 NEW
    required this.name,
    required this.description,
    required this.serviceProviderId, // 👈 Provider UID
    required this.ownerName,
    required this.ownerNumber,
    required this.parent,
    required this.serviceCategory,
    required this.openingTime,
    required this.closingTime,
    required this.startDay,
    required this.endDay,
    required this.imageUrl,
    required this.providerAddress,
    required this.isOpen,
    required this.isActive,
    required this.lat,
    required this.lng,
    required this.createdAt,
    required this.services,
    required this.averageRating,
    required this.totalRatings,
    required this.totalReviews,
  });

  // --------------------------
  // FROM FIRESTORE
  // --------------------------
  factory BookingServiceModel.fromDoc(DocumentSnapshot doc, String id) {
    final map = doc.data() as Map<String, dynamic>;

    return BookingServiceModel(
      id: doc.id, // 👈 Firestore document ID
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      serviceProviderId: map['serviceProviderId'] ?? '', // 👈 Provider UID
      ownerName: map['ownerName'] ?? '',
      ownerNumber: map['ownerNumber'] ?? '',
      parent: map['parent'] ?? '',
      serviceCategory: map['serviceCategory'] ?? '',
      openingTime: map['openingTime'] ?? '',
      closingTime: map['closeingTime'] ?? '',
      startDay: map['startDay'] ?? '',
      endDay: map['endDay'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      providerAddress: map['providerAddress'] ?? '',
      isOpen: map['isOpen'] ?? true,
      isActive: map['isActive'] ?? true,
      lat: (map['lat'] ?? 0).toDouble(),
      lng: (map['lng'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      services: (map['services'] as List<dynamic>? ?? [])
          .map((e) => ServiceItem.fromMap(e))
          .toList(),
      averageRating: map['averageRating'] ?? 0.0,
      totalRatings: map['totalRatings'] ?? 0,
      totalReviews: map['totalReviews'] ?? 0,
    );
  }

  // --------------------------
  // TO FIRESTORE
  // --------------------------
  Map<String, dynamic> toMap() {
    return {
      // id is NOT stored unless you want to store it explicitly
      'name': name,
      'description': description,
      'serviceProviderId': serviceProviderId, // 👈 Provider UID
      'ownerName': ownerName,
      'ownerNumber': ownerNumber,
      'parent': parent,
      'serviceCategory': serviceCategory,
      'openingTime': openingTime,
      'closeingTime': closingTime,
      'startDay': startDay,
      'endDay': endDay,
      'imageUrl': imageUrl,
      'providerAddress': providerAddress,
      'isOpen': isOpen,
      'isActive': isActive,
      'lat': lat,
      'lng': lng,
      'createdAt': createdAt,
      'services': services.map((e) => e.toMap()).toList(),
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'totalReviews': totalReviews,
    };
  }
}
