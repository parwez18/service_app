import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khujo_app/models/booking_model.dart';
import 'package:khujo_app/models/booking_service_model.dart';
import 'package:khujo_app/models/categories_model.dart';
import 'package:khujo_app/models/parent_categories_model.dart';
import 'package:khujo_app/models/review_model.dart';

import 'package:khujo_app/models/services_model.dart';

class DatasRepository {
  final _firestore = FirebaseFirestore.instance;

  // Get All Sub-Categories
  Stream<List<CategoriesModel>> getAllCategoriesList() {
    return _firestore
        .collection("categories")
        .where('parent', isEqualTo: "Travel & Market")
        .snapshots()
        .map((snapshot) {
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

  // Get Travel & Market Services for specific Service Provider
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

  // Get Booking Services for specific Service Provider
  Stream<List<BookingServiceModel>> getAllBookingServicesById(
    String serviceProviderId,
  ) {
    return _firestore
        .collection('bookingServices')
        .where('serviceProviderId', isEqualTo: serviceProviderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingServiceModel.fromDoc(doc, doc.id))
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

  // Fetch Travel and Market favourite services by list of IDs
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

  // Fetch Booking favourite services by list of IDs
  Future<List<BookingServiceModel>> getBookingFavouriteServices(
    List<String> favIds,
  ) async {
    if (favIds.isEmpty) return [];

    final snapshot = await _firestore
        .collection('bookingServices')
        .where(FieldPath.documentId, whereIn: favIds)
        .get();

    return snapshot.docs
        .map((doc) => BookingServiceModel.fromDoc(doc, doc.id))
        .toList();
  }

  // Get All Booking Services
  Stream<List<BookingServiceModel>> getAllBookingService() {
    return _firestore
        .collection('bookingServices')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingServiceModel.fromDoc(doc, doc.id))
              .toList();
        });
  }

  // Get All Booking Services by serviceCategoryName
  Stream<List<BookingServiceModel>> getBookingServiceByCategory(
    String serviceCategoryName,
  ) {
    return _firestore
        .collection('bookingServices')
        .where('isActive', isEqualTo: true)
        .where('serviceCategory', isEqualTo: serviceCategoryName)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingServiceModel.fromDoc(doc, doc.id))
              .toList();
        });
  }

  /////////////////////////////// Bookings //////////////////////////////////
  // All Bookings
  Stream<List<BookingModel>> getAllBookings() {
    return _firestore.collection('bookings').snapshots().map((snap) {
      return snap.docs.map((doc) => BookingModel.fromMap(doc.data())).toList();
    });
  }

  // Pending Booking
  Stream<List<BookingModel>> getPendingBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('paymentStatus', isEqualTo: 'paid')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => BookingModel.fromMap(doc.data())).toList(),
        );
  }

  // Upcoming Booking for specific user
  Stream<List<BookingModel>> getUpcomingBookings(String userId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Start of today
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .where('paymentStatus', isEqualTo: 'paid')
        .where('bookingDate', isGreaterThanOrEqualTo: today) // Today or future
        .orderBy('bookingDate', descending: false)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => BookingModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Ongoing Booking for specific user
  Stream<List<BookingModel>> getOngoingBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'ongoing')
        .where('paymentStatus', isEqualTo: 'paid')
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => BookingModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Completed Bookings
  Stream<List<BookingModel>> getCompletedBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .where('paymentStatus', isEqualTo: 'paid')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => BookingModel.fromMap(doc.data())).toList(),
        );
  }

  // Rejected Bookings
  Stream<List<BookingModel>> getRejectedBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'rejected')
        .where('paymentStatus', isEqualTo: 'paid')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => BookingModel.fromMap(doc.data())).toList(),
        );
  }

  // Canceled Bookings
  Stream<List<BookingModel>> getCanceledBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'canceled')
        .where('paymentStatus', isEqualTo: 'paid')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => BookingModel.fromMap(doc.data())).toList(),
        );
  }

  // Get booking by ID (stream)
  Stream<BookingModel> getBookingById(String bookingId) {
    return _firestore.collection('bookings').doc(bookingId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return BookingModel.fromMap(data);
      } else {
        throw Exception("Booking not found");
      }
    });
  }

  /////////////////////////////// Bookings For Service Provider //////////////////////////////////

  // New Booking Requests for Service Provider
  Stream<List<BookingModel>> getNewBookingsRequest(String serviceProviderId) {
    return _firestore
        .collection('bookings')
        .where('serviceProviderId', isEqualTo: serviceProviderId)
        .where('paymentStatus', isEqualTo: 'paid')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => BookingModel.fromMap(doc.data())).toList(),
        );
  }

  // Upcoming Bookings for Service Provider
  Stream<List<BookingModel>> getUpcomingBookingsForProvider(
    String serviceProviderId,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Start of today
    return _firestore
        .collection('bookings')
        .where('serviceProviderId', isEqualTo: serviceProviderId)
        .where('status', isEqualTo: 'accepted')
        .where('paymentStatus', isEqualTo: 'paid')
        .where('bookingDate', isGreaterThanOrEqualTo: today) // Today or future
        .orderBy('bookingDate') // 🔥 required (ASC by default)
        .orderBy('createdAt') // ✅ ASC
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => BookingModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Ongoing Booking for Service Provider
  Stream<List<BookingModel>> getOngoingBookingsForProvider(
    String serviceProviderId,
  ) {
    return _firestore
        .collection('bookings')
        .where('serviceProviderId', isEqualTo: serviceProviderId)
        .where('status', isEqualTo: 'ongoing')
        .where('paymentStatus', isEqualTo: 'paid')
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => BookingModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Completed Booking for Service Provider
  Stream<List<BookingModel>> getCompletedBookingsForProvider(
    String serviceProviderId,
  ) {
    return _firestore
        .collection('bookings')
        .where('serviceProviderId', isEqualTo: serviceProviderId)
        .where('status', isEqualTo: 'completed')
        .where('paymentStatus', isEqualTo: 'paid')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => BookingModel.fromMap(doc.data())).toList(),
        );
  }

  // Rejected Booking for Service Provider
  Stream<List<BookingModel>> getRejectedBookingsForProvider(
    String serviceProviderId,
  ) {
    return _firestore
        .collection('bookings')
        .where('serviceProviderId', isEqualTo: serviceProviderId)
        .where('status', isEqualTo: 'rejected')
        .where('paymentStatus', isEqualTo: 'paid')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => BookingModel.fromMap(doc.data())).toList(),
        );
  }

  // Canceled Booking for Service Provider
  Stream<List<BookingModel>> getCanceledBookingsForProvider(
    String serviceProviderId,
  ) {
    return _firestore
        .collection('bookings')
        .where('serviceProviderId', isEqualTo: serviceProviderId)
        .where('status', isEqualTo: 'canceled')
        .where('paymentStatus', isEqualTo: 'paid')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => BookingModel.fromMap(doc.data())).toList(),
        );
  }

  /////////////////////////////// Reviews //////////////////////////////////
  // To get Reviews for specific service
  Stream<List<ReviewModel>> getReviewByServiceId(String serviceId) {
    return _firestore
        .collection('bookingServices')
        .doc(serviceId)
        .collection('reviews')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.data()))
              .toList();
        });
  }

  // To get Review and check the user has reviewed or not
  // Stream<ReviewModel?> getReviewByUser({
  //   required String userId,
  //   required String bookedServiceId,
  //   required String bookingId,
  // }) {
  //   // Use bookingId as document ID to fetch the review directly
  //   return _firestore
  //       .collection('bookingServices')
  //       .doc(bookedServiceId)
  //       .collection('reviews')
  //       .doc(bookingId)
  //       .snapshots()
  //       .map((doc) {
  //         // If document doesn't exist, user hasn't reviewed yet
  //         if (!doc.exists || doc.data() == null) {
  //           return null;
  //         }

  //         return ReviewModel.fromMap(doc.data()!);
  //       });
  // }

  // To get that user has rated or not if yes then get data
  Stream<ReviewModel?> checkReviewByUser({
    required String bookingId,
    required String userId,
  }) {
    print('🔍 Checking review for bookingId: $bookingId, userId: $userId');
    print('🔍 Path: bookings/$bookingId/reviews/$userId');

    return _firestore
        .collection('bookings')
        .doc(bookingId)
        .collection('reviews')
        .doc(userId)
        .snapshots()
        .handleError((error) {
          print('❌ ERROR in stream: $error');
          return null;
        })
        .map((doc) {
          print('📄 Document exists: ${doc.exists}');
          print('📄 Document data: ${doc.data()}');

          if (!doc.exists || doc.data() == null) {
            print('❌ No review found - returning null');
            return null;
          }

          print('✅ Review found - parsing data');
          try {
            return ReviewModel.fromMap(doc.data()!);
          } catch (e) {
            print('❌ ERROR parsing ReviewModel: $e');
            return null;
          }
        });
  }
}
