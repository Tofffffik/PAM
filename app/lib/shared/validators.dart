/// Rules for every form field in the application. Each validator returns the
/// message shown under the field, or `null` when the value is accepted.
///
/// The functions are pure — no widgets, no context — so the same rules are
/// unit-tested here and reused unchanged by the backend contract at L5.
abstract final class Validators {
  static const int nameMin = 2;
  static const int nameMax = 50;
  static const int passwordMin = 8;
  static const int cityMin = 2;
  static const int cityMax = 40;
  static const int seatsMin = 1;
  static const int seatsMax = 12;
  static const double priceMax = 1000;

  /// How far ahead a route has to leave: a ride announced for the next
  /// fifteen minutes cannot realistically be booked.
  static const Duration departureLead = Duration(minutes: 15);

  /// Furthest a route can be published ahead.
  static const Duration departureHorizon = Duration(days: 60);

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final RegExp _personName = RegExp(
    r"^[\p{L}][\p{L} '\-]*$",
    unicode: true,
  );
  static final RegExp _cityName = RegExp(
    r"^[\p{L}][\p{L} .'\-]*$",
    unicode: true,
  );
  static final RegExp _letter = RegExp(r'\p{L}', unicode: true);
  static final RegExp _digit = RegExp(r'\d');
  static final RegExp _priceFormat = RegExp(r'^\d+([.,]\d{1,2})?$');

  static String? name(String? value) {
    final String text = _trim(value);
    if (text.isEmpty) return 'Введите имя';
    if (text.length < nameMin) return 'Имя слишком короткое';
    if (text.length > nameMax) return 'Не длиннее $nameMax символов';
    if (!_personName.hasMatch(text)) {
      return 'Только буквы, пробел, дефис и апостроф';
    }
    return null;
  }

  static String? email(String? value) {
    final String text = _trim(value);
    if (text.isEmpty) return 'Введите почту';
    if (!_email.hasMatch(text)) return 'Почта в формате name@student.utm.md';
    return null;
  }

  /// Signing in only checks the password is there: the rules for a new
  /// password must not lock out an account made under older ones.
  static String? passwordPresent(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    return null;
  }

  static String? newPassword(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return 'Введите пароль';
    if (text.length < passwordMin) {
      return 'Не короче $passwordMin символов';
    }
    if (!_letter.hasMatch(text) || !_digit.hasMatch(text)) {
      return 'Нужны хотя бы одна буква и одна цифра';
    }
    return null;
  }

  static String? city(String? value) {
    final String text = _trim(value);
    if (text.isEmpty) return 'Укажите город';
    if (text.length < cityMin) return 'Название слишком короткое';
    if (text.length > cityMax) return 'Не длиннее $cityMax символов';
    if (!_cityName.hasMatch(text)) return 'Только буквы, пробел и дефис';
    return null;
  }

  /// Both cities on their own, then the pair: a route cannot end where it
  /// starts.
  static String? cityPair(String? from, String? to) {
    final String? fromError = city(from);
    if (fromError != null) return 'Откуда: ${_lower(fromError)}';
    final String? toError = city(to);
    if (toError != null) return 'Куда: ${_lower(toError)}';
    if (_trim(from).toLowerCase() == _trim(to).toLowerCase()) {
      return 'Города отправления и прибытия совпадают';
    }
    return null;
  }

  static String? seats(String? value) {
    final String text = _trim(value);
    if (text.isEmpty) return 'Укажите число мест';
    final int? count = int.tryParse(text);
    if (count == null) return 'Целое число';
    if (count < seatsMin || count > seatsMax) {
      return 'От $seatsMin до $seatsMax';
    }
    return null;
  }

  static String? price(String? value) {
    final String text = _trim(value);
    if (text.isEmpty) return 'Укажите цену';
    if (!_priceFormat.hasMatch(text)) {
      return 'Число, до двух знаков после запятой';
    }
    final double amount = parsePrice(text)!;
    if (amount <= 0) return 'Цена больше нуля';
    if (amount > priceMax) return 'Не больше ${priceMax.round()} L';
    return null;
  }

  /// [departure] is the date and time picked together; [now] is injected so
  /// the rule is testable.
  static String? departure(DateTime? departure, {DateTime? now}) {
    if (departure == null) return 'Выберите дату и время';
    final DateTime reference = now ?? DateTime.now();
    if (departure.isBefore(reference.add(departureLead))) {
      return 'Выезд не раньше чем через ${departureLead.inMinutes} минут';
    }
    if (departure.isAfter(reference.add(departureHorizon))) {
      return 'Не дальше чем на ${departureHorizon.inDays} дней вперёд';
    }
    return null;
  }

  /// `180`, `180.5` and `180,50` are all the same amount to the user.
  static double? parsePrice(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  static String _trim(String? value) => (value ?? '').trim();

  static String _lower(String message) {
    return message.isEmpty
        ? message
        : message[0].toLowerCase() + message.substring(1);
  }
}
