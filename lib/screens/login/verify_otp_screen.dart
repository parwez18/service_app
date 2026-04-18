import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/login/user_name_type.dart';
import 'package:khujo_app/screens/m_screen.dart';
import 'package:khujo_app/screens/subscription/sp_subscription_mandate_screen.dart';
import 'package:khujo_app/screens/subscription/sp_subscription_screen.dart';
import 'package:khujo_app/service_provider/screens/provider_m_screen.dart';
import 'package:khujo_app/services/notifiction_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void dispose() {
    // Don't dispose _otpController manually — PinCodeTextField
    // holds an internal listener that outlives this State's dispose.
    // The controller will be GC'd with this State object.
    super.dispose();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _key,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 130.h),
                Image.asset(
                  'assets/login/verifyOTP.png',
                  height: 280.h,
                  width: 1.sw,
                ),
                Text(
                  "Enter valid 6 digit otp to verify",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20.h),
                PinCodeTextField(
                  controller: _otpController,
                  keyboardType: TextInputType.phone,
                  appContext: context,
                  length: 6,
                  cursorColor: Colors.black,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    fieldHeight: 50.h,
                    fieldWidth: 45.w,
                    borderRadius: BorderRadius.circular(10.r),
                    activeColor: AppConstants.primaryColor,
                    selectedColor: AppConstants.primaryColor,
                    inactiveColor: Colors.grey,
                  ),
                  validator: (value) {
                    if (value == null || value.length != 6) {
                      return "Enter valid 6 digit OTP";
                    }
                    return null;
                  },
                  enablePinAutofill: true,
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () async {
                    // Verify OTP
                    if (_key.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      final otp = _otpController.text.trim();
                      final verifyOTPProvider = ref.read(
                        authRepositoryProvider,
                      );
                      if (!mounted) return;
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        final result = await verifyOTPProvider.verifyOTP(otp);
                        final isNewUser = result['isNewUser'] as bool;
                        final userType = result['userType'] as String?;

                        // Save FCM token in the background (don't block navigation)
                        FirebaseMessaging.instance.getToken().then((token) {
                          if (token != null) {
                            NotificationService.saveFCMToken(token);
                          }
                        });

                        if (!mounted) return;

                        if (isNewUser || userType == null || userType.isEmpty) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserNameTypeScreen(),
                            ),
                          );
                        } else if (userType == "Customer") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MScreen()),
                          );
                        } else {
                          // Existing Service Provider — check subscription status
                          final uid =
                              FirebaseAuth.instance.currentUser?.uid ?? '';
                          final doc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .get();
                          final sub =
                              doc.data()?['subscription']
                                  as Map<String, dynamic>? ??
                              {};
                          final subStatus =
                              sub['status'] as String? ?? 'inactive';
                          final introPaid = sub['introPaid'] as bool? ?? false;
                          final phone =
                              doc.data()?['phoneNumber'] as String? ?? '';

                          if (!mounted) return;

                          if (subStatus == 'active') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProviderMScreen(),
                              ),
                            );
                          } else if (introPaid) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SPSubscriptionMandateScreen(phone: phone),
                              ),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SPSubscriptionScreen(),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (!mounted) return;
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    }
                  },
                  child: Center(
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Verify OTP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19.sp,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
