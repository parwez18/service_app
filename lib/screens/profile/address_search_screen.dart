import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:khujo_app/appconstants/appconstants.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';

class AddressSearchScreen extends StatelessWidget {
  final Function(String address, double lat, double lng) onPlaceSelected;

  const AddressSearchScreen({super.key, required this.onPlaceSelected});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: customAppBar("Search Address"),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: GooglePlaceAutoCompleteTextField(
              textEditingController: controller,
              googleAPIKey: AppConstants.MAPAPI,
              inputDecoration: InputDecoration(
                prefixIcon: Icon(Icons.location_on),
                filled: true,
                fillColor: Colors.white,
                hintText: "Search location",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              debounceTime: 400,
              isLatLngRequired: true,

              getPlaceDetailWithLatLng: (Prediction prediction) {
                if (prediction.lat == null || prediction.lng == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Could not fetch location")),
                  );
                  return;
                }

                final address = prediction.description ?? "";
                final lat = double.tryParse(prediction.lat!) ?? 0.0;
                final lng = double.tryParse(prediction.lng!) ?? 0.0;

                onPlaceSelected(address, lat, lng);
                Navigator.pop(context);
              },

              itemClick: (Prediction prediction) {
                controller.text = prediction.description ?? "";
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
