import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khujo_app/services/cloudinary_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khujo_app/models/services_model.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';

class EditServiceScreen extends ConsumerStatefulWidget {
  final ServicesModel serviceData;
  const EditServiceScreen({super.key, required this.serviceData});

  @override
  ConsumerState<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends ConsumerState<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _originalPriceController = TextEditingController();
  TextEditingController _discountPriceController = TextEditingController();
  bool isLoading = false;

  String? _existingImageUrl;

  File? _selectedImage;

  late String selectedServiceType;

  // IMAGE PICKER
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path); // store new image
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) {
    return CloudinaryService.uploadImage(imageFile, folder: 'services');
  }

  @override
  void initState() {
    _titleController = TextEditingController(
      text: widget.serviceData.serviceTitle,
    );
    _descController = TextEditingController(
      text: widget.serviceData.description,
    );
    _originalPriceController = TextEditingController(
      text: widget.serviceData.originalPrice.toString(),
    );
    _discountPriceController = TextEditingController(
      text: widget.serviceData.discountPrice.toString(),
    );

    // Image
    _existingImageUrl = widget.serviceData.serviceImage;

    selectedServiceType = widget.serviceData.serviceType;
    super.initState();
  }

  // Save Data of Updated Service
  Future<void> updateService(
    String selectedServiceType,
    String providerAddress,
    double providerLat,
    double providerLng,
  ) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String finalImageUrl = _existingImageUrl!; // default old image
      try {
        // If user selected a new image upload it
        if (_selectedImage != null) {
          final uploadedUrl = await _uploadImage(_selectedImage!);
          if (uploadedUrl != null) {
            finalImageUrl = uploadedUrl;
          }
        }
        await FirebaseFirestore.instance
            .collection('services')
            .doc(widget.serviceData.id)
            .update({
              "serviceTitle": _titleController.text.trim(),
              "description": _descController.text.trim(),
              "serviceType": selectedServiceType,
              "originalPrice":
                  double.tryParse(_originalPriceController.text.trim()) ?? 0.0,
              "discountPrice":
                  double.tryParse(_discountPriceController.text.trim()) ?? 0.0,
              "serviceImage": finalImageUrl,
              "providerAddress": providerAddress,
              "lat": providerLat,
              "lng": providerLng,
            });
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updeted successfully!')),
        );
        // Optional: go back
        Navigator.pop(context);
      } catch (e) {
        print("ERROR updating service: $e");
      } finally {
        setState(() => isLoading = false); // ⭐ FIXED
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _originalPriceController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final currentUserAsync = ref.watch(userDataProvider(currentUserId));
    final categoriesAsync = ref.watch(allCategoriesListProvider);
    // Booking Service Categories
    final bookingServiceCategoriesAsync = ref.watch(
      allBookingServiceCategoriesListProvider,
    );
    //Travel Booking Categories
    final travelBookingCategoriesAsync = ref.watch(
      allTravelBookingCategoriesListProvider,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar("Edit Service"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Image
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.deepOrange),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : Image.network(
                              _existingImageUrl!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                // Service Tile
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Enter Service Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter service title";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.h),

                // Service Type
                widget.serviceData.parent == "Booking Service"
                    ? bookingServiceCategoriesAsync.when(
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
                            hint: const Text("Select Service Type"),
                            items: categoryTitles
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ),
                                )
                                .toList(),
                            value: selectedServiceType,
                            onChanged: (value) =>
                                setState(() => selectedServiceType = value!),
                            validator: (value) => value == null
                                ? "Please select service type"
                                : null,
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text("Error: $err"),
                      )
                    : travelBookingCategoriesAsync.when(
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
                            hint: const Text("Select Service Type"),
                            items: categoryTitles
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ),
                                )
                                .toList(),
                            value: selectedServiceType,
                            onChanged: (value) =>
                                setState(() => selectedServiceType = value!),
                            validator: (value) => value == null
                                ? "Please select service type"
                                : null,
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text("Error: $err"),
                      ),
                SizedBox(height: 15.h),

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
                      return "Please enter service title";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.h),
                // Original Price
                TextFormField(
                  controller: _originalPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Original Price",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter price";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Discount Price
                TextFormField(
                  controller: _discountPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Discount Price",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter price";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.h),
                // Update Service Button
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
                        onPressed: () async {
                          // To update Service
                          // await updateService(selectedServiceType);
                          await updateService(
                            selectedServiceType,
                            currentUserAsync.value!.userAddress,
                            currentUserAsync.value!.lat,
                            currentUserAsync.value!.lng,
                          );
                        },
                        child: Center(
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Update Service",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
