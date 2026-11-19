import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'spacing.dart';

/// Assembles [ThemeData] from the tokens.
///
/// The colour scheme is written out by hand: `ColorScheme.fromSeed` would
/// generate its own tints and the palette is fixed. Elevation is zero
/// everywhere — surfaces are separated by background density and 1px [edge]
/// outlines, never by shadows.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light, AppColors.light);

  static ThemeData get dark => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: colors.lime,
      onPrimary: AppColors.onLime,
      secondary: colors.ink,
      onSecondary: colors.paper,
      surface: colors.surface,
      onSurface: colors.ink,
      surfaceContainerLowest: colors.paper,
      surfaceContainer: colors.surface,
      onSurfaceVariant: colors.moss,
      outline: colors.edge,
      outlineVariant: colors.edge,
      error: colors.stop,
      onError: colors.surface,
    );

    final TextTheme textTheme = AppTypography.textTheme(colors.ink);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[colors],
      scaffoldBackgroundColor: colors.paper,
      canvasColor: colors.paper,
      textTheme: textTheme,
      shadowColor: Colors.transparent,
      splashFactory: InkRipple.splashFactory,
      dividerTheme: DividerThemeData(
        color: colors.edge,
        thickness: Sizes.hairline,
        space: Sizes.hairline,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.paper,
        foregroundColor: colors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      iconTheme: IconThemeData(color: colors.ink),
      // Confirmations after a form is sent: ink plate, paper text, floating
      // above the bottom navigation.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.ink,
        contentTextStyle: AppTypography.body.copyWith(color: colors.paper),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.field),
        ),
      ),
      // Text buttons of dialogs and pickers would take `primary` — lime on
      // white is unreadable, so they are ink like the rest of the text.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.ink,
          textStyle: AppTypography.button,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
        ),
        titleTextStyle: AppTypography.city.copyWith(color: colors.ink),
        contentTextStyle: AppTypography.body.copyWith(color: colors.moss),
      ),
      // The accent would vanish on the light paper: the spinner shown while
      // the repositories answer is drawn in ink, like the text around it.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.ink,
        circularTrackColor: colors.edge,
      ),
      // Focus has to stay visible for keyboard navigation.
      focusColor: colors.ink.withValues(alpha: 0.12),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.ink,
        selectionColor: colors.lime.withValues(alpha: 0.4),
        selectionHandleColor: colors.ink,
      ),
    );
  }
}
