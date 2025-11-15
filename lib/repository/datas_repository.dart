import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khujo_app/models/categories_model.dart';

import 'package:khujo_app/models/services_model.dart';

class DatasRepository {
  final _firestore = FirebaseFirestore.instance;

  // /// ✅ Get all categories (root + subcategories)
  // Stream<List<CategoryModel>> getAllCategories() {
  //   return _firestore.collection('exams').snapshots().map((snapshot) {
  //     return snapshot.docs
  //         .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
  //         .toList();
  //   });
  // }

  // /// ✅ Get only top-level categories (where parentId == null)
  // Stream<List<CategoryModel>> getRootCategories() {
  //   return _firestore
  //       .collection('exams')
  //       .where('category.parentId', isNull: true)
  //       .snapshots()
  //       .map((snapshot) {
  //         return snapshot.docs
  //             .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
  //             .toList();
  //       });
  // }

  // /// ✅ Get subcategories of a specific parent
  // Stream<List<CategoryModel>> getSubcategories(String parentId) {
  //   return _firestore
  //       .collection('exams')
  //       .where('category.parentId', isEqualTo: parentId)
  //       .snapshots()
  //       .map((snapshot) {
  //         return snapshot.docs
  //             .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
  //             .toList();
  //       });
  // }

  // // Get All Data
  // Stream<List<ServiceModel>> getAllData() {
  //   return _firestore.collection('courses').snapshots().map((snapshot) {
  //     return snapshot.docs
  //         .map((doc) => ServiceModel.fromJson(doc.data()))
  //         .toList();
  //   });
  // }

  // // Get All Data by category
  // Stream<List<ServiceModel>> getDataByCategory() {
  //   return _firestore.collection('courses').snapshots().map((snapshot) {
  //     return snapshot.docs
  //         .map((doc) => ServiceModel.fromJson(doc.data()))
  //         .toList();
  //   });
  // }

  // // Get All Provider Roles
  // Stream<List<ProviderRoleModel>> getAllProviderRoles() {
  //   return _firestore.collection("provider_roles").snapshots().map((snapshot) {
  //     return snapshot.docs
  //         .map((doc) => ProviderRoleModel.fromDoc(doc.data(), doc.id))
  //         .toList();
  //   });
  // }

  // Get All Categories
  Stream<List<CategoriesModel>> getAllCategoriesList() {
    return _firestore.collection("categories").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoriesModel.fromDoc(doc.data(), doc.id))
          .toList();
    });
  }

  // Get Services for specific Service Provider
  Stream<List<ServicesModel>> getAllServicesById(String serviceProviderId) {
    return _firestore
        .collection('services')
        .where('providerId', isEqualTo: serviceProviderId)
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
        .where('serviceType', isEqualTo: serviceType)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ServicesModel.fromDoc(doc.data(), doc.id))
              .toList();
        });
  }
}
