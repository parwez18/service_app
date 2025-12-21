import 'package:flutter/material.dart';

class ServiceModel {
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController duration = TextEditingController();

  void dispose() {
    name.dispose();
    price.dispose();
    duration.dispose();
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name.text.trim(),
      'price': double.tryParse(price.text.trim()) ?? 0.0,
      'duration': "${duration.text.trim()} minutes",
    };
  }
}
