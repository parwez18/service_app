import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khujo_app/screens/helper_widgets/appbar_widget.dart';
import 'package:khujo_app/screens/home/services_widget.dart';

class CategoriesFullList extends StatefulWidget {
  final String serviceType;
  const CategoriesFullList({super.key, required this.serviceType});

  @override
  State<CategoriesFullList> createState() => _CategoriesFullListState();
}

class _CategoriesFullListState extends State<CategoriesFullList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(widget.serviceType),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: ServicesWidget(widget.serviceType),
      ),
    );
  }
}
