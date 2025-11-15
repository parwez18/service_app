import 'package:flutter/material.dart';
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
    return Scaffold(body: ServicesWidget(widget.serviceType));
  }
}
