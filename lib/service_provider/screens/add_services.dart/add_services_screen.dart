import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';

class AddServicesScreen extends ConsumerStatefulWidget {
  const AddServicesScreen({super.key});

  @override
  ConsumerState<AddServicesScreen> createState() => _AddServicesScreenState();
}

class _AddServicesScreenState extends ConsumerState<AddServicesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _originalPriceController =
      TextEditingController();
  final TextEditingController _discountPriceController =
      TextEditingController();

  String? selectedServiceType;
  String? serviceImageUrl; // you can later replace with image picker

  bool isLoading = false;

  File? _selectedImage;

  // Pick Image
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // Upload Image to firebase
  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      // New unique file name
      final filename = 'services/${DateTime.now().millisecondsSinceEpoch}.jpg';
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

  // Add Service
  Future<void> addService(
    String providerId,
    String providerName,
    String providerAddress,
    String providerNumber,
  ) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select an image')));
        return;
      }

      setState(() => isLoading = true);
      final imageUrl = await _uploadImageToFirebase(_selectedImage!);
      final docRef = FirebaseFirestore.instance.collection('services').doc();
      await docRef.set({
        "id": docRef.id,
        "providerId": providerId,
        "providerName": providerName,
        "providerNumber": providerNumber,
        "providerAddress": providerAddress,
        "serviceTitle": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "serviceType": selectedServiceType,
        "originalPrice":
            double.tryParse(_originalPriceController.text.trim()) ?? 0.0,
        "discountPrice":
            double.tryParse(_discountPriceController.text.trim()) ?? 0.0,
        "serviceImage": imageUrl,
        "isActive": true,
        "createdAt": Timestamp.now(),
      });
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service added successfully!')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _selectedImage = null;
        selectedServiceType = null;
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final currentUserAsync = ref.watch(userDataProvider(currentUserId));
    // Get all categories Data List
    final categoriesAsync = ref.watch(allCategoriesListProvider);
    return Scaffold(
      appBar: customAppBar("Add Services"),

      body: SingleChildScrollView(
        child: currentUserAsync.when(
          data: (currentUserData) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Image Picker (For Service Image)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 160.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.deepOrange),
                          color: Colors.grey.shade100,
                        ),
                        child: _selectedImage == null
                            ? Center(
                                child: Text(
                                  "Tap to select image",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Service Title
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
                    const SizedBox(height: 15),
                    // Service Type
                    // 🧰 Service Type (Dynamic from Firestore)
                    categoriesAsync.when(
                      data: (categoriesList) {
                        final categoryTitles = categoriesList
                            .map((cat) => cat.title)
                            .toList();

                        return DropdownButtonFormField2<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r),
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
                              setState(() => selectedServiceType = value),
                          validator: (value) => value == null
                              ? "Please select service type"
                              : null,
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text("Error: $err"),
                    ),

                    const SizedBox(height: 15),

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
                    const SizedBox(height: 15),
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
                    SizedBox(height: 20.h),

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
                            onPressed: () async {
                              await addService(
                                currentUserData.uid,
                                currentUserData.name,
                                currentUserData.userAddress,
                                currentUserData.phoneNumber,
                              );
                            },
                            child: Center(
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "Add Service",
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
            );
          },
          error: (err, _) => Center(child: Text(err.toString())),
          loading: () => Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
