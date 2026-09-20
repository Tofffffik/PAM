/// Grid step is 4. Every gap in the application comes from this list.
abstract final class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal screen margin.
  static const double screen = 20;

  /// Gap between meaningful blocks.
  static const double block = 24;
}

/// Three radii for the whole application, no more.
abstract final class Radii {
  /// Cards and buttons.
  static const double card = 20;

  /// Input fields.
  static const double field = 16;

  /// Chips are fully rounded; large enough to act as a stadium.
  static const double chip = 999;
}

/// Fixed sizes named by the visual system.
abstract final class Sizes {
  /// Minimum height of a route row.
  static const double routeRow = 104;

  /// Minimum touch target.
  static const double tap = 48;

  /// Primary button and input field height.
  static const double control = 56;

  /// Seat pip diameter and the gap between pips.
  static const double pip = 12;
  static const double pipGap = 5;

  /// Outline width of a free seat pip.
  static const double pipStroke = 1.5;

  /// Radius of the perforation notch on the route details card.
  static const double notch = 8;

  /// Booking status dot.
  static const double statusDot = 6;

  /// Hairline used for borders and separators.
  static const double hairline = 1;

  /// Focused input field border.
  static const double focusLine = 1.5;
}
