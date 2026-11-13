import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:carpool/core/di/providers.dart';
import 'package:carpool/core/router/app_router.dart';
import 'package:carpool/core/router/app_routes.dart';
import 'package:carpool/data/mock/mock_route_repository.dart';
import 'package:carpool/data/repositories/route_repository.dart';
import 'package:carpool/features/auth/domain/session_controller.dart';
import 'package:carpool/main.dart';
import 'package:carpool/shared/demo_data.dart';
import 'package:carpool/shared/models/route.dart' as model;
import 'package:carpool/shared/models/user.dart';
import 'package:carpool/shared/widgets/app_text_field.dart';

/// Builds the application on a phone-sized surface with the mock repositories
/// answering at once, and lets the router settle on its first page.
Future<void> _pumpApp(
  WidgetTester tester, {
  User? signedIn,
  String? initialLocation,
  List<Override> overrides = const <Override>[],
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      // Riverpod retries a failed load by itself; the tests check the
      // screens' own reaction, so a failure stays a failure here.
      retry: (int retryCount, Object error) => null,
      overrides: [
        mockLatencyProvider.overrideWithValue(Duration.zero),
        sessionProvider.overrideWith(() => SessionController(signedIn)),
        initialLocationProvider.overrideWithValue(initialLocation),
        ...overrides,
      ],
      child: const CarPoolApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// The signed-in user as the session holds it right now.
User? _session(WidgetTester tester) {
  return ProviderScope.containerOf(tester.element(find.byType(CarPoolApp)))
      .read(sessionProvider);
}

/// Opens [location] the way a tap on a link would.
Future<void> _go(WidgetTester tester, String location) async {
  ProviderScope.containerOf(tester.element(find.byType(CarPoolApp)))
      .read(routerProvider)
      .go(location);
  await tester.pumpAndSettle();
}

/// The mock routes, except that the first request fails as a dropped network
/// would. Everything after it is answered normally.
class _FailingOnce implements RouteRepository {
  _FailingOnce(this._inner);

  final RouteRepository _inner;
  int fetches = 0;

  @override
  Future<List<model.Route>> fetchRoutes() async {
    fetches += 1;
    if (fetches == 1) throw Exception('no connection');
    return _inner.fetchRoutes();
  }

  @override
  Future<model.Route?> findRoute(String id) => _inner.findRoute(id);

  @override
  Future<model.Route> publish(RouteDraft draft) => _inner.publish(draft);
}

Finder _field(String key) => find.descendant(
      of: find.byKey(ValueKey<String>(key)),
      matching: find.byType(EditableText),
    );

void main() {
  setUpAll(() async {
    Intl.defaultLocale = 'ru';
    await initializeDateFormatting('ru');
  });

  group('auth guard', () {
    testWidgets('a signed-out user lands on the sign-in screen',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      expect(find.text('CarPool'), findsOneWidget);
      expect(find.text('Войти'), findsOneWidget);
    });

    testWidgets('empty sign-in shows the field errors and stays put',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();

      expect(find.text('Введите почту'), findsOneWidget);
      expect(find.text('Введите пароль'), findsOneWidget);
      expect(_session(tester), isNull);
    });

    testWidgets('a fixed field loses its error as it is typed into',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();
      await tester.enterText(_field('auth-email'), 'name@student.utm.md');
      await tester.pumpAndSettle();

      expect(find.text('Введите почту'), findsNothing);
      expect(find.text('Введите пароль'), findsOneWidget);
    });

    testWidgets('valid credentials open the search',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      await tester.enterText(_field('auth-email'), 'name@student.utm.md');
      await tester.enterText(_field('auth-password'), 'secret');
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();

      expect(_session(tester)?.email, 'name@student.utm.md');
      expect(find.text('Поиск'), findsWidgets);
    });

    testWidgets('sign-up checks the name and the password strength',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      await tester.tap(find.text('Регистрация'));
      await tester.pumpAndSettle();
      await tester.enterText(_field('auth-email'), 'name@student.utm.md');
      await tester.enterText(_field('auth-password'), 'short');
      await tester.tap(find.text('Создать аккаунт'));
      await tester.pumpAndSettle();

      expect(find.text('Введите имя'), findsOneWidget);
      expect(find.text('Не короче 8 символов'), findsOneWidget);
    });

    testWidgets('a link opened signed out comes back after sign-in',
        (WidgetTester tester) async {
      await _pumpApp(tester, initialLocation: '/routes/r1');

      expect(find.text('Войти'), findsOneWidget);

      await tester.enterText(_field('auth-email'), 'name@student.utm.md');
      await tester.enterText(_field('auth-password'), 'secret');
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();

      expect(find.text('Маршрут'), findsOneWidget);
      expect(find.text('Забронировать место'), findsOneWidget);
    });

    testWidgets('signing out returns to the sign-in screen',
        (WidgetTester tester) async {
      await _pumpApp(tester, signedIn: demoCurrentUser);

      await tester.tap(find.text('Профиль'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Выйти'));
      await tester.pumpAndSettle();

      expect(_session(tester), isNull);
      expect(find.text('Войти'), findsOneWidget);
    });
  });

  group('navigation', () {
    testWidgets('search → route → booking → back', (WidgetTester tester) async {
      await _pumpApp(tester, signedIn: demoCurrentUser);

      await tester.tap(find.text('Кишинёв → Бэлць').first);
      await tester.pumpAndSettle();
      expect(find.text('Маршрут'), findsOneWidget);

      await tester.tap(find.text('Забронировать место'));
      await tester.pumpAndSettle();
      expect(find.text('Бронирование'), findsOneWidget);

      await tester.tap(find.text('Забронировать место'));
      await tester.pumpAndSettle();
      expect(find.text('Место забронировано'), findsOneWidget);

      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();
      expect(find.text('Маршрут'), findsOneWidget);
    });

    testWidgets('the bottom navigation switches sections',
        (WidgetTester tester) async {
      await _pumpApp(tester, signedIn: demoCurrentUser);

      await tester.tap(find.text('Поездки'));
      await tester.pumpAndSettle();
      expect(find.text('Мои поездки'), findsOneWidget);

      await tester.tap(find.text('Профиль'));
      await tester.pumpAndSettle();
      expect(find.text(demoCurrentUser.email), findsOneWidget);
    });

    testWidgets('a sold-out route cannot be booked, even by link',
        (WidgetTester tester) async {
      await _pumpApp(
        tester,
        signedIn: demoCurrentUser,
        initialLocation: '/routes/r2/book',
      );

      // The booking screen sends the link back to the route itself.
      expect(find.text('Бронирование'), findsNothing);
      expect(find.text('Маршрут'), findsOneWidget);
    });

    testWidgets('the driver cannot book their own route',
        (WidgetTester tester) async {
      await _pumpApp(
        tester,
        signedIn: demoCurrentUser,
        initialLocation: '/routes/r5',
      );

      expect(
        find.text('Это ваш маршрут: бронируют его попутчики.'),
        findsOneWidget,
      );
    });

    testWidgets('an unknown route id shows «not found»',
        (WidgetTester tester) async {
      await _pumpApp(
        tester,
        signedIn: demoCurrentUser,
        initialLocation: '/routes/nope',
      );

      expect(
        find.text('Маршрут не найден. Возможно, водитель его отменил.'),
        findsOneWidget,
      );
    });

    testWidgets('an unknown path shows «not found»',
        (WidgetTester tester) async {
      await _pumpApp(
        tester,
        signedIn: demoCurrentUser,
        initialLocation: '/nowhere',
      );

      expect(
        find.text('Такой страницы нет. Вернитесь к поиску рейсов.'),
        findsOneWidget,
      );
    });
  });

  group('search', () {
    testWidgets('the chip «Завтра» changes the day of the search',
        (WidgetTester tester) async {
      await _pumpApp(tester, signedIn: demoCurrentUser);

      // Today from Chișinău to Bălți: r1 departs.
      expect(find.text('Кишинёв → Бэлць'), findsOneWidget);

      await tester.tap(find.text('Завтра'));
      await tester.pumpAndSettle();

      // Tomorrow there is no such route (r7 is the day after).
      expect(find.text('Кишинёв → Бэлць'), findsNothing);
    });

    testWidgets('a booking lowers the free seats shown on the route',
        (WidgetTester tester) async {
      await _pumpApp(tester, signedIn: demoCurrentUser);

      await tester.tap(find.text('Кишинёв → Бэлць').first);
      await tester.pumpAndSettle();
      expect(find.text('Свободно только 2 места.'), findsOneWidget);

      await tester.tap(find.text('Забронировать место'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Забронировать место'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Готово'));
      await tester.pumpAndSettle();

      expect(find.text('Свободно только 1 место.'), findsOneWidget);
    });
  });

  group('publish form', () {
    Future<void> openForm(WidgetTester tester) async {
      await _pumpApp(tester, signedIn: demoCurrentUser, initialLocation: '/trips');
      // The button sits under both lists, below the first screen.
      await tester.scrollUntilVisible(
        find.text('Опубликовать маршрут'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Опубликовать маршрут'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Опубликовать маршрут'));
      await tester.pumpAndSettle();
    }

    testWidgets('empty cities and bad numbers are reported',
        (WidgetTester tester) async {
      await openForm(tester);

      await tester.enterText(_field('publish-seats'), '20');
      await tester.enterText(_field('publish-price'), '0');
      await tester.tap(find.text('Опубликовать маршрут'));
      await tester.pumpAndSettle();

      expect(find.text('Откуда: укажите город'), findsOneWidget);
      expect(find.text('От 1 до 12'), findsOneWidget);
      expect(find.text('Цена больше нуля'), findsOneWidget);
    });

    testWidgets('seats accept digits only', (WidgetTester tester) async {
      await openForm(tester);

      await tester.enterText(_field('publish-seats'), '4a');
      await tester.pump();

      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('a valid route is published and the form closes',
        (WidgetTester tester) async {
      await openForm(tester);

      final Finder cities = find.descendant(
        of: find.byType(CityPairField),
        matching: find.byType(EditableText),
      );
      await tester.enterText(cities.at(0), 'Кишинёв');
      await tester.enterText(cities.at(1), 'Бэлць');
      await tester.tap(find.text('Опубликовать маршрут'));
      await tester.pumpAndSettle();

      expect(find.text('Маршрут опубликован'), findsOneWidget);
      expect(find.text('Новый маршрут'), findsNothing);
    });

    // `pageBack` looks for the English «Back» tooltip; the application is
    // in Russian, so the back button is tapped by type.
    testWidgets('leaving a touched form asks first',
        (WidgetTester tester) async {
      await openForm(tester);

      await tester.enterText(_field('publish-seats'), '2');
      await tester.pump();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Не публиковать маршрут?'), findsOneWidget);

      await tester.tap(find.text('Остаться'));
      await tester.pumpAndSettle();
      expect(find.text('Новый маршрут'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Выйти'));
      await tester.pumpAndSettle();
      expect(find.text('Новый маршрут'), findsNothing);
    });
  });

  group('state', () {
    testWidgets('cancelling a booking returns the seat everywhere',
        (WidgetTester tester) async {
      // r1: four seats, the user holds one, another passenger one.
      await _pumpApp(
        tester,
        signedIn: demoCurrentUser,
        initialLocation: AppRoutes.route('r1'),
      );
      expect(find.text('Ваша бронь'), findsOneWidget);
      expect(find.text('Свободно только 2 места.'), findsOneWidget);

      await tester.tap(find.text('Отменить бронь'));
      await tester.pumpAndSettle();
      expect(
        find.text('Отменить бронь? Места вернутся в продажу.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Отменить бронь').last);
      await tester.pumpAndSettle();

      expect(find.text('Бронь отменена'), findsOneWidget);
      expect(find.text('Ваша бронь'), findsNothing);
      expect(find.text('Свободно только 2 места.'), findsNothing);
      expect(find.text('3 свободно'), findsOneWidget);

      // The record stays and is shown as cancelled: r4 was already, now r1.
      await _go(tester, AppRoutes.trips);
      expect(find.text('Отменена'), findsNWidgets(2));
    });

    testWidgets('«Оставить» keeps the booking', (WidgetTester tester) async {
      await _pumpApp(
        tester,
        signedIn: demoCurrentUser,
        initialLocation: AppRoutes.route('r1'),
      );

      await tester.tap(find.text('Отменить бронь'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Оставить'));
      await tester.pumpAndSettle();

      expect(find.text('Ваша бронь'), findsOneWidget);
      expect(find.text('Свободно только 2 места.'), findsOneWidget);
    });

    testWidgets('a failed load offers to try again',
        (WidgetTester tester) async {
      late _FailingOnce routes;
      await _pumpApp(
        tester,
        signedIn: demoCurrentUser,
        overrides: <Override>[
          routeRepositoryProvider.overrideWith((Ref ref) {
            return routes = _FailingOnce(
              MockRouteRepository(
                ref.watch(mockStoreProvider),
                latency: Duration.zero,
              ),
            );
          }),
        ],
      );
      expect(
        find.text(
          'Не удалось загрузить рейсы. Проверьте соединение и повторите.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Повторить'));
      await tester.pumpAndSettle();

      expect(routes.fetches, 2);
      expect(find.text('Повторить'), findsNothing);
      expect(find.text('17:40'), findsOneWidget);
    });

    testWidgets('booking several seats says how many',
        (WidgetTester tester) async {
      // r7: five seats, three free.
      await _pumpApp(
        tester,
        signedIn: demoCurrentUser,
        initialLocation: AppRoutes.booking('r7'),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.text('Забронировать 2 места'));
      await tester.pumpAndSettle();

      expect(find.text('Забронировано 2 места'), findsOneWidget);
    });

    testWidgets('a new user sees both empty sections of «Мои поездки»',
        (WidgetTester tester) async {
      await _pumpApp(
        tester,
        signedIn: const User(
          id: 'u-new',
          name: 'Ион Попа',
          email: 'ion.popa@student.utm.md',
        ),
        initialLocation: AppRoutes.trips,
      );

      expect(
        find.text(
          'Вы ещё не бронировали поездки. Найдите рейс на нужную дату.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Вы ещё не публиковали маршруты. '
          'Опубликуйте первый — его увидят попутчики.',
        ),
        findsOneWidget,
      );
    });
  });
}
