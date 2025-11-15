// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:khujo_app/appconstants/appconstants.dart';
// import 'package:khujo_app/provider/datas_provider.dart';
// import 'package:khujo_app/screens/m_screen.dart';

// class ServiceProviderCategoriesScreen extends ConsumerStatefulWidget {
//   const ServiceProviderCategoriesScreen({super.key});

//   @override
//   ConsumerState<ServiceProviderCategoriesScreen> createState() =>
//       _ServiceProviderCategoriesScreenState();
// }

// class _ServiceProviderCategoriesScreenState
//     extends ConsumerState<ServiceProviderCategoriesScreen> {
//   final _firestore = FirebaseFirestore.instance;
//   final _currentUserUid = FirebaseAuth.instance.currentUser!.uid;

//   List<String> selectedRoles = [];
//   bool isLoading = false;

//   // Save selected roles to Firestore
//   Future<void> saveProviderRoles() async {
//     if (selectedRoles.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select at least one role")),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       await _firestore.collection('users').doc(_currentUserUid).update({
//         'userRoles': selectedRoles, // store as List<String>
//       });

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const MScreen()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error saving roles: $e")));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final rolesStream = ref.watch(allProviderRolesProvider);
// //
//     return Scaffold(
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
//         child: rolesStream.when(
//           data: (roles) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 80.h),
//                 Center(
//                   child: Text(
//                     "Select services you will provide",
//                     style: TextStyle(
//                       fontSize: 22.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 // ✅ List of Roles with Checkboxes
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: roles.length,
//                     itemBuilder: (context, index) {
//                       final role = roles[index];
//                       final isSelected = selectedRoles.contains(role.title);

//                       return CheckboxListTile(
//                         selected: true,
//                         checkColor: Colors.white,
//                         title: Text(
//                           role.title,
//                           style: TextStyle(
//                             fontSize: 20.sp,
//                             color: Colors.black,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         value: isSelected,
//                         onChanged: (value) {
//                           setState(() {
//                             if (value == true) {
//                               selectedRoles.add(role.title);
//                             } else {
//                               selectedRoles.remove(role.title);
//                             }
//                           });
//                         },
//                       );
//                     },
//                   ),
//                 ),

//                 SizedBox(height: 10.h),
//                 ElevatedButton(
//                   onPressed: saveProviderRoles,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppConstants.primaryColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                   ),
//                   child: Center(
//                     child: isLoading
//                         ? CircularProgressIndicator(color: Colors.white)
//                         : Text(
//                             "Submit",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18.sp,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             );
//           },
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (err, _) => Center(child: Text("Error: $err")),
//         ),
//       ),
//     );
//   }
// }
