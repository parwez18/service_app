import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationRepository {
  /// Get current location safely
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception("Please enable location services");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10),
    );
  }

  /// Reverse geocode
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

    if (placemarks.isEmpty) {
      return "Unknown Address";
    }

    Placemark p = placemarks.first;

    return [
      p.street,
      p.subLocality,
      p.locality,
      p.postalCode,
      p.country,
    ].where((e) => e != null && e.isNotEmpty).join("- ");
  }

  /// Get combined location + address
  Future<Map<String, dynamic>> getUserLocationData() async {
    Position pos = await _getCurrentLocation();
    String address = await getAddressFromLatLng(pos.latitude, pos.longitude);

    return {"lat": pos.latitude, "lng": pos.longitude, "address": address};
  }

  /// Save to Firestore
  Future<void> saveUserAddress(String userId) async {
    final data = await getUserLocationData();

    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "userAddress": data["address"],
      "lat": data["lat"],
      "lng": data["lng"],
      "updatedAt": DateTime.now(),
    });
  }
}
