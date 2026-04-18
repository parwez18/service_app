import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khujo_app/models/service_model.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';

class AddBookingServiceScreen extends ConsumerStatefulWidget {
  const AddBookingServiceScreen({super.key});

  @override
  ConsumerState<AddBookingServiceScreen> createState() =>
      _AddBookingServiceScreenState();
}

class _AddBookingServiceScreenState
    extends ConsumerState<AddBookingServiceScreen> {
  final TextEditingController _shopName = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  TextEditingController openController = TextEditingController();
  TextEditingController closeController = TextEditingController();
  TextEditingController startDayController = TextEditingController();
  TextEditingController endDayController = TextEditingController();

  final _key = GlobalKey<FormState>();
  String? selectedSubServiceType;
  List<ServiceModel> services = [
    ServiceModel(), // one row by default
  ];
  // List of days
  final List<String> daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];
  bool isLoading = false;
  File? selectedImage;

  Future<void> pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          selectedImage = File(picked.path);
        });
      }
    } catch (e) {}
  }

  // Upload Image to firebase
  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      // New unique file name
      final filename =
          'bookingServices/${DateTime.now().millisecondsSinceEpoch}.jpg';
      // Reference to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(filename);
      // Upload the image
      await ref.putFile(imageFile);
      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Save Service Data
  Future<void> saveServiceData({
    required double providerLat,
    required double providerLng,
    required String ownerName,
    required String phone,
    required String userAddress,
    required String serviceProviderId,
  }) async {
    try {
      // For checking Subscription of Service Provider
      // Check subscription before saving
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      final subStatus =
          userDoc.data()?['subscription']?['status'] as String? ?? 'inactive';

      if (subStatus != 'active') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your subscription has expired. Please renew to add services.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!_key.currentState!.validate()) return;
      if (selectedImage == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select an image')));
        return;
      }
      setState(() => isLoading = true);
      final imageUrl = await _uploadImageToFirebase(selectedImage!);
      // 🔥 Create document reference first (this gives ID)
      final docRef = FirebaseFirestore.instance
          .collection("bookingServices")
          .doc();
      await docRef.set({
        'id': docRef.id,
        'name': _shopName.text.trim(),
        'serviceProviderId': serviceProviderId,
        'ownerName': ownerName,
        'ownerNumber': phone,
        'imageUrl': imageUrl,
        'description': _descController.text.trim(),
        'services': services.map((service) => service.toMap()).toList(),
        'openingTime': openController.text.trim(),
        'closeingTime': closeController.text.trim(),
        'startDay': startDayController.text.trim(),
        'endDay': endDayController.text.trim(),
        "parent": "Booking Service",
        'serviceCategory': selectedSubServiceType,
        'isOpen': true,
        "isActive": false,
        'providerAddress': userAddress,
        "lat": providerLat,
        "lng": providerLng,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service added successfully!')),
      );

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    _shopName.dispose();
    _descController.dispose();
    openController.dispose();
    closeController.dispose();
    startDayController.dispose();
    endDayController.dispose();
    for (var s in services) {
      s.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final currentUserAsync = ref.watch(userDataProvider(currentUserId));
    final bookingServiceCategoriesAsync = ref.watch(
      allBookingServiceCategoriesListProvider,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar("Add Service"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 15.h,
              children: [
                SizedBox(height: 10.h),
                // Image Section
                // Image Picker (For Service Image)
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 160.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.deepOrange),
                      color: Colors.grey.shade100,
                    ),
                    child: selectedImage == null
                        ? Center(
                            child: Text(
                              "Tap to select image",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                  ),
                ),

                // Medical/Doctor/Salon Name
                TextFormField(
                  controller: _shopName,
                  decoration: InputDecoration(
                    labelText: " Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter shop name";
                    }
                    return null;
                  },
                ),
                bookingServiceCategoriesAsync.when(
                  data: (categoriesList) {
                    final categoryTitles = categoriesList
                        .map((cat) => cat.title)
                        .toList();

                    return DropdownButtonFormField2<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: Colors.white, // dropdown menu bg
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),

                      hint: const Text("Select Service Categorie"),
                      items: categoryTitles
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      value: selectedSubServiceType,
                      onChanged: (value) =>
                          setState(() => selectedSubServiceType = value),
                      validator: (value) => value == null
                          ? "Please select service Categorie"
                          : null,
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text("Error: $err"),
                ),
                // Owner Name will Come from user collection
                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please describe work";
                    }
                    return null;
                  },
                ),

                // Services And Price
                // ------------------------
                // SERVICES LIST
                // ------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Services",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: Colors.deepOrange,
                        size: 28.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          services.add(ServiceModel());
                        });
                      },
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 7.h),
                      child: ServiceRow(
                        model: services[index],
                        onRemove: () {
                          if (services.length > 1) {
                            setState(() => services.removeAt(index));
                          }
                        },
                      ),
                    );
                  },
                ),

                // Working Hours
                Row(
                  spacing: 7,
                  children: [
                    // Opening Time
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: openController,
                        decoration: InputDecoration(
                          labelText: "Opening Time",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            openController.text = time.format(context);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select opening time";
                          }
                          return null;
                        },
                      ),
                    ),
                    // Closing Time
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: closeController,
                        decoration: InputDecoration(
                          labelText: "Closing Time",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            closeController.text = time.format(context);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select closing time";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                // Working Days
                Row(
                  spacing: 7,
                  children: [
                    // Start day
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          labelText: "Start Day",

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        items: daysOfWeek
                            .map(
                              (day) => DropdownMenuItem(
                                value: day,
                                child: Text(day),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          startDayController.text = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select Start Day";
                          }
                          return null;
                        },
                      ),
                    ),

                    // End day
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          labelText: "End Day",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        items: daysOfWeek
                            .map(
                              (day) => DropdownMenuItem(
                                value: day,
                                child: Text(day),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          endDayController.text = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select End Day";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                // Add Service Button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            6,
                            86,
                            236,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: currentUserAsync.hasValue && !isLoading
                            ? () async {
                                await saveServiceData(
                                  providerLat: currentUserAsync.value!.lat,
                                  providerLng: currentUserAsync.value!.lng,
                                  ownerName: currentUserAsync.value!.name,
                                  phone: currentUserAsync.value!.phoneNumber,
                                  userAddress:
                                      currentUserAsync.value!.userAddress,
                                  serviceProviderId:
                                      currentUserAsync.value!.uid,
                                );
                              }
                            : null,
                        child: Center(
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Add Service",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ServiceRow extends StatelessWidget {
  final ServiceModel model;
  final VoidCallback onRemove;

  const ServiceRow({super.key, required this.model, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: model.name,
            decoration: InputDecoration(
              labelText: "Service Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? "Enter service name" : null,
          ),
        ),

        Expanded(
          flex: 1,
          child: TextFormField(
            controller: model.price,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Price",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? "Enter price" : null,
          ),
        ),
        Expanded(
          flex: 1,
          child: TextFormField(
            controller: model.duration,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Time",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? "Enter time" : null,
          ),
        ),

        IconButton(
          icon: Icon(Icons.remove_circle, color: Colors.red),
          onPressed: onRemove,
        ),
      ],
    );
  }
}
