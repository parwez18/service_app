import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final ratingProvider = StateProvider<int>((ref) => 0);

final isLoadingProvider = StateProvider<bool>((ref) => false);
