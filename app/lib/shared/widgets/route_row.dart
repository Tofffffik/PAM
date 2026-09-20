import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';
import '../formatting.dart';
import '../models/route.dart' as model;
import 'press_scale.dart';
import 'seat_pips.dart';

/// One trip in the search results.
///
/// The departure time is set as large as a shop sign and never shrinks; the
/// city pair gives way to an ellipsis instead. Rows carry no outline and no
/// shadow — they are separated by an 8pt gap over the paper background.
class RouteRow extends StatelessWidget {
  const RouteRow({
    super.key,
    required this.route,
    required this.freeSeats,
    this.onTap,
  });

  final model.Route route;
  final int freeSeats;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return PressScale(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: Sizes.routeRow),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Radii.card),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(
                  Formatting.time(route.departureAt),
                  style: AppTypography.timeHero.copyWith(color: colors.ink),
                  maxLines: 1,
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    '${route.fromCity} → ${route.toCity}',
                    style: AppTypography.city.copyWith(color: colors.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  Formatting.price(route.price),
                  style: AppTypography.price.copyWith(color: colors.ink),
                  maxLines: 1,
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Row(
              children: <Widget>[
                Text(
                  Formatting.dayShort(route.departureAt),
                  style: AppTypography.caption.copyWith(color: colors.moss),
                  maxLines: 1,
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SeatPips(
                      total: route.seatsTotal,
                      free: freeSeats,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
