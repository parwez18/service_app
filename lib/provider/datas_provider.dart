import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khujo_app/models/categories_model.dart';

import 'package:khujo_app/models/services_model.dart';
import 'package:khujo_app/repository/datas_repository.dart';

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

// To All Categories
final allCategoriesListProvider = StreamProvider<List<CategoriesModel>>((ref) {
  final repo = ref.read(datasProviderRepository);
  return repo.getAllCategoriesList();
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
