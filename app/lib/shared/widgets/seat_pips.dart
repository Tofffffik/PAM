import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';
import '../formatting.dart';

/// The seat indicator: taken seats on the left as filled dots, free seats on
/// the right as outlines.
///
/// It is the loudest detail of the interface on purpose — it shows the rule
/// the whole domain turns on, that free seats are counted rather than stored.
/// The widget therefore takes [total] and [free] and derives nothing itself.
class SeatPips extends StatelessWidget {
  const SeatPips({
    super.key,
    required this.total,
    required this.free,
  });

  /// Seats the driver offers.
  final int total;

  /// Seats still available.
  final int free;

  /// Above this many seats the dots stop being countable at a glance and
  /// collapse into one dot plus the number.
  static const int _pipLimit = 8;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final int taken = (total - free).clamp(0, total);
    final bool soldOut = free <= 0;

    final String label = total > _pipLimit
        ? '${Formatting.seats(total)} · ${_freeLabel(free)}'
        : _freeLabel(free);

    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (total > _pipLimit)
          _Pip(color: colors.lime, filled: true, outline: colors.edge)
        else
          ...List<Widget>.generate(total, (int index) {
            final bool isTaken = index < taken;
            // The last free seat is outlined in warn: one seat left is a
            // different situation from three.
            final bool isLastSeat = free == 1 && index == total - 1;
            return Padding(
              padding: EdgeInsets.only(
                right: index == total - 1 ? 0 : Sizes.pipGap,
              ),
              child: _Pip(
                color: colors.lime,
                filled: isTaken,
                outline: isLastSeat ? colors.warn : colors.edge,
              ),
            );
          }),
        const SizedBox(width: Spacing.sm),
        Flexible(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(color: colors.moss),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Semantics(
      label: '${Formatting.seats(total)}, $label',
      excludeSemantics: true,
      child: soldOut ? Opacity(opacity: 0.45, child: row) : row,
    );
  }

  /// Colour is never the only carrier of meaning: the dots always come with
  /// this caption.
  static String _freeLabel(int free) {
    if (free <= 0) return 'мест нет';
    if (free == 1) return '1 место';
    return '$free свободно';
  }
}

class _Pip extends StatelessWidget {
  const _Pip({
    required this.color,
    required this.filled,
    required this.outline,
  });

  final Color color;
  final bool filled;
  final Color outline;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Sizes.pip,
      height: Sizes.pip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? color : null,
          border: filled
              ? null
              : Border.all(color: outline, width: Sizes.pipStroke),
        ),
      ),
    );
  }
}
