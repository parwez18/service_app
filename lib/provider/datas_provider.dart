import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// Get Services for Specific Service Provider by their id
final specificServicesProvider =
    StreamProvider.family<List<ServicesModel>, String>((
      ref,
      serviceProviderId,
    ) {
      final repo = ref.read(datasProviderRepository);
      return repo.getAllServicesById(serviceProviderId);
    });

// Get Services for Specific Service Provider by their id
final getServicesByServiceTypeProvider =
    StreamProvider.family<List<ServicesModel>, String>((ref, serviceType) {
      final repo = ref.read(datasProviderRepository);
      return repo.getServicesByServiceType(serviceType);
    });

// Fetch services by list of IDs
final favouriteServicesProvider =
    FutureProvider.family<List<ServicesModel>, List<String>>((ref, favIds) {
      final repo = ref.watch(datasProviderRepository);
      return repo.getFavouriteServices(favIds);
    });

// Nearby Service
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
