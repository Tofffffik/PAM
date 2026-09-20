import 'package:flutter/material.dart';

/// Colour tokens of the CarPool visual system.
///
/// The palette is declared explicitly for both brightnesses; it is never
/// derived from a seed colour. Widgets read the tokens through the theme
/// extension, so a widget never hard-codes a hex value.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.ink,
    required this.moss,
    required this.paper,
    required this.surface,
    required this.lime,
    required this.edge,
    required this.ok,
    required this.warn,
    required this.stop,
  });

  /// Primary text, dark surfaces, brand colour.
  final Color ink;

  /// Secondary text, labels, inactive icons.
  final Color moss;

  /// Screen background.
  final Color paper;

  /// Cards, list rows, input fields.
  final Color surface;

  /// The single accent: primary button, taken seats, active filter.
  final Color lime;

  /// Field borders, outlines, separators.
  final Color edge;

  /// Booking is active.
  final Color ok;

  /// Few seats left.
  final Color warn;

  /// Booking cancelled, no seats left.
  final Color stop;

  /// Text drawn on top of [lime] is always the brand dark, never white —
  /// in both brightnesses.
  static const Color onLime = Color(0xFF0E241C);

  static const AppColors light = AppColors(
    ink: Color(0xFF0E241C),
    moss: Color(0xFF5C7268),
    paper: Color(0xFFF1F4EE),
    surface: Color(0xFFFFFFFF),
    lime: Color(0xFFCBF25C),
    edge: Color(0xFFDFE4DA),
    ok: Color(0xFF1E7A5F),
    warn: Color(0xFFB5822A),
    stop: Color(0xFFB0463B),
  );

  /// Dark scheme: the brand dark becomes the background, [lime] stays the
  /// only accent. Secondary and status colours are lightened tints of the
  /// same hues, otherwise they would fall below the 4.5:1 contrast floor on
  /// the dark surfaces.
  static const AppColors dark = AppColors(
    ink: Color(0xFFEEF3EA),
    moss: Color(0xFF8FA79B),
    paper: Color(0xFF0A1A14),
    surface: Color(0xFF17302A),
    lime: Color(0xFFCBF25C),
    edge: Color(0xFF2B4840),
    ok: Color(0xFF4FC49E),
    warn: Color(0xFFE0AE52),
    stop: Color(0xFFE3796C),
  );

  @override
  AppColors copyWith({
    Color? ink,
    Color? moss,
    Color? paper,
    Color? surface,
    Color? lime,
    Color? edge,
    Color? ok,
    Color? warn,
    Color? stop,
  }) {
    return AppColors(
      ink: ink ?? this.ink,
      moss: moss ?? this.moss,
      paper: paper ?? this.paper,
      surface: surface ?? this.surface,
      lime: lime ?? this.lime,
      edge: edge ?? this.edge,
      ok: ok ?? this.ok,
      warn: warn ?? this.warn,
      stop: stop ?? this.stop,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      ink: Color.lerp(ink, other.ink, t)!,
      moss: Color.lerp(moss, other.moss, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      lime: Color.lerp(lime, other.lime, t)!,
      edge: Color.lerp(edge, other.edge, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      stop: Color.lerp(stop, other.stop, t)!,
    );
  }
}

/// Short access to the palette: `context.colors.lime`.
extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
