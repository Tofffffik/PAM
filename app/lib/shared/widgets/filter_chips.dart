import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

/// One toggle in the filter row: filled with the accent when on, outlined
/// when off.
class FilterToggleChip extends StatelessWidget {
  const FilterToggleChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Semantics(
      button: true,
      selected: selected,
      child: SizedBox(
        height: Sizes.tap,
        child: Material(
          color: selected ? colors.lime : Colors.transparent,
          shape: StadiumBorder(
            side: selected
                ? BorderSide.none
                : BorderSide(color: colors.edge, width: Sizes.hairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: selected ? AppColors.onLime : colors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The horizontal row of filters under the search form.
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.labels,
    required this.selected,
    this.onToggle,
  });

  final List<String> labels;
  final Set<String> selected;
  final ValueChanged<String>? onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Sizes.tap,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.screen),
        itemCount: labels.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: Spacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final String label = labels[index];
          return FilterToggleChip(
            label: label,
            selected: selected.contains(label),
            onTap: onToggle == null ? null : () => onToggle!(label),
          );
        },
      ),
    );
  }
}
