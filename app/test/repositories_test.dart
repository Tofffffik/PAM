import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:carpool/core/di/providers.dart';
import 'package:carpool/data/mock/mock_store.dart';
import 'package:carpool/data/repositories/booking_repository.dart';
import 'package:carpool/data/repositories/route_repository.dart';
import 'package:carpool/shared/demo_data.dart';
import 'package:carpool/shared/models/booking.dart';
import 'package:carpool/shared/state/catalog.dart';

/// A container whose mock repositories answer at once, as in the widget tests.
ProviderContainer _container() {
  final ProviderContainer container = ProviderContainer(
    overrides: [
      mockLatencyProvider.overrideWithValue(Duration.zero),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('booking repository', () {
    test('a booking takes seats from the route', () async {
      final BookingRepository repo =
          _container().read(bookingRepositoryProvider);

      // r4 has three seats and none taken (its only booking is cancelled).
      final Booking booking = await repo.book(
        routeId: 'r4',
        passengerId: demoCurrentUser.id,
        seats: 1,
      );

      expect(booking.routeId, 'r4');
      expect(booking.isActive, isTrue);
      expect(booking.passengerId, demoCurrentUser.id);
    });

    test('asking for more seats than are free is refused with the count',
        () async {
      final BookingRepository repo =
          _container().read(bookingRepositoryProvider);

      // r9 has two seats and one is taken: one is left.
      await expectLater(
        repo.book(routeId: 'r9', passengerId: demoCurrentUser.id, seats: 2),
        throwsA(
          isA<BookingRefused>()
              .having((BookingRefused e) => e.reason,
                  'reason', BookingRefusal.notEnoughSeats)
              .having((BookingRefused e) => e.seatsLeft, 'seatsLeft', 1),
        ),
      );
    });

    test('the driver cannot book their own route', () async {
      final BookingRepository repo =
          _container().read(bookingRepositoryProvider);

      await expectLater(
        repo.book(routeId: 'r5', passengerId: demoCurrentUser.id, seats: 1),
        throwsA(isA<BookingRefused>().having(
          (BookingRefused e) => e.reason,
          'reason',
          BookingRefusal.ownRoute,
        )),
      );
    });

    test('an unknown route is refused', () async {
      final BookingRepository repo =
          _container().read(bookingRepositoryProvider);

      await expectLater(
        repo.book(routeId: 'nope', passengerId: demoCurrentUser.id, seats: 1),
        throwsA(isA<BookingRefused>().having(
          (BookingRefused e) => e.reason,
          'reason',
          BookingRefusal.routeNotFound,
        )),
      );
    });

    test('cancelling keeps the record and returns the seats', () async {
      final ProviderContainer container = _container();
      final BookingRepository repo = container.read(bookingRepositoryProvider);

      // b1 holds one seat on r1.
      final Booking cancelled = await repo.cancel('b1');

      expect(cancelled.status, BookingStatus.cancelled);
      final List<Booking> all = await repo.fetchBookings();
      expect(all.where((Booking b) => b.id == 'b1'), hasLength(1));
    });
  });

  group('route repository', () {
    test('a published route gets an id and joins the list', () async {
      final ProviderContainer container = _container();
      final RouteRepository repo = container.read(routeRepositoryProvider);
      final int before = (await repo.fetchRoutes()).length;

      final route = await repo.publish(
        RouteDraft(
          driverId: demoCurrentUser.id,
          fromCity: 'Кишинёв',
          toCity: 'Бэлць',
          departureAt: DateTime(2030, 1, 1, 9),
          seatsTotal: 3,
          price: 150,
        ),
      );

      expect(route.id, isNotEmpty);
      expect((await repo.fetchRoutes()).length, before + 1);
      expect(await repo.findRoute(route.id), isNotNull);
    });

    test('a draft outside the rules is rejected', () async {
      final RouteRepository repo =
          _container().read(routeRepositoryProvider);

      await expectLater(
        repo.publish(
          RouteDraft(
            driverId: demoCurrentUser.id,
            fromCity: 'Кишинёв',
            toCity: 'Бэлць',
            departureAt: DateTime(2030, 1, 1, 9),
            seatsTotal: 20,
            price: 150,
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('state', () {
    test('a booking changes the free seats seen by the board', () async {
      final ProviderContainer container = _container();

      final RouteBoard before =
          await container.read(routeBoardProvider.future);
      expect(before.freeSeats(before.routeById('r2')!), 0);
      expect(before.freeSeats(before.routeById('r1')!), 2);

      await container.read(bookingsProvider.notifier).book(
            routeId: 'r1',
            passengerId: demoCurrentUser.id,
            seats: 1,
          );

      final RouteBoard after = await container.read(routeBoardProvider.future);
      expect(after.freeSeats(after.routeById('r1')!), 1);
    });

    test('the booking rule refuses the own and the sold-out route', () async {
      final RouteBoard board = await _container()
          .read(routeBoardProvider.future);

      expect(
        bookingBlockFor(
          route: board.routeById('r5')!,
          bookings: board.bookings,
          userId: demoCurrentUser.id,
        ),
        BookingBlock.ownRoute,
      );
      expect(
        bookingBlockFor(
          route: board.routeById('r2')!,
          bookings: board.bookings,
          userId: demoCurrentUser.id,
        ),
        BookingBlock.soldOut,
      );
      expect(
        bookingBlockFor(
          route: board.routeById('r1')!,
          bookings: board.bookings,
          userId: demoCurrentUser.id,
        ),
        isNull,
      );
    });

    test('a cancelled booking leaves the user\'s active bookings', () async {
      final ProviderContainer container = _container();
      final RouteBoard before =
          await container.read(routeBoardProvider.future);
      final List<Booking> mine = activeBookingsOn(
        routeId: 'r1',
        bookings: before.bookings,
        userId: demoCurrentUser.id,
      );
      expect(mine.map((Booking b) => b.id), <String>['b1']);
      // r4 holds only a cancelled booking of the user.
      expect(
        activeBookingsOn(
          routeId: 'r4',
          bookings: before.bookings,
          userId: demoCurrentUser.id,
        ),
        isEmpty,
      );

      await container.read(bookingsProvider.notifier).cancel('b1');

      final RouteBoard after = await container.read(routeBoardProvider.future);
      expect(
        activeBookingsOn(
          routeId: 'r1',
          bookings: after.bookings,
          userId: demoCurrentUser.id,
        ),
        isEmpty,
      );
      expect(after.freeSeats(after.routeById('r1')!), 3);
    });
  });

  group('mock store', () {
    test('ids do not clash with the seed data', () {
      final MockStore store = MockStore();
      final String id = store.nextId('r');

      expect(demoRoutes.any((route) => route.id == id), isFalse);
    });
  });
}
