import 'package:flutter/material.dart';

/// Shrinks its child slightly while it is held down.
///
/// Motion here answers a direct action, so it is allowed; when the system
/// asks for reduced motion the change is applied instantly instead.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.98,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final BorderRadius? borderRadius;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool instant = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: widget.onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? widget.scale : 1,
          duration: instant ? Duration.zero : const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
