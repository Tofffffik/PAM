import 'package:intl/intl.dart';

/// Russian formatting of the values the interface shows. Kept in one place so
/// that a date reads the same on every screen.
abstract final class Formatting {
  static const String _locale = 'ru';

  /// `17:40`
  static String time(DateTime value) => DateFormat.Hm(_locale).format(value);

  /// `пт, 24 окт` — the short date under the departure time.
  static String dayShort(DateTime value) {
    return _trimDots(DateFormat('EEE, d MMM', _locale).format(value));
  }

  /// `пятница, 24 октября` — the date on the route details card.
  static String dayLong(DateTime value) {
    return _trimDots(DateFormat('EEEE, d MMMM', _locale).format(value));
  }

  /// `24.10.2025` — the value shown in a date input field.
  static String dateField(DateTime value) =>
      DateFormat('dd.MM.yyyy', _locale).format(value);

  /// `180 L` — prices in the demo set are whole lei, so the fraction is only
  /// printed when there is one.
  static String price(double value) {
    final NumberFormat format = value == value.roundToDouble()
        ? NumberFormat('#,##0', _locale)
        : NumberFormat('#,##0.00', _locale);
    return '${format.format(value)} L';
  }

  /// `2 места` — the seat count with the right Russian form.
  static String seats(int count) => '$count ${seatsWord(count)}';

  /// The declension of «место» for [count].
  static String seatsWord(int count) {
    final int tail = count % 100;
    if (tail >= 11 && tail <= 14) return 'мест';
    switch (count % 10) {
      case 1:
        return 'место';
      case 2:
      case 3:
      case 4:
        return 'места';
      default:
        return 'мест';
    }
  }

  /// Russian month and weekday abbreviations carry a trailing dot; the visual
  /// system writes them without one.
  static String _trimDots(String value) => value.replaceAll('.', '');
}
