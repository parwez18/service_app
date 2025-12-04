import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/models/user_model.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/profile/address_search_screen.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  double? selectedLat;
  double? selectedLng;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.name);
    _addressController = TextEditingController(
      text: widget.userData.userAddress,
    );
    selectedLat = widget.userData.lat;
    selectedLng = widget.userData.lng;
  }

  /// -------------------------
  /// place result callback
  /// -------------------------
  void onPlaceSelected(String address, double lat, double lng) {
    setState(() {
      _addressController.text = address;
      selectedLat = lat;
      selectedLng = lng;
    });

    print("Selected Address: $address");
    print("Selected Lat: $lat");
    print("Selected Lng: $lng");
  }

  // Save Edit Changes
  Future<void> saveChanges(BuildContext context) async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter name")));
      return;
    }
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select address")));
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userData.uid)
          .update({
            "name": _nameController.text.trim(),
            "userAddress": _addressController.text.trim(),
            "lat": selectedLat,
            "lng": selectedLng,
            "updatedAt": Timestamp.now(),
          });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile updated successfully")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Edit Profile"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Image Section
            CircleAvatar(
              radius: 80,
              child: Image.asset('assets/images/user2.png'),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              onTap: () {
                // Navigate to open Search Location Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddressSearchScreen(onPlaceSelected: onPlaceSelected),
                  ),
                );
              },
              readOnly: true,
              maxLines: 2,
              controller: _addressController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "Address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Change Location
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              onPressed: () async {
                // Save data changes logic
                await saveChanges(context);
              },
              child: Center(
                child: Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
