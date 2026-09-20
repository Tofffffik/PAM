import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/demo_data.dart';
import '../../../shared/formatting.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/route.dart' as model;
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/booking_status_chip.dart';
import '../../../shared/widgets/route_row.dart';
import '../../publish_route/presentation/publish_route_screen.dart';
import '../../route_details/presentation/route_details_screen.dart';

/// Two sections: the trips booked as a passenger and the routes driven.
class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final List<Booking> bookings = demoMyBookings;
    final List<model.Route> routes = demoMyRoutes;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: Spacing.xxl),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.screen,
                Spacing.xl,
                Spacing.screen,
                Spacing.lg,
              ),
              child: Text(
                'Мои поездки',
                style: AppTypography.title.copyWith(color: colors.ink),
              ),
            ),
            const _SectionLabel('Как пассажир'),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Spacing.screen),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < bookings.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: Spacing.sm),
                    _BookingRow(booking: bookings[i]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Spacing.block),
            const _SectionLabel('Как водитель'),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Spacing.screen),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < routes.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: Spacing.sm),
                    RouteRow(
                      route: routes[i],
                      freeSeats: routes[i].freeSeats(demoBookings),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              RouteDetailsScreen(routeId: routes[i].id),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.lg),
                  SecondaryButton(
                    label: 'Опубликовать маршрут',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PublishRouteScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.screen,
        0,
        Spacing.screen,
        Spacing.md,
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(color: context.colors.moss),
      ),
    );
  }
}

/// A booked trip: the same shape as a route row, but the right column carries
/// the booking status instead of the free seats.
class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final model.Route route = demoRouteById(booking.routeId);

    return Container(
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
              const SizedBox(width: Spacing.lg),
              Expanded(
                child: Text(
                  '${route.fromCity} → ${route.toCity}',
                  style: AppTypography.city.copyWith(color: colors.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            children: <Widget>[
              Text(
                '${Formatting.dayShort(route.departureAt)} · '
                '${Formatting.seats(booking.seats)}',
                style: AppTypography.caption.copyWith(color: colors.moss),
                maxLines: 1,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: BookingStatusChip(status: booking.status),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
