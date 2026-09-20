import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

/// A labelled input: the label sits above the box, the box is [surface] with a
/// 1px [edge] outline, the focus ring is [ink] and never the accent.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.trailing,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChanged);

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: AppTypography.caption.copyWith(color: colors.moss),
        ),
        const SizedBox(height: Spacing.sm),
        FieldBox(
          focused: _focusNode.hasFocus,
          hasError: widget.errorText != null,
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.obscureText,
                  readOnly: widget.readOnly,
                  onTap: widget.onTap,
                  cursorColor: colors.ink,
                  style: AppTypography.body.copyWith(color: colors.ink),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle:
                        AppTypography.body.copyWith(color: colors.moss),
                  ),
                ),
              ),
              if (widget.trailing != null) ...<Widget>[
                const SizedBox(width: Spacing.md),
                widget.trailing!,
              ],
            ],
          ),
        ),
        if (widget.errorText != null) ...<Widget>[
          const SizedBox(height: Spacing.xs),
          Text(
            widget.errorText!,
            style: AppTypography.caption.copyWith(color: colors.stop),
          ),
        ],
      ],
    );
  }
}

/// The box every input shares: height 56, radius 16, [surface] fill.
class FieldBox extends StatelessWidget {
  const FieldBox({
    super.key,
    required this.child,
    this.focused = false,
    this.hasError = false,
    this.borderRadius,
    this.border,
  });

  final Widget child;
  final bool focused;
  final bool hasError;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    final Color lineColor = hasError
        ? colors.stop
        : focused
            ? colors.ink
            : colors.edge;
    final double lineWidth =
        focused || hasError ? Sizes.focusLine : Sizes.hairline;

    return Container(
      constraints: const BoxConstraints(minHeight: Sizes.control),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(Radii.field),
        border: border ?? Border.all(color: lineColor, width: lineWidth),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        heightFactor: 1,
        child: child,
      ),
    );
  }
}

/// «Откуда» and «куда» stand against each other inside one outline, with the
/// swap button sitting on the rule between them.
class CityPairField extends StatelessWidget {
  const CityPairField({
    super.key,
    required this.fromController,
    required this.toController,
    this.onSwap,
  });

  final TextEditingController fromController;
  final TextEditingController toController;
  final VoidCallback? onSwap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(Radii.field),
            border: Border.all(color: colors.edge, width: Sizes.hairline),
          ),
          child: Column(
            children: <Widget>[
              _CityHalf(label: 'Откуда', controller: fromController),
              Divider(height: Sizes.hairline, color: colors.edge),
              _CityHalf(label: 'Куда', controller: toController),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: Spacing.sm),
          child: _SwapButton(onPressed: onSwap),
        ),
      ],
    );
  }
}

class _CityHalf extends StatelessWidget {
  const _CityHalf({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      constraints: const BoxConstraints(minHeight: Sizes.control),
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.sm,
        // Room for the swap button.
        Sizes.tap + Spacing.md,
        Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: AppTypography.caption.copyWith(color: colors.moss),
          ),
          TextField(
            controller: controller,
            cursorColor: colors.ink,
            style: AppTypography.body.copyWith(color: colors.ink),
            decoration: const InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwapButton extends StatelessWidget {
  const _SwapButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return SizedBox(
      width: Sizes.tap,
      height: Sizes.tap,
      child: Material(
        color: colors.surface,
        shape: CircleBorder(
          side: BorderSide(color: colors.edge, width: Sizes.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Icon(Icons.swap_vert, color: colors.ink, size: 20),
        ),
      ),
    );
  }
}
