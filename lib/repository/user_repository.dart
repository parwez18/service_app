import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khujo_app/models/user_model.dart';

class UserRepository {
  final _firestore = FirebaseFirestore.instance;

  // ✅ Get user data by ID (stream)
  Stream<UserModel> getUserDataById(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return UserModel.fromDoc(data, snapshot.id);
      } else {
        throw Exception("User not found");
      }
    });
  }
}
