import 'package:flutter/material.dart';
import 'package:khujo_app/appconstants/appconstants.dart';

customAppBar(String title) {
  return AppBar(
    title: Text(title, style: TextStyle(color: Colors.white)),
    centerTitle: true,
    backgroundColor: AppConstants.primaryColor,
    iconTheme: IconThemeData(color: Colors.white),
  );
}
