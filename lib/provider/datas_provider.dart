import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khujo_app/models/booking_model.dart';
import 'package:khujo_app/models/booking_service_model.dart';
import 'package:khujo_app/models/categories_model.dart';
import 'package:khujo_app/models/parent_categories_model.dart';

import 'package:khujo_app/models/services_model.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/repository/datas_repository.dart';
import 'package:khujo_app/repository/distance_helper.dart';

final datasProviderRepository = Provider<DatasRepository>((ref) {
  return DatasRepository();
});

// // To get All Categories
// final allCategoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
//   final repo = ref.read(datasProviderRepository);
//   return repo.getAllCategories();
// });

// // To get Root Level Categories
// final rootCategoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
//   final repo = ref.read(datasProviderRepository);
//   return repo.getRootCategories();
// });

// // To get Root Level Categories
// final subCategoriesProvider =
//     StreamProvider.family<List<CategoryModel>, String>((ref, String parentId) {
//       final repo = ref.read(datasProviderRepository);
//       return repo.getSubcategories(parentId);
//     });

// // To Get All Provider ROles
// final allProviderRolesProvider = StreamProvider<List<ProviderRoleModel>>((ref) {
//   final repo = ref.read(datasProviderRepository);
//   return repo.getAllProviderRoles();
// });

// To All Sub-Categories
final allCategoriesListProvider = StreamProvider<List<CategoriesModel>>((ref) {
  final repo = ref.read(datasProviderRepository);
  return repo.getAllCategoriesList();
});

// To All Parent-Categories
final allParentCategoriesListProvider =
    StreamProvider<List<ParentCategoriesModel>>((ref) {
      final repo = ref.read(datasProviderRepository);
      return repo.getAllParentCategoriesList();
    });

// Get All Sub-Categories whose parent is Booking Service
final allBookingServiceCategoriesListProvider =
    StreamProvider<List<CategoriesModel>>((ref) {
      final repo = ref.read(datasProviderRepository);
      return repo.getAllBookingServiceCategories();
    });

// Get All Sub-Categories whose parent is Travel Booking
final allTravelBookingCategoriesListProvider =
    StreamProvider<List<CategoriesModel>>((ref) {
      final repo = ref.read(datasProviderRepository);
      return repo.getAllTravelBookingCategories();
    });

// To All Services
final allServicesProvider = StreamProvider<List<ServicesModel>>((ref) {
  final repo = ref.read(datasProviderRepository);
  return repo.getAllServices();
});

// To Get All Booking Services
final allBookingServicesProvider = StreamProvider<List<BookingServiceModel>>((
  ref,
) {
  final repo = ref.read(datasProviderRepository);
  return repo.getAllBookingService();
});

// Get Travel and Market Services for Specific Service Provider by their id
final specificServicesProvider =
    StreamProvider.family<List<ServicesModel>, String>((
      ref,
      serviceProviderId,
    ) {
      final repo = ref.read(datasProviderRepository);
      return repo.getAllServicesById(serviceProviderId);
    });

// Get Booking Service Services for Specific Service Provider by their id
final specificBookingServicesProvider =
    StreamProvider.family<List<BookingServiceModel>, String>((
      ref,
      serviceProviderId,
    ) {
      final repo = ref.read(datasProviderRepository);
      return repo.getAllBookingServicesById(serviceProviderId);
    });

// Get Services for Specific Service Provider by their id
final getServicesByServiceTypeProvider =
    StreamProvider.family<List<ServicesModel>, String>((ref, serviceType) {
      final repo = ref.read(datasProviderRepository);
      return repo.getServicesByServiceType(serviceType);
    });

// Fetch Travel and Market Favourite services by list of IDs
final favouriteServicesProvider =
    FutureProvider.family<List<ServicesModel>, List<String>>((ref, favIds) {
      final repo = ref.watch(datasProviderRepository);
      return repo.getFavouriteServices(favIds);
    });

// Fetch Booking Favourite services by list of IDs
final favouriteBookingServicesProvider =
    FutureProvider.family<List<BookingServiceModel>, List<String>>((
      ref,
      favIds,
    ) {
      final repo = ref.watch(datasProviderRepository);
      return repo.getBookingFavouriteServices(favIds);
    });

// Nearby Service for Travel & Market
final currentUserId = FirebaseAuth.instance.currentUser!.uid;
final nearbyServicesProvider = Provider<List<ServicesModel>>((ref) {
  final user = ref.watch(userDataProvider(currentUserId)).value;
  final services = ref.watch(allServicesProvider).value ?? [];
  if (user == null) return [];

  const double maxDistance = 10; // km (change as you want)
  List<ServicesModel> nearby = services.where((service) {
    double dist = calculateDistance(
      user.lat,
      user.lng,
      service.lat,
      service.lng,
    );

    return dist <= maxDistance;
  }).toList();

  // Sort by nearest first
  nearby.sort((a, b) {
    double distA = calculateDistance(user.lat, user.lng, a.lat, a.lng);
    double distB = calculateDistance(user.lat, user.lng, b.lat, b.lng);
    return distA.compareTo(distB);
  });

  return nearby;
});

// Nearby Service for Booking Service
final nearbyBookingServicesProvider = Provider<List<BookingServiceModel>>((
  ref,
) {
  final userAsync = ref.watch(
    userDataProvider(FirebaseAuth.instance.currentUser!.uid),
  );
  final bookingServicesAsync = ref.watch(allBookingServicesProvider);

  final user = userAsync.value;
  final services = bookingServicesAsync.value;

  if (user == null || services == null) return [];

  const double maxDistance = 10; // km

  final nearby = services.where((service) {
    final distance = calculateDistance(
      user.lat,
      user.lng,
      service.lat,
      service.lng,
    );
    return distance <= maxDistance;
  }).toList();

  // Nearest first
  nearby.sort((a, b) {
    final d1 = calculateDistance(user.lat, user.lng, a.lat, a.lng);
    final d2 = calculateDistance(user.lat, user.lng, b.lat, b.lng);
    return d1.compareTo(d2);
  });

  return nearby;
});

// Get All Booking Services by serviceCategoryName
final getBookingServiceProvider =
    StreamProvider.family<List<BookingServiceModel>, String>((
      ref,
      serviceCategoryName,
    ) {
      final repo = ref.read(datasProviderRepository);
      return repo.getBookingServiceByCategory(serviceCategoryName);
    });

//////////////////////// For User //////////////////
// To get All Pending Bookings for specific user
final pendingBookingsProvider =
    StreamProvider.family<List<BookingModel>, String>((ref, userId) {
      final repo = ref.read(datasProviderRepository);
      return repo.getPendingBookings(userId);
    });

// To get All Upcoming Bookings for specific user
final upcomingBookingsProvider =
    StreamProvider.family<List<BookingModel>, String>((ref, userId) {
      final repo = ref.read(datasProviderRepository);
      return repo.getUpcomingBookings(userId);
    });

// To get All Upcoming Bookings for specific user
final ongoingBookingsProvider =
    StreamProvider.family<List<BookingModel>, String>((ref, userId) {
      final repo = ref.read(datasProviderRepository);
      return repo.getOngoingBookings(userId);
    });

// To get All Completed Bookings for specific user
final completedBookingsProvider =
    StreamProvider.family<List<BookingModel>, String>((ref, userId) {
      final repo = ref.read(datasProviderRepository);
      return repo.getCompletedBookings(userId);
    });

// To get All Rejected Bookings for specific user
final rejectedBookingsProvider =
    StreamProvider.family<List<BookingModel>, String>((ref, userId) {
      final repo = ref.read(datasProviderRepository);
      return repo.getRejectedBookings(userId);
    });

// Provider to get a single booking by ID
final bookingByIdProvider = StreamProvider.family<BookingModel, String>((
  ref,
  bookingId,
) {
  final repo = ref.watch(datasProviderRepository);
  return repo.getBookingById(bookingId);
});

/////////////////// For Service Provider /////////////////////////////
// For New Booking Request
final newBookingRequestsProvider =
    StreamProvider.family<List<BookingModel>, String>((ref, serviceProviderId) {
      final repo = ref.read(datasProviderRepository);
      return repo.getNewBookingsRequest(serviceProviderId);
    });

// For Upcoming Bookings for Service Provider
final upcomingBookingforProviderProvider =
    StreamProvider.family<List<BookingModel>, String>((ref, serviceProviderId) {
      final repo = ref.read(datasProviderRepository);
      return repo.getUpcomingBookingsForProvider(serviceProviderId);
    });

// For Ongoing Bookings for Service Provider
final ongoingBookingforProviderProvider =
    StreamProvider.family<List<BookingModel>, String>((ref, serviceProviderId) {
      final repo = ref.read(datasProviderRepository);
      return repo.getOngoingBookingsForProvider(serviceProviderId);
    });

// For Completed Bookings for Service Provider
final completedBookingforProviderProvider =
    StreamProvider.family<List<BookingModel>, String>((ref, serviceProviderId) {
      final repo = ref.read(datasProviderRepository);
      return repo.getCompletedBookingsForProvider(serviceProviderId);
    });

// For Rejected Bookings for Service Provider
final rejectedBookingforProviderProvider =
    StreamProvider.family<List<BookingModel>, String>((ref, serviceProviderId) {
      final repo = ref.read(datasProviderRepository);
      return repo.getRejectedBookingsForProvider(serviceProviderId);
    });
