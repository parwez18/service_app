import 'package:cloud_firestore/cloud_firestore.dart';

class ServicesModel {
  final String id;
  final String providerId; // 👈 Helps identify who added the service
  final String serviceTitle;
  final String serviceType;
  final String description;
  final double originalPrice;
  final double discountPrice;
  final String serviceImage;
  final String providerName;
  final String providerAddress;
  final String providerNumber;
  final bool isActive;
  final Timestamp createdAt;

  ServicesModel({
    required this.id,
    required this.providerId,
    required this.serviceTitle,
    required this.serviceType,
    required this.description,
    required this.originalPrice,
    required this.discountPrice,
    required this.serviceImage,
    required this.providerName,
    required this.providerAddress,
    required this.providerNumber,
    required this.isActive,
    required this.createdAt,
  });

  /// ✅ Create object from Firestore document
  factory ServicesModel.fromDoc(Map<String, dynamic> doc, String docId) {
    return ServicesModel(
      id: docId,
      providerId: doc['providerId'] ?? '',
      serviceTitle: doc['serviceTitle'] ?? '',
      serviceType: doc['serviceType'] ?? '',
      description: doc['description'] ?? '',
      originalPrice: (doc['originalPrice'] ?? 0).toDouble(),
      discountPrice: (doc['discountPrice'] ?? 0).toDouble(),
      serviceImage: doc['serviceImage'] ?? '',
      providerName: doc['providerName'] ?? '',
      providerAddress: doc['providerAddress'] ?? '',
      providerNumber: doc['providerNumber'] ?? '',
      isActive: doc['isActive'] ?? true,
      createdAt: doc['createdAt'] ?? Timestamp.now(),
    );
  }

  /// ✅ Convert object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'serviceTitle': serviceTitle,
      'serviceType': serviceType,
      'description': description,
      'originalPrice': originalPrice,
      'discountPrice': discountPrice,
      'serviceImage': serviceImage,
      'providerName': providerName,
      'providerAddress': providerAddress,
      'providerNumber': providerNumber,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  /// ✅ CopyWith method (for partial updates)
  ServicesModel copyWith({
    String? id,
    String? providerId,
    String? serviceTitle,
    String? serviceType,
    String? description,
    double? originalPrice,
    double? discountPrice,
    String? serviceImage,
    String? providerName,
    String? providerAddress,
    String? providerNumber,
    bool? isActive,
    Timestamp? createdAt,
  }) {
    return ServicesModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      serviceImage: serviceImage ?? this.serviceImage,
      providerName: providerName ?? this.providerName,
      providerAddress: providerAddress ?? this.providerAddress,
      providerNumber: providerNumber ?? this.providerNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// ✅ For debugging/logging
  @override
  String toString() {
    return 'Service(id: $id, title: $serviceTitle, type: $serviceType, provider: $providerName, price: $discountPrice)';
  }
}
