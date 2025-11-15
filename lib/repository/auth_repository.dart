import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // To Login with Phone Number
  String? _verificationId;

  // Send OTP
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException ex) {
        throw Exception("Verification failed: ${ex.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        codeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Verify OTP
  Future<User?> verifyOTP(String smsCode) async {
    try {
      if (_verificationId == null) {
        throw Exception("No verification ID found");
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDocRef = _firestore.collection("users").doc(user.uid);
        final userDoc = await userDocRef.get();
        if (!userDoc.exists) {
          // Create new user document with empty fields
          await userDocRef.set({
            "uid": user.uid,
            "name": "",
            "phoneNumber": user.phoneNumber,
            "userType": "", // Customer or Service Provider
            "userRoles": [], // Array of roles: Plumber, Doctor, Electrician
            "userImage": "",
            "userAddress": "",
            "isVerified": false,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
          });
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception("OTP verification failed: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
