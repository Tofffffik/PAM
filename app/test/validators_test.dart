import 'package:flutter_test/flutter_test.dart';

import 'package:carpool/shared/validators.dart';

void main() {
  group('name', () {
    test('accepts Cyrillic, Latin, hyphen and apostrophe', () {
      expect(Validators.name('Андрей Мунтяну'), isNull);
      expect(Validators.name('Ana-Maria O\'Neil'), isNull);
      expect(Validators.name('  Ion  '), isNull);
    });

    test('rejects empty, short, long and non-letters', () {
      expect(Validators.name(''), 'Введите имя');
      expect(Validators.name('   '), 'Введите имя');
      expect(Validators.name(null), 'Введите имя');
      expect(Validators.name('А'), 'Имя слишком короткое');
      expect(Validators.name('a' * 51), 'Не длиннее 50 символов');
      expect(Validators.name('Andrei2'), isNotNull);
      expect(Validators.name('-Ion'), isNotNull);
    });
  });

  group('email', () {
    test('accepts a well-formed address', () {
      expect(Validators.email('name@student.utm.md'), isNull);
      expect(Validators.email(' a.b@gmail.com '), isNull);
    });

    test('rejects empty and malformed addresses', () {
      expect(Validators.email(''), 'Введите почту');
      expect(Validators.email('name'), isNotNull);
      expect(Validators.email('name@utm'), isNotNull);
      expect(Validators.email('na me@utm.md'), isNotNull);
      expect(Validators.email('@utm.md'), isNotNull);
    });
  });

  group('password', () {
    test('sign in only needs something typed', () {
      expect(Validators.passwordPresent(''), 'Введите пароль');
      expect(Validators.passwordPresent('1'), isNull);
    });

    test('a new password needs eight characters, a letter and a digit', () {
      expect(Validators.newPassword(''), 'Введите пароль');
      expect(Validators.newPassword('abc123'), 'Не короче 8 символов');
      expect(Validators.newPassword('abcdefgh'), isNotNull);
      expect(Validators.newPassword('12345678'), isNotNull);
      expect(Validators.newPassword('пароль12'), isNull);
      expect(Validators.newPassword('secret42'), isNull);
    });
  });

  group('cities', () {
    test('a single city', () {
      expect(Validators.city('Кишинёв'), isNull);
      expect(Validators.city('Ştefan Vodă'), isNull);
      expect(Validators.city(''), 'Укажите город');
      expect(Validators.city('К'), 'Название слишком короткое');
      expect(Validators.city('Бэлць 2'), isNotNull);
    });

    test('the pair names the failing half', () {
      expect(Validators.cityPair('', 'Бэлць'), startsWith('Откуда:'));
      expect(Validators.cityPair('Кишинёв', ''), startsWith('Куда:'));
    });

    test('the pair cannot be one city, whatever the case and spaces', () {
      expect(
        Validators.cityPair('Кишинёв', ' кишинёв '),
        'Города отправления и прибытия совпадают',
      );
      expect(Validators.cityPair('Кишинёв', 'Бэлць'), isNull);
    });
  });

  group('seats', () {
    test('a whole number from 1 to 12', () {
      expect(Validators.seats('1'), isNull);
      expect(Validators.seats('12'), isNull);
      expect(Validators.seats(''), 'Укажите число мест');
      expect(Validators.seats('0'), 'От 1 до 12');
      expect(Validators.seats('13'), 'От 1 до 12');
      expect(Validators.seats('2.5'), 'Целое число');
    });
  });

  group('price', () {
    test('accepts whole and fractional lei with either separator', () {
      expect(Validators.price('180'), isNull);
      expect(Validators.price('180.5'), isNull);
      expect(Validators.price('180,50'), isNull);
      expect(Validators.price('1000'), isNull);
    });

    test('rejects empty, zero, too much and malformed', () {
      expect(Validators.price(''), 'Укажите цену');
      expect(Validators.price('0'), 'Цена больше нуля');
      expect(Validators.price('1000.01'), 'Не больше 1000 L');
      expect(Validators.price('1.234'), isNotNull);
      expect(Validators.price('1,2,3'), isNotNull);
      expect(Validators.price('-5'), isNotNull);
    });

    test('parsePrice reads a comma as the decimal point', () {
      expect(Validators.parsePrice('180,5'), 180.5);
    });
  });

  group('departure', () {
    final DateTime now = DateTime(2026, 10, 16, 12, 0);

    test('must be picked', () {
      expect(Validators.departure(null, now: now), 'Выберите дату и время');
    });

    test('at least fifteen minutes ahead', () {
      expect(
        Validators.departure(DateTime(2026, 10, 16, 12, 10), now: now),
        isNotNull,
      );
      expect(
        Validators.departure(DateTime(2026, 10, 16, 11, 0), now: now),
        isNotNull,
      );
      expect(
        Validators.departure(DateTime(2026, 10, 16, 12, 15), now: now),
        isNull,
      );
    });

    test('no further than sixty days ahead', () {
      expect(
        Validators.departure(now.add(const Duration(days: 60)), now: now),
        isNull,
      );
      expect(
        Validators.departure(now.add(const Duration(days: 61)), now: now),
        isNotNull,
      );
    });
  });
}
