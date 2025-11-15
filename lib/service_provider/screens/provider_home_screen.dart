import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/provider/datas_provider.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/service_provider/screens/add_services.dart/add_services_screen.dart';
import 'package:khujo_app/service_provider/screens/add_services.dart/edit_service_screen.dart';

class ProviderHomeScreen extends ConsumerStatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  ConsumerState<ProviderHomeScreen> createState() => _AddServicesScreenState();
}

class _AddServicesScreenState extends ConsumerState<ProviderHomeScreen> {
  String _calculateDiscount(num original, num discount) {
    if (original <= 0) return "0";
    final percentage = ((original - discount) / original * 100).round();
    return "$percentage";
  }

  String _formatDate(dynamic date) {
    // Handle both DateTime and Timestamp
    if (date == null) return "N/A";
    DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else {
      // Assume it's a Timestamp from Firestore
      dateTime = date.toDate();
    }
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  final _firestore = FirebaseFirestore.instance;
  // To Delete Service
  Future<void> deleteService(String serviceId) async {
    try {
      await _firestore.collection("services").doc(serviceId).delete();
    } catch (e) {
      print("Error while deleting service $e");
    }
  }

  // To Toggle isActive
  Future<void> toggleIsActive(bool isActive, String serviceId) async {
    try {
      if (isActive) {
        await _firestore.collection('services').doc(serviceId).update({
          'isActive': false,
        });
      } else {
        await _firestore.collection('services').doc(serviceId).update({
          'isActive': true,
        });
      }
    } catch (e) {
      print("Error while toggling service isActive $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final servicesAsync = ref.watch(specificServicesProvider(currentUserId));
    return Scaffold(
      appBar: customAppBar("Home"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddServicesScreen()),
          );
        },
        child: Icon(Iconsax.add, color: Colors.white),
      ),
      body: servicesAsync.when(
        data: (servicesData) {
          if (servicesData.isEmpty) {
            return Center(child: Text("Please add services"));
          }
          return ListView.builder(
            itemCount: servicesData.length,
            itemBuilder: (context, index) {
              final service = servicesData[index];
              final discountPercent = _calculateDiscount(
                service.originalPrice,
                service.discountPrice,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            // Header: Provider Info + Date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Iconsax.call,
                                        size: 16,
                                        color: AppConstants.primaryColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          service.providerNumber.isNotEmpty
                                              ? service.providerNumber
                                              : "No number",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppConstants.primaryColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatDate(service.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Main Content: Image + Info
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Service Image with Discount Badge
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        service.serviceImage,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    // Discount Badge
                                    if (discountPercent != "0")
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            "$discountPercent% OFF",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),

                                // Service Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title + Active Status
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              service.serviceTitle,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: service.isActive
                                                  ? Colors.green.withOpacity(
                                                      0.15,
                                                    )
                                                  : Colors.red.withOpacity(
                                                      0.15,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              service.isActive
                                                  ? "Active"
                                                  : "Inactive",
                                              style: TextStyle(
                                                color: service.isActive
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      // Service Type Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppConstants.primaryColor
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          service.serviceType,
                                          style: TextStyle(
                                            color: AppConstants.primaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // Description
                                      Text(
                                        service.description,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      const SizedBox(height: 10),

                                      // Price
                                      Row(
                                        children: [
                                          Text(
                                            "₹${service.discountPrice}",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppConstants.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "₹${service.originalPrice}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Address
                            Row(
                              children: [
                                Icon(
                                  Iconsax.location,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    service.providerAddress.isNotEmpty
                                        ? service.providerAddress
                                        : "Address not provided",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Divider(height: 1, thickness: 1, color: Colors.grey[200]),

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Edit Button
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  // Navigate to edit screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditServiceScreen(
                                        serviceData: service,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Iconsax.edit, size: 18),
                                label: const Text("Edit"),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppConstants.primaryColor,
                                ),
                              ),
                            ),

                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.grey[300],
                            ),

                            // Toggle Status Button
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () async {
                                  await toggleIsActive(
                                    service.isActive,
                                    service.id,
                                  );
                                  // TODO: Toggle active status
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        service.isActive
                                            ? "Service deactivated"
                                            : "Service activated",
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  service.isActive
                                      ? Iconsax.eye_slash
                                      : Iconsax.eye,
                                  size: 18,
                                ),
                                label: Text(
                                  service.isActive ? "Deactivate" : "Activate",
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: service.isActive
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                            ),

                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.grey[300],
                            ),

                            // Delete Button
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  // TODO: Show delete confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Delete Service"),
                                      content: const Text(
                                        "Are you sure you want to delete this service?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            // Delete Logic
                                            await deleteService(service.id);

                                            Navigator.pop(context);
                                            SnackBar(
                                              content: Text(
                                                "Service Deleted Successfully",
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Iconsax.trash, size: 18),
                                label: const Text("Delete"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (err, _) => Center(child: Text(err.toString())),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
      drawer: Drawer(),
    );
  }
}
