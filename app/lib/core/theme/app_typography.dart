import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale of the visual system.
///
/// Two families only: Unbounded carries times, prices and large numbers and is
/// never used below 18px; Golos Text carries everything else. The numeric
/// styles enable tabular figures so that times and prices line up in a column.
///
/// If Unbounded ever turns out too heavy on Cyrillic strings, it is swapped
/// for Golos Text 700 with −1.0 tracking inside this file alone — nothing else
/// in the system depends on the family choice.
abstract final class AppTypography {
  static const List<FontFeature> _tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  /// Departure time in a route row.
  static TextStyle get timeHero => GoogleFonts.unbounded(
        fontSize: 34,
        height: 36 / 34,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        fontFeatures: _tabular,
      );

  /// Departure time on the route details screen.
  static TextStyle get timeXL => GoogleFonts.unbounded(
        fontSize: 52,
        height: 54 / 52,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.0,
        fontFeatures: _tabular,
      );

  /// Price per seat.
  static TextStyle get price => GoogleFonts.unbounded(
        fontSize: 20,
        height: 24 / 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        fontFeatures: _tabular,
      );

  /// Screen title.
  static TextStyle get title => GoogleFonts.golosText(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      );

  /// Cities in a route row.
  static TextStyle get city => GoogleFonts.golosText(
        fontSize: 17,
        height: 22 / 17,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      );

  /// Body copy.
  static TextStyle get body => GoogleFonts.golosText(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      );

  /// Dates, labels, secondary information.
  static TextStyle get caption => GoogleFonts.golosText(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      );

  /// Button label.
  static TextStyle get button => GoogleFonts.golosText(
        fontSize: 16,
        height: 20 / 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  /// The scale assembled for [ThemeData]. Only the slots the application
  /// actually uses are filled; the rest inherit from [body].
  static TextTheme textTheme(Color primary) {
    return TextTheme(
      displayLarge: timeXL,
      headlineLarge: timeHero,
      titleLarge: title,
      titleMedium: price,
      titleSmall: city,
      bodyMedium: body,
      bodySmall: caption,
      labelLarge: button,
    ).apply(bodyColor: primary, displayColor: primary);
  }
}
