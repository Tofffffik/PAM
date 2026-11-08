import '../../shared/demo_data.dart';
import '../../shared/models/booking.dart';
import '../../shared/models/route.dart' as model;
import '../../shared/models/user.dart';

/// The in-memory "database" behind the mock repositories.
///
/// It is seeded from `demo_data.dart` and lives as long as its provider
/// container, so a booking made in one screen is visible in every other one,
/// and a fresh container (as in each test) starts from the seed again.
class MockStore {
  MockStore()
      : routes = List<model.Route>.of(demoRoutes),
        bookings = List<Booking>.of(demoBookings),
        users = List<User>.of(demoDrivers);

  final List<model.Route> routes;
  final List<Booking> bookings;
  final List<User> users;

  int _sequence = 100;

  /// A new id that does not clash with the seed ids (`r1`…`r10`, `b1`…`b11`).
  String nextId(String prefix) => '$prefix${++_sequence}';
}

/// Waits for [latency] to imitate a network call. Zero skips the wait, which
/// keeps tests free of pending timers.
Future<void> pause(Duration latency) {
  return latency == Duration.zero
      ? Future<void>.value()
      : Future<void>.delayed(latency);
}
