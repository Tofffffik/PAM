import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/navigation.dart';
import '../../../core/router/not_found_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../shared/formatting.dart';
import '../../../shared/models/route.dart' as model;
import '../../../shared/state/catalog.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/load_failed.dart';
import '../../../shared/widgets/seat_pips.dart';
import '../../auth/domain/session_controller.dart';

/// Choosing how many seats to take and confirming the booking.
///
/// The booking is written through [bookingsProvider]. A route that is sold out
/// or driven by the user is not bookable: the screen sends the user back to the
/// route, which explains why.
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.routeId});

  final String routeId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _seats = 1;
  bool _saving = false;
  bool _confirmed = false;

  Future<void> _confirm(model.Route route) async {
    final String? userId = ref.read(sessionProvider)?.id;
    if (userId == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(bookingsProvider.notifier).book(
            routeId: route.id,
            passengerId: userId,
            seats: _seats,
          );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _confirmed = true;
      });
    } on BookingRefused catch (refused) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_refusalMessage(refused))),
      );
    }
  }

  static String _refusalMessage(BookingRefused refused) {
    switch (refused.reason) {
      case BookingRefusal.notEnoughSeats:
        return refused.seatsLeft == 0
            ? 'Мест на этот рейс уже нет'
            : 'Осталось только ${Formatting.seats(refused.seatsLeft)}';
      case BookingRefusal.ownRoute:
        return 'Нельзя забронировать свой маршрут';
      case BookingRefusal.routeNotFound:
        return 'Маршрут не найден';
      case BookingRefusal.invalidSeats:
        return 'Выберите от 1 до 12 мест';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AsyncValue<RouteBoard> boardAsync = ref.watch(routeBoardProvider);
    final RouteBoard? board = boardAsync.value;

    if (board == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Бронирование')),
        body: boardAsync.hasError
            ? const LoadFailed()
            : const Center(child: CircularProgressIndicator()),
      );
    }

    final model.Route? route = board.routeById(widget.routeId);
    if (route == null) return const NotFoundScreen(routeMissing: true);

    final BookingBlock? block = bookingBlockFor(
      route: route,
      bookings: board.bookings,
      userId: ref.watch(sessionProvider)?.id,
    );
    if (block != null && !_confirmed) {
      // Back to the route, which shows why it cannot be booked.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.route(route.id));
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final int free = board.freeSeats(route);

    return Scaffold(
      appBar: AppBar(title: const Text('Бронирование')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.screen,
          Spacing.sm,
          Spacing.screen,
          Spacing.block,
        ),
        children: <Widget>[
          _Summary(route: route, seats: _seats),
          const SizedBox(height: Spacing.block),
          if (_confirmed)
            Text(
              _seats == 1
                  ? 'Место забронировано'
                  : 'Забронировано ${Formatting.seats(_seats)}',
              style: AppTypography.body.copyWith(color: colors.ok),
            )
          else ...<Widget>[
            Text(
              'Сколько мест',
              style: AppTypography.caption.copyWith(color: colors.moss),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: <Widget>[
                _StepButton(
                  icon: Icons.remove,
                  onPressed:
                      _seats > 1 ? () => setState(() => _seats -= 1) : null,
                ),
                const SizedBox(width: Spacing.lg),
                Text(
                  '$_seats',
                  style: AppTypography.price.copyWith(color: colors.ink),
                ),
                const SizedBox(width: Spacing.lg),
                _StepButton(
                  icon: Icons.add,
                  onPressed:
                      _seats < free ? () => setState(() => _seats += 1) : null,
                ),
                const SizedBox(width: Spacing.xl),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SeatPips(total: free, free: free - _seats),
                  ),
                ),
              ],
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
        child: _confirmed
            ? SecondaryButton(
                label: 'Готово',
                onPressed: () => context.popOrGo(AppRoutes.route(route.id)),
              )
            : PrimaryButton(
                label: _seats == 1
                    ? 'Забронировать место'
                    : 'Забронировать ${Formatting.seats(_seats)}',
                onPressed: _saving ? null : () => _confirm(route),
              ),
      ),
    );
  }
}

/// What the passenger is about to pay for.
class _Summary extends StatelessWidget {
  const _Summary({required this.route, required this.seats});

  final model.Route route;
  final int seats;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(Spacing.xl),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${route.fromCity} → ${route.toCity}',
            style: AppTypography.city.copyWith(color: colors.ink),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            '${Formatting.dayLong(route.departureAt)}, '
            '${Formatting.time(route.departureAt)}',
            style: AppTypography.caption.copyWith(color: colors.moss),
          ),
          const SizedBox(height: Spacing.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${Formatting.price(route.price)} × $seats',
                  style: AppTypography.body.copyWith(color: colors.moss),
                ),
              ),
              Text(
                Formatting.price(route.price * seats),
                style: AppTypography.price.copyWith(color: colors.ink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Round outlined control of the seat counter.
class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final bool enabled = onPressed != null;

    return SizedBox(
      width: Sizes.tap,
      height: Sizes.tap,
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(
          side: BorderSide(color: colors.edge, width: Sizes.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Icon(
            icon,
            size: 20,
            color: enabled ? colors.ink : colors.moss,
          ),
        ),
      ),
    );
  }
}
