import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';
import '../formatting.dart';
import '../models/route.dart' as model;
import '../models/user.dart';
import 'seat_pips.dart';

/// The route card on the details screen — the one place in the application
/// that carries the ticket perforation, and it is used nowhere else.
class RouteDetailCard extends StatelessWidget {
  const RouteDetailCard({
    super.key,
    required this.route,
    required this.driver,
    required this.freeSeats,
  });

  final model.Route route;
  final User driver;
  final int freeSeats;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.card),
      child: ColoredBox(
        color: colors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.xl,
                Spacing.xl,
                Spacing.xl,
                Spacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    Formatting.time(route.departureAt),
                    style: AppTypography.timeXL.copyWith(color: colors.ink),
                    maxLines: 1,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    '${route.fromCity} → ${route.toCity}',
                    style: AppTypography.city.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    Formatting.dayLong(route.departureAt),
                    style: AppTypography.caption.copyWith(color: colors.moss),
                  ),
                ],
              ),
            ),
            const _Perforation(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.xl,
                Spacing.lg,
                Spacing.xl,
                Spacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: _Field(
                          label: 'Водитель',
                          value: Text(
                            driver.name,
                            style:
                                AppTypography.body.copyWith(color: colors.ink),
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.lg),
                      _Field(
                        label: 'Цена за место',
                        alignment: CrossAxisAlignment.end,
                        value: Text(
                          Formatting.price(route.price),
                          style: AppTypography.price.copyWith(color: colors.ink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.lg),
                  _Field(
                    label: 'Места',
                    value: SeatPips(
                      total: route.seatsTotal,
                      free: freeSeats,
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

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
  });

  final String label;
  final Widget value;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: AppTypography.caption.copyWith(color: context.colors.moss),
        ),
        const SizedBox(height: Spacing.xs),
        value,
      ],
    );
  }
}

/// The torn-off stub: two half-circle notches in the screen colour bite into
/// the card edges, with a dashed rule between them.
class _Perforation extends StatelessWidget {
  const _Perforation();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return SizedBox(
      height: Sizes.notch * 2,
      child: CustomPaint(
        painter: _PerforationPainter(
          notchColor: colors.paper,
          lineColor: colors.edge,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _PerforationPainter extends CustomPainter {
  const _PerforationPainter({
    required this.notchColor,
    required this.lineColor,
  });

  final Color notchColor;
  final Color lineColor;

  static const double _dash = 4;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final double y = size.height / 2;

    final Paint notch = Paint()..color = notchColor;
    canvas.drawCircle(Offset(0, y), Sizes.notch, notch);
    canvas.drawCircle(Offset(size.width, y), Sizes.notch, notch);

    final Paint line = Paint()
      ..color = lineColor
      ..strokeWidth = Sizes.hairline
      ..strokeCap = StrokeCap.butt;

    double x = Sizes.notch + Spacing.md;
    final double end = size.width - Sizes.notch - Spacing.md;
    while (x < end) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + _dash).clamp(x, end), y),
        line,
      );
      x += _dash + _gap;
    }
  }

  @override
  bool shouldRepaint(_PerforationPainter oldDelegate) {
    return oldDelegate.notchColor != notchColor ||
        oldDelegate.lineColor != lineColor;
  }
}
