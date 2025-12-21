import 'package:flutter/material.dart';
import 'package:khujo_app/widgets/rating_star_widget.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hello")),
      body: RatingStarWidget(rating: 3.0),
    );
  }
}
