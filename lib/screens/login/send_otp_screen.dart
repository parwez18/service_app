import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/login/verify_otp_screen.dart';

class SendOtpScreen extends ConsumerStatefulWidget {
  const SendOtpScreen({super.key});

  @override
  ConsumerState<SendOtpScreen> createState() => _SendOtpScreenState();
}

class _SendOtpScreenState extends ConsumerState<SendOtpScreen> {
  final TextEditingController _numController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _numController.dispose();
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
                  'assets/login/sendOTP.png',
                  height: 280.h,
                  width: 1.sw,
                ),
                Text(
                  "Enter your phone number to login",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: _numController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 12, right: 6),
                      child: Text(
                        "+91",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    hintText: "Enter phone number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter phone number";
                    } else if (value.length != 10) {
                      return "Enter valid 10 digit number";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 25.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () async {
                    // Send OTP
                    if (_key.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      final phone = "+91${_numController.text.trim()}";
                      final sendOTPProvider = ref.read(authRepositoryProvider);
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await sendOTPProvider.sendOTP(
                          phoneNumber: phone,
                          codeSent: (verificationId, resendToken) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text("OTP Sent")));
                            setState(() {
                              isLoading = false;
                            });
                            // Navigate to Verify screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VerifyOtpScreen(),
                              ),
                            );
                          },
                        );
                      } catch (e) {
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
                            "Send OTP",
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
