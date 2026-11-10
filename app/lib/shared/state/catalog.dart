import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/repositories/route_repository.dart';
import '../models/booking.dart';
import '../models/route.dart' as model;
import '../models/user.dart';

/// The published routes. Publishing a route reloads the list.
class RoutesController extends AsyncNotifier<List<model.Route>> {
  @override
  Future<List<model.Route>> build() {
    return ref.watch(routeRepositoryProvider).fetchRoutes();
  }

  Future<model.Route> publish(RouteDraft draft) async {
    final model.Route route =
        await ref.read(routeRepositoryProvider).publish(draft);
    ref.invalidateSelf();
    await future;
    return route;
  }
}

final AsyncNotifierProvider<RoutesController, List<model.Route>>
    routesProvider =
    AsyncNotifierProvider<RoutesController, List<model.Route>>(
  RoutesController.new,
);

/// Every booking in the system. Booking or cancelling reloads the list, and
/// with it the free seats of every route.
class BookingsController extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() {
    return ref.watch(bookingRepositoryProvider).fetchBookings();
  }

  Future<Booking> book({
    required String routeId,
    required String passengerId,
    required int seats,
  }) async {
    final Booking booking =
        await ref.read(bookingRepositoryProvider).book(
              routeId: routeId,
              passengerId: passengerId,
              seats: seats,
            );
    ref.invalidateSelf();
    await future;
    return booking;
  }

  Future<Booking> cancel(String bookingId) async {
    final Booking booking =
        await ref.read(bookingRepositoryProvider).cancel(bookingId);
    ref.invalidateSelf();
    await future;
    return booking;
  }
}

final AsyncNotifierProvider<BookingsController, List<Booking>>
    bookingsProvider =
    AsyncNotifierProvider<BookingsController, List<Booking>>(
  BookingsController.new,
);

/// Routes and bookings together: everything a screen needs to show seats.
class RouteBoard {
  const RouteBoard({required this.routes, required this.bookings});

  final List<model.Route> routes;
  final List<Booking> bookings;

  model.Route? routeById(String id) {
    for (final model.Route route in routes) {
      if (route.id == id) return route;
    }
    return null;
  }

  int freeSeats(model.Route route) => route.freeSeats(bookings);
}

final FutureProvider<RouteBoard> routeBoardProvider =
    FutureProvider<RouteBoard>((Ref ref) async {
  final List<model.Route> routes =
      await ref.watch(routesProvider.future);
  final List<Booking> bookings =
      await ref.watch(bookingsProvider.future);
  return RouteBoard(routes: routes, bookings: bookings);
});

/// Loads the routes and the bookings again, after a failed attempt.
void reloadCatalog(WidgetRef ref) {
  ref.invalidate(routesProvider);
  ref.invalidate(bookingsProvider);
}

/// The active bookings [userId] holds on the route, oldest first. Cancelled
/// ones are left out: there is nothing more to do with them.
List<Booking> activeBookingsOn({
  required String routeId,
  required Iterable<Booking> bookings,
  required String? userId,
}) {
  return bookings
      .where(
        (Booking booking) =>
            booking.routeId == routeId &&
            booking.passengerId == userId &&
            booking.isActive,
      )
      .toList()
    ..sort((Booking a, Booking b) => a.createdAt.compareTo(b.createdAt));
}

/// The driver of a route. `null` when the user record is missing.
final driverProvider =
    FutureProvider.family<User?, String>(
  (Ref ref, String userId) =>
      ref.watch(userRepositoryProvider).userById(userId),
);

/// Why a user cannot book a route, or `null` when they can.
enum BookingBlock { ownRoute, soldOut }

/// The rule behind the booking button, the booking screen and the seat
/// counter. Kept in one place so the screens cannot disagree about it.
BookingBlock? bookingBlockFor({
  required model.Route route,
  required Iterable<Booking> bookings,
  required String? userId,
}) {
  if (route.driverId == userId) return BookingBlock.ownRoute;
  if (route.freeSeats(bookings) == 0) return BookingBlock.soldOut;
  return null;
}
