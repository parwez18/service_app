import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khujo_app/models/categories_model.dart';
import 'package:khujo_app/models/parent_categories_model.dart';

import 'package:khujo_app/models/services_model.dart';

class DatasRepository {
  final _firestore = FirebaseFirestore.instance;

  // Get All Sub-Categories
  Stream<List<CategoriesModel>> getAllCategoriesList() {
    return _firestore.collection("categories").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoriesModel.fromDoc(doc.data(), doc.id))
          .toList();
    });
  }

  // Get All Parent-Categories
  Stream<List<ParentCategoriesModel>> getAllParentCategoriesList() {
    return _firestore.collection("parent_categories").snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => ParentCategoriesModel.fromDoc(doc.data(), doc.id))
          .toList();
    });
  }

  // Get All Sub-Categories whose parent is Booking Service
  Stream<List<CategoriesModel>> getAllBookingServiceCategories() {
    return _firestore
        .collection('categories')
        .where('parent', isEqualTo: "Booking Service")
        .orderBy('createdAt', descending: false) // Ascending Order
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CategoriesModel.fromDoc(doc.data(), doc.id))
              .toList();
        });
  }

  // Get All Sub-Categories whose parent is Travel Booking
  Stream<List<CategoriesModel>> getAllTravelBookingCategories() {
    return _firestore
        .collection('categories')
        .where('parent', isEqualTo: "Travel & Market")
        .orderBy('createdAt', descending: false) // Ascending Order
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CategoriesModel.fromDoc(doc.data(), doc.id))
              .toList();
        });
  }

  // Get All Services
  Stream<List<ServicesModel>> getAllServices() {
    return _firestore.collection("services").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ServicesModel.fromDoc(doc.data(), doc.id))
          .toList();
    });
  }

  // Get Services for specific Service Provider
  Stream<List<ServicesModel>> getAllServicesById(String serviceProviderId) {
    return _firestore
        .collection('services')
        .where('providerId', isEqualTo: serviceProviderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ServicesModel.fromDoc(doc.data(), doc.id))
              .toList();
        });
  }

  // Get Services by their service type
  Stream<List<ServicesModel>> getServicesByServiceType(String serviceType) {
    return _firestore
        .collection('services')
        .where('isActive', isEqualTo: true)
        .where('serviceType', isEqualTo: serviceType)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ServicesModel.fromDoc(doc.data(), doc.id))
              .toList();
        });
  }

  // Fetch services by list of IDs
  Future<List<ServicesModel>> getFavouriteServices(List<String> favIds) async {
    if (favIds.isEmpty) return [];

    final snapshot = await _firestore
        .collection('services')
        .where(FieldPath.documentId, whereIn: favIds)
        .get();

    return snapshot.docs
        .map((doc) => ServicesModel.fromDoc(doc.data(), doc.id))
        .toList();
  }
}
