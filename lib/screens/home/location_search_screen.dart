import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/repository/location_repository.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  late FlutterGooglePlacesSdk _places;
  final TextEditingController _controller = TextEditingController();

  List<AutocompletePrediction> _predictions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _places = FlutterGooglePlacesSdk(AppConstants.MAPAPI);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // 🔍 Search places
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.isEmpty) {
        setState(() => _predictions = []);
        return;
      }

      final result = await _places.findAutocompletePredictions(
        value,
        countries: ['in'],
      );

      setState(() => _predictions = result.predictions);
    });
  }

  final LocationRepository locationRepo = LocationRepository();
  // Get Current Location
  Future<void> _useCurrentLocation(BuildContext context) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Save current location to Firestore
      await locationRepo.saveUserAddress(userId);

      Navigator.pop(context);
    } catch (e) {
      print("Error getting current location: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to get location: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔶 SafeArea + Search bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 30.h,
                bottom: 10.h,
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search for your location",
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.my_location, color: Colors.deepPurple),
            title: const Text(
              "Use current location",
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _useCurrentLocation(context),
          ),

          // 🔶 Suggestions
          Expanded(
            child: ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];

                return ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.deepPurple,
                  ),
                  title: Text(
                    prediction.fullText,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () async {
                    final details = await _places.fetchPlace(
                      prediction.placeId,
                      fields: [PlaceField.Location, PlaceField.Address],
                    );

                    if (details.place != null) {
                      final userId = FirebaseAuth.instance.currentUser!.uid;
                      final address = details.place!.address ?? "";
                      final lat = details.place!.latLng?.lat;
                      final lng = details.place!.latLng?.lng;

                      if (lat != null && lng != null) {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(userId)
                            .update({
                              "userAddress": address,
                              "lat": lat,
                              "lng": lng,
                              "updatedAt": DateTime.now(),
                            });

                        Navigator.pop(context, {
                          "address": address,
                          "lat": lat,
                          "lng": lng,
                        });
                      }
                    }
                  },
                );
              },
            ),
          ),

          // 🔹 Google branding (REQUIRED)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Powered by Google",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
