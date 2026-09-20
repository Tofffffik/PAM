import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/demo_data.dart';
import '../../../shared/formatting.dart';
import '../../../shared/models/route.dart' as model;
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/seat_pips.dart';

/// Choosing how many seats to take and confirming the booking.
///
/// Nothing is written anywhere yet: the counter is local to the screen and
/// the confirmation is the static end of the flow until L4.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.routeId});

  final String routeId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _seats = 1;
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final model.Route route = demoRouteById(widget.routeId);
    final int free = route.freeSeats(demoBookings);

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
              'Место забронировано',
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
                onPressed: () => Navigator.of(context).pop(),
              )
            : PrimaryButton(
                label: _seats == 1
                    ? 'Забронировать место'
                    : 'Забронировать ${Formatting.seats(_seats)}',
                onPressed: () => setState(() => _confirmed = true),
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
