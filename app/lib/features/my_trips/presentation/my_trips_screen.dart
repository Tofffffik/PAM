import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/formatting.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/route.dart' as model;
import '../../../shared/state/catalog.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/booking_status_chip.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/load_failed.dart';
import '../../../shared/widgets/press_scale.dart';
import '../../../shared/widgets/route_row.dart';
import '../../auth/domain/session_controller.dart';

/// Two sections: the trips booked as a passenger and the routes driven.
class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors colors = context.colors;
    final AsyncValue<RouteBoard> boardAsync = ref.watch(routeBoardProvider);
    final RouteBoard? board = boardAsync.value;
    final String? userId = ref.watch(sessionProvider)?.id;

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
            if (board == null)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.xl),
                child: Center(
                  child: boardAsync.hasError
                      ? const LoadFailed()
                      : const CircularProgressIndicator(),
                ),
              )
            else
              ..._sections(context, board, userId),
          ],
        ),
      ),
    );
  }

  List<Widget> _sections(
    BuildContext context,
    RouteBoard board,
    String? userId,
  ) {
    final List<_BookedTrip> booked = <_BookedTrip>[
      for (final Booking booking in board.bookings)
        if (booking.passengerId == userId)
          if (board.routeById(booking.routeId) case final model.Route route)
            _BookedTrip(booking: booking, route: route),
    ]..sort(
        (_BookedTrip a, _BookedTrip b) =>
            b.booking.createdAt.compareTo(a.booking.createdAt),
      );
    final List<model.Route> driven = board.routes
        .where((model.Route route) => route.driverId == userId)
        .toList()
      ..sort(
        (model.Route a, model.Route b) =>
            a.departureAt.compareTo(b.departureAt),
      );

    return <Widget>[
      const _SectionLabel('Как пассажир'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.screen),
        child: booked.isEmpty
            ? const EmptyState.noTrips()
            : Column(
                children: <Widget>[
                  for (int i = 0; i < booked.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: Spacing.sm),
                    _BookingRow(trip: booked[i]),
                  ],
                ],
              ),
      ),
      const SizedBox(height: Spacing.block),
      const _SectionLabel('Как водитель'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.screen),
        child: Column(
          children: <Widget>[
            if (driven.isEmpty) const EmptyState.noPublishedRoutes(),
            for (int i = 0; i < driven.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: Spacing.sm),
              RouteRow(
                route: driven[i],
                freeSeats: board.freeSeats(driven[i]),
                onTap: () => context.push(AppRoutes.route(driven[i].id)),
              ),
            ],
            const SizedBox(height: Spacing.lg),
            SecondaryButton(
              label: 'Опубликовать маршрут',
              onPressed: () => context.push(AppRoutes.publish),
            ),
          ],
        ),
      ),
    ];
  }
}

class _BookedTrip {
  const _BookedTrip({required this.booking, required this.route});

  final Booking booking;
  final model.Route route;
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
/// the booking status instead of the free seats. Tapping it opens the route.
class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.trip});

  final _BookedTrip trip;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final model.Route route = trip.route;
    final Booking booking = trip.booking;

    return PressScale(
      onTap: () => context.push(AppRoutes.route(route.id)),
      borderRadius: BorderRadius.circular(Radii.card),
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
                // The status always fits whole; a long date gives way.
                Expanded(
                  child: Text(
                    '${Formatting.dayShort(route.departureAt)} · '
                    '${Formatting.seats(booking.seats)}',
                    style: AppTypography.caption.copyWith(color: colors.moss),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                BookingStatusChip(status: booking.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
