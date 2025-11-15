import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khujo_app/models/user_model.dart';
import 'package:khujo_app/repository/auth_repository.dart';
import 'package:khujo_app/repository/user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// To get userData by Id
final userDataProvider = StreamProvider.family<UserModel, String>((
  ref,
  userId,
) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUserDataById(userId);
});
