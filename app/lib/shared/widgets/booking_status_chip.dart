import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';
import '../models/booking.dart';

/// Status of a booking: a dot and a word, no coloured plate behind them.
class BookingStatusChip extends StatelessWidget {
  const BookingStatusChip({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final bool cancelled = status == BookingStatus.cancelled;
    final Color color = cancelled ? colors.stop : colors.ok;
    final String label = cancelled ? 'Отменена' : 'Активна';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: Sizes.statusDot,
          height: Sizes.statusDot,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: Spacing.sm),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: color,
            decoration: cancelled ? TextDecoration.lineThrough : null,
            decorationColor: color,
          ),
        ),
      ],
    );
  }
}
