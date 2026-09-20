import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

/// Filled with the accent, dark text on it. One per screen.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final bool enabled = onPressed != null;

    return _ButtonShell(
      onPressed: onPressed,
      expand: expand,
      decoration: BoxDecoration(
        color: enabled ? colors.lime : colors.edge,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      label: label,
      // Text on lime is always ink, never white.
      labelColor: enabled ? AppColors.onLime : colors.moss,
    );
  }
}

/// No fill, an [edge] outline.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return _ButtonShell(
      onPressed: onPressed,
      expand: expand,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: colors.edge, width: Sizes.hairline),
      ),
      label: label,
      labelColor: onPressed == null ? colors.moss : colors.ink,
    );
  }
}

/// No fill, [stop]-coloured label. Cancelling and signing out.
class DangerButton extends StatelessWidget {
  const DangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return _ButtonShell(
      onPressed: onPressed,
      expand: expand,
      decoration: const BoxDecoration(),
      label: label,
      labelColor: onPressed == null ? colors.moss : colors.stop,
    );
  }
}

/// Label only; it underlines while held down.
class AppTextButton extends StatefulWidget {
  const AppTextButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  State<AppTextButton> createState() => _AppTextButtonState();
}

class _AppTextButtonState extends State<AppTextButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Sizes.tap),
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: Text(
            widget.label,
            style: AppTypography.button.copyWith(
              color: colors.ink,
              decoration: _pressed ? TextDecoration.underline : null,
              decorationColor: colors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared geometry of the three box buttons: height 56, radius 20, the label
/// centred and never wrapped out of the button.
class _ButtonShell extends StatelessWidget {
  const _ButtonShell({
    required this.onPressed,
    required this.decoration,
    required this.label,
    required this.labelColor,
    required this.expand,
  });

  final VoidCallback? onPressed;
  final BoxDecoration decoration;
  final String label;
  final Color labelColor;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final Widget button = Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(Radii.card),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Sizes.control),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xl,
                vertical: Spacing.md,
              ),
              // heightFactor keeps the button from stretching when it is
              // handed loose constraints, as the bottom bar slot does.
              child: Align(
                alignment: Alignment.center,
                heightFactor: 1,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.button.copyWith(color: labelColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
