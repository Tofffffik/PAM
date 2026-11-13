import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/not_found_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/formatting.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/route.dart' as model;
import '../../../shared/models/user.dart';
import '../../../shared/state/catalog.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/booking_status_chip.dart';
import '../../../shared/widgets/load_failed.dart';
import '../../../shared/widgets/route_detail_card.dart';
import '../../auth/domain/session_controller.dart';

/// Driver, departure time, free seats and price for one route.
///
/// The booking button is off when there is nothing to book: the route is
/// sold out or the user drives it. The booking screen applies the same rule
/// to a link typed by hand.
class RouteDetailsScreen extends ConsumerWidget {
  const RouteDetailsScreen({super.key, required this.routeId});

  final String routeId;

  /// Below this many seats left the interface says so in words as well.
  static const int _fewSeats = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors colors = context.colors;
    final AsyncValue<RouteBoard> boardAsync = ref.watch(routeBoardProvider);
    final RouteBoard? board = boardAsync.value;

    if (board == null) {
      return _Waiting(failed: boardAsync.hasError);
    }
    final model.Route? route = board.routeById(routeId);
    if (route == null) {
      return const NotFoundScreen(routeMissing: true);
    }

    final String? userId = ref.watch(sessionProvider)?.id;
    final int free = board.freeSeats(route);
    final BookingBlock? block = bookingBlockFor(
      route: route,
      bookings: board.bookings,
      userId: userId,
    );
    final AsyncValue<User?> driverAsync =
        ref.watch(driverProvider(route.driverId));
    if (!driverAsync.hasValue) {
      return const _Waiting(failed: false);
    }
    final User driver = driverAsync.value ??
        User(id: route.driverId, name: 'Водитель', email: '');

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
          RouteDetailCard(route: route, driver: driver, freeSeats: free),
          if (block == BookingBlock.ownRoute) ...<Widget>[
            const SizedBox(height: Spacing.lg),
            Text(
              'Это ваш маршрут: бронируют его попутчики.',
              style: AppTypography.body.copyWith(color: colors.moss),
            ),
          ] else if (free > 0 && free <= _fewSeats) ...<Widget>[
            const SizedBox(height: Spacing.lg),
            Text(
              'Свободно только ${Formatting.seats(free)}.',
              style: AppTypography.body.copyWith(color: colors.warn),
            ),
          ],
          for (final Booking booking in activeBookingsOn(
            routeId: route.id,
            bookings: board.bookings,
            userId: userId,
          )) ...<Widget>[
            const SizedBox(height: Spacing.lg),
            _YourBooking(booking: booking),
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
          onPressed: block != null
              ? null
              : () => context.push(AppRoutes.booking(route.id)),
        ),
      ),
    );
  }
}

/// Shown while the routes or the driver are loading, or when loading failed.
class _Waiting extends StatelessWidget {
  const _Waiting({required this.failed});

  final bool failed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Маршрут')),
      body: failed
          ? const LoadFailed()
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

/// A booking the user holds on this route, with the way to cancel it.
///
/// Cancelling is asked about first: it cannot be undone from here, the seats
/// go back on sale at once. The record stays and shows as «Отменена» in
/// «Мои поездки».
class _YourBooking extends ConsumerStatefulWidget {
  const _YourBooking({required this.booking});

  final Booking booking;

  @override
  ConsumerState<_YourBooking> createState() => _YourBookingState();
}

class _YourBookingState extends ConsumerState<_YourBooking> {
  bool _cancelling = false;

  Future<void> _cancel() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('Отменить бронь? Места вернутся в продажу.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Оставить'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Отменить бронь'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    await ref.read(bookingsProvider.notifier).cancel(widget.booking.id);
    if (!mounted) return;
    setState(() => _cancelling = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Бронь отменена')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        Spacing.xl,
        Spacing.lg,
        Spacing.xl,
        Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Ваша бронь',
            style: AppTypography.caption.copyWith(color: colors.moss),
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  Formatting.seats(widget.booking.seats),
                  style: AppTypography.body.copyWith(color: colors.ink),
                ),
              ),
              BookingStatusChip(status: widget.booking.status),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          DangerButton(
            label: 'Отменить бронь',
            onPressed: _cancelling ? null : _cancel,
          ),
        ],
      ),
    );
  }
}
