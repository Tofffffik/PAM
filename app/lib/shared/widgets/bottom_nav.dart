import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

/// The three sections of the application. The active one is marked by colour
/// and weight alone — no pill, no plate behind the label.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int>? onSelect;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem('Поиск', Icons.search),
    _NavItem('Поездки', Icons.directions_car_outlined),
    _NavItem('Профиль', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.edge, width: Sizes.hairline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List<Widget>.generate(_items.length, (int index) {
            final _NavItem item = _items[index];
            final bool active = index == currentIndex;
            final Color color = active ? colors.ink : colors.moss;

            return Expanded(
              child: Semantics(
                button: true,
                selected: active,
                child: InkWell(
                  onTap: onSelect == null ? null : () => onSelect!(index),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: Sizes.tap + Spacing.md,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(item.icon, color: color, size: 24),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          item.label,
                          style: AppTypography.caption.copyWith(
                            color: color,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
