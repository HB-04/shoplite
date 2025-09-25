import 'package:flutter/material.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;
  final Color? starColor;

  const RatingDisplay({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.starSize = 20,
    this.starColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Stars
        Row(
          children: List.generate(5, (index) {
            final starRating = index + 1;
            return Icon(
              starRating <= rating
                  ? Icons.star
                  : starRating - 0.5 <= rating
                      ? Icons.star_half
                      : Icons.star_border,
              color: starColor ?? Colors.amber[600],
              size: starSize,
            );
          }),
        ),
        const SizedBox(width: 8),

        // Rating value
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),

        // Review count
        Text(
          '($reviewCount reviews)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
