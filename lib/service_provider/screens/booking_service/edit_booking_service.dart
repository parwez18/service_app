import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khujo_app/models/booking_service_model.dart';
import 'package:khujo_app/models/service_model.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/provider/user_provider.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';

class EditBookingService extends ConsumerStatefulWidget {
  final BookingServiceModel serviceData;
  const EditBookingService({super.key, required this.serviceData});

  @override
  ConsumerState<EditBookingService> createState() => _EditBookingServiceState();
}

class _EditBookingServiceState extends ConsumerState<EditBookingService> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController openController = TextEditingController();
  TextEditingController closeController = TextEditingController();
  TextEditingController startDayController = TextEditingController();
  TextEditingController endDayController = TextEditingController();

  String? _existingImageUrl;

  File? _selectedImage;

  late String selectedServiceType;
  List<ServiceModel> services = [];
  bool isLoading = false;

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

  // IMAGE PICKER
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path); // store new image
      });
    }
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.serviceData.name);
    _descController = TextEditingController(
      text: widget.serviceData.description,
    );
    openController = TextEditingController(
      text: widget.serviceData.openingTime,
    );
    closeController = TextEditingController(
      text: widget.serviceData.closingTime,
    );
    startDayController = TextEditingController(
      text: widget.serviceData.startDay,
    );
    endDayController = TextEditingController(text: widget.serviceData.endDay);

    // Image
    _existingImageUrl = widget.serviceData.imageUrl;

    selectedServiceType = widget.serviceData.serviceCategory;
    // Load existing services
    for (var serviceItem in widget.serviceData.services) {
      final serviceModel = ServiceModel();
      serviceModel.name.text = serviceItem.name;
      serviceModel.price.text = serviceItem.price.toString();
      serviceModel.duration.text = serviceItem.duration.replaceAll(
        ' minutes',
        '',
      );
      services.add(serviceModel);
    }

    // If no services exist, add one empty service
    if (services.isEmpty) {
      services.add(ServiceModel());
    }
  }

  // Update Service Data
  Future<void> updateServiceData() async {
    try {
      if (!_formKey.currentState!.validate()) return;

      setState(() => isLoading = true);

      String imageUrl = _existingImageUrl!;

      // If new image is selected, upload it
      if (_selectedImage != null) {
        final newImageUrl = await _uploadImageToFirebase(_selectedImage!);
        if (newImageUrl != null) {
          imageUrl = newImageUrl;
        }
      }

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection("bookingServices")
          .doc(widget.serviceData.id)
          .update({
            'name': _nameController.text.trim(),
            'description': _descController.text.trim(),
            'serviceCategory': selectedServiceType,
            'imageUrl': imageUrl,
            'openingTime': openController.text.trim(),
            'closeingTime': closeController.text.trim(),
            'startDay': startDayController.text.trim(),
            'endDay': endDayController.text.trim(),
            'services': services.map((service) => service.toMap()).toList(),
          });

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service updated successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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

    // Booking Service Categories
    final bookingServiceCategoriesAsync = ref.watch(
      allBookingServiceCategoriesListProvider,
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

                SizedBox(height: 25.h),
                // Service Tile
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Enter shop/clinic name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter shop/clinic name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.h),
                // Service Type
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
                      validator: (value) =>
                          value == null ? "Please select service type" : null,
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
                  maxLines: 6,
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

                // Services List
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
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 15.h),
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
                    SizedBox(width: 7.w),
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

                SizedBox(height: 20.h),

                // Working Days
                Row(
                  children: [
                    // Start day
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Start Day",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        value: startDayController.text.isNotEmpty
                            ? startDayController.text
                            : null,
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
                    SizedBox(width: 7.w),
                    // End day
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "End Day",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        value: endDayController.text.isNotEmpty
                            ? endDayController.text
                            : null,
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

                SizedBox(height: 25.h),
                // Update Button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
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
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                        ),
                        onPressed: !isLoading ? updateServiceData : null,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Update Service",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
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
        SizedBox(width: 5.w),
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
        SizedBox(width: 5.w),
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
          icon: const Icon(Icons.remove_circle, color: Colors.red),
          onPressed: onRemove,
        ),
      ],
    );
  }
}
