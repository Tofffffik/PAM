import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

/// A labelled input: the label sits above the box, the box is [surface] with a
/// 1px [edge] outline, the focus ring is [ink] and never the accent.
///
/// The field takes part in the enclosing [Form] through [validator]: the
/// message it returns is drawn under the box in [stop], the same way as an
/// explicit [errorText].
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.validator,
    this.autovalidateMode,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.trailing,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChanged);
  TextEditingController? _ownController;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_onTextChanged);
      _controller.addListener(_onTextChanged);
    }
  }

  void _onFocusChanged() => setState(() {});

  /// Text set from code — a picker writing the date, the swap button — has to
  /// reach the form field too, or validation would see the old value.
  void _onTextChanged() {
    final FormFieldState<String>? field = _fieldKey.currentState;
    if (field != null && field.value != _controller.text) {
      field.didChange(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _ownController?.dispose();
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return FormField<String>(
      key: _fieldKey,
      initialValue: _controller.text,
      // The controller is the source of truth: after `Form.reset` the form
      // field's own value goes back to the initial one, the text does not.
      validator: widget.validator == null
          ? null
          : (_) => widget.validator!(_controller.text),
      autovalidateMode: widget.autovalidateMode,
      builder: (FormFieldState<String> field) {
        final String? error = widget.errorText ?? field.errorText;

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
              hasError: error != null,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      autofillHints: widget.autofillHints,
                      inputFormatters: widget.inputFormatters,
                      obscureText: widget.obscureText,
                      readOnly: widget.readOnly,
                      onTap: widget.onTap,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                      cursorColor: colors.ink,
                      style: AppTypography.body.copyWith(color: colors.ink),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: widget.hint,
                        hintStyle: AppTypography.body.copyWith(
                          color: colors.moss,
                        ),
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
            if (error != null) FieldError(error),
          ],
        );
      },
    );
  }
}

/// The message under an invalid field. It is a live region, so the screen
/// reader announces it as soon as it appears.
class FieldError extends StatelessWidget {
  const FieldError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Semantics(
        liveRegion: true,
        child: Text(
          message,
          style: AppTypography.caption.copyWith(color: context.colors.stop),
        ),
      ),
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
///
/// The pair is validated as one value — two valid cities can still be the
/// same city — so a single [validator] receives both texts and its message
/// goes under the whole outline.
class CityPairField extends StatefulWidget {
  const CityPairField({
    super.key,
    required this.fromController,
    required this.toController,
    this.onSwap,
    this.validator,
    this.autovalidateMode,
  });

  final TextEditingController fromController;
  final TextEditingController toController;
  final VoidCallback? onSwap;
  final String? Function(String from, String to)? validator;
  final AutovalidateMode? autovalidateMode;

  @override
  State<CityPairField> createState() => _CityPairFieldState();
}

class _CityPairFieldState extends State<CityPairField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();

  /// One string standing for both texts, so the form field notices a change
  /// in either of them.
  String get _pair =>
      '${widget.fromController.text}\n${widget.toController.text}';

  @override
  void initState() {
    super.initState();
    widget.fromController.addListener(_onTextChanged);
    widget.toController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final FormFieldState<String>? field = _fieldKey.currentState;
    if (field != null && field.value != _pair) field.didChange(_pair);
  }

  @override
  void dispose() {
    widget.fromController.removeListener(_onTextChanged);
    widget.toController.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final String? Function(String from, String to)? validator =
        widget.validator;

    return FormField<String>(
      key: _fieldKey,
      initialValue: _pair,
      autovalidateMode: widget.autovalidateMode,
      validator: validator == null
          ? null
          : (_) =>
              validator(widget.fromController.text, widget.toController.text),
      builder: (FormFieldState<String> field) {
        final bool hasError = field.errorText != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(Radii.field),
                    border: Border.all(
                      color: hasError ? colors.stop : colors.edge,
                      width: hasError ? Sizes.focusLine : Sizes.hairline,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      _CityHalf(
                        label: 'Откуда',
                        controller: widget.fromController,
                      ),
                      Divider(height: Sizes.hairline, color: colors.edge),
                      _CityHalf(label: 'Куда', controller: widget.toController),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: Spacing.sm),
                  child: _SwapButton(onPressed: widget.onSwap),
                ),
              ],
            ),
            if (hasError) FieldError(field.errorText!),
          ],
        );
      },
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
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
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
          child: Semantics(
            label: 'Поменять города местами',
            button: true,
            child: Icon(Icons.swap_vert, color: colors.ink, size: 20),
          ),
        ),
      ),
    );
  }
}
