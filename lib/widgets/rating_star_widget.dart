import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingStarWidget extends StatelessWidget {
  final double rating;
  final int starCount;
  final Color color;
  final double size;
  final bool allowHalfRating;

  const RatingStarWidget({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.color = Colors.amber,
    this.size = 30,
    this.allowHalfRating = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        IconData icon;
        if (index >= rating) {
          icon = Icons.star_border;
        } else if (index > rating - 1 && index < rating && allowHalfRating) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star;
        }
        return Icon(icon, color: color, size: size.sp);
      }),
    );
  }
}

class RatingStarSelector extends ConsumerStatefulWidget {
  final Function(double) onRatingChanged;
  final double initialRating;
  final int starCount;
  final Color color;
  final Color borderColor;
  final double size;

  const RatingStarSelector({
    super.key,
    required this.onRatingChanged,
    this.initialRating = 0,
    this.starCount = 5,
    this.color = Colors.amber,
    this.borderColor = Colors.grey,
    this.size = 40,
  });

  @override
  ConsumerState<RatingStarSelector> createState() => _RatingStarSelectorState();
}

class _RatingStarSelectorState extends ConsumerState<RatingStarSelector> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.starCount, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1.0;
            });
            widget.onRatingChanged(_currentRating);
          },
          child: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            color: index < _currentRating ? widget.color : widget.borderColor,
            size: widget.size.sp,
          ),
        );
      }),
    );
  }
}
