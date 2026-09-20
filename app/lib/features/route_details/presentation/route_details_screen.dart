import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/demo_data.dart';
import '../../../shared/formatting.dart';
import '../../../shared/models/route.dart' as model;
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/route_detail_card.dart';
import '../../booking/presentation/booking_screen.dart';

/// Driver, departure time, free seats and price for one route.
class RouteDetailsScreen extends StatelessWidget {
  const RouteDetailsScreen({super.key, required this.routeId});

  final String routeId;

  /// Below this many seats left the interface says so in words as well.
  static const int _fewSeats = 2;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final model.Route route = demoRouteById(routeId);
    final int free = route.freeSeats(demoBookings);

    return Scaffold(
      appBar: AppBar(title: const Text('Маршрут')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.screen,
          Spacing.sm,
          Spacing.screen,
          Spacing.block,
        ),
        children: <Widget>[
          RouteDetailCard(
            route: route,
            driver: demoUserById(route.driverId),
            freeSeats: free,
          ),
          if (free > 0 && free <= _fewSeats) ...<Widget>[
            const SizedBox(height: Spacing.lg),
            Text(
              'Свободно только ${Formatting.seats(free)}.',
              style: AppTypography.body.copyWith(color: colors.warn),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          Spacing.screen,
          0,
          Spacing.screen,
          Spacing.lg,
        ),
        child: PrimaryButton(
          label: 'Забронировать место',
          onPressed: free == 0
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BookingScreen(routeId: route.id),
                    ),
                  ),
        ),
      ),
    );
  }
}
