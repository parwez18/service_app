import 'package:cloud_firestore/cloud_firestore.dart';

class ServicesModel {
  final String id;
  final String providerId;
  final String serviceTitle;
  final String serviceType;
  final String parent;
  final String description;
  final double originalPrice;
  final double discountPrice;
  final String serviceImage;
  final String providerName;
  final String providerAddress;
  final String providerNumber;
  final bool isActive;
  final Timestamp createdAt;
  final double lat;
  final double lng;

  ServicesModel({
    required this.id,
    required this.providerId,
    required this.serviceTitle,
    required this.serviceType,
    required this.parent,
    required this.description,
    required this.originalPrice,
    required this.discountPrice,
    required this.serviceImage,
    required this.providerName,
    required this.providerAddress,
    required this.providerNumber,
    required this.isActive,
    required this.lat,
    required this.lng,
    required this.createdAt,
  });

  /// 🔹 Create object from Firestore document
  factory ServicesModel.fromDoc(Map<String, dynamic> doc, String docId) {
    return ServicesModel(
      id: docId,
      providerId: doc['providerId'] ?? '',
      serviceTitle: doc['serviceTitle'] ?? '',
      serviceType: doc['serviceType'] ?? '',
      parent: doc['parent'] ?? '',
      description: doc['description'] ?? '',
      originalPrice: (doc['originalPrice'] ?? 0).toDouble(),
      discountPrice: (doc['discountPrice'] ?? 0).toDouble(),
      serviceImage: doc['serviceImage'] ?? '',
      providerName: doc['providerName'] ?? '',
      providerAddress: doc['providerAddress'] ?? '',
      providerNumber: doc['providerNumber'] ?? '',
      isActive: doc['isActive'] ?? true,
      createdAt: doc['createdAt'] ?? Timestamp.now(),
      lat: (doc['lat'] ?? 0).toDouble(),
      lng: (doc['lng'] ?? 0).toDouble(),
    );
  }

  /// 🔹 Convert object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'serviceTitle': serviceTitle,
      'serviceType': serviceType,
      'parent': parent,
      'description': description,
      'originalPrice': originalPrice,
      'discountPrice': discountPrice,
      'serviceImage': serviceImage,
      'providerName': providerName,
      'providerAddress': providerAddress,
      'providerNumber': providerNumber,
      'isActive': isActive,
      'lat': lat,
      'lng': lng,
      'createdAt': createdAt,
    };
  }

  /// 🔹 Copy model for partial updates
  ServicesModel copyWith({
    String? id,
    String? providerId,
    String? serviceTitle,
    String? serviceType,
    String? parent,
    String? description,
    double? originalPrice,
    double? discountPrice,
    String? serviceImage,
    String? providerName,
    String? providerAddress,
    String? providerNumber,
    bool? isActive,
    double? lat,
    double? lng,
    Timestamp? createdAt,
  }) {
    return ServicesModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      serviceType: serviceType ?? this.serviceType,
      parent: parent ?? this.parent,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      serviceImage: serviceImage ?? this.serviceImage,
      providerName: providerName ?? this.providerName,
      providerAddress: providerAddress ?? this.providerAddress,
      providerNumber: providerNumber ?? this.providerNumber,
      isActive: isActive ?? this.isActive,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Service(id: $id, title: $serviceTitle, type: $serviceType, type: $parent, provider: $providerName, price: $discountPrice)';
  }
}
