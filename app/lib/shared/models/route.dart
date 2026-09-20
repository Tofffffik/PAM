import 'booking.dart';

/// A trip published by a driver.
///
/// The number of free seats is deliberately absent from the fields: it is
/// derived from the active bookings of the route, never stored.
class Route {
  const Route({
    required this.id,
    required this.driverId,
    required this.fromCity,
    required this.toCity,
    required this.departureAt,
    required this.seatsTotal,
    required this.price,
  });

  final String id;
  final String driverId;
  final String fromCity;
  final String toCity;
  final DateTime departureAt;
  final int seatsTotal;
  final double price;

  /// `seatsTotal` minus the seats held by the active bookings of this route.
  /// Cancelled bookings return their seats to the pool.
  int freeSeats(Iterable<Booking> bookings) {
    int taken = 0;
    for (final Booking booking in bookings) {
      if (booking.routeId == id && booking.isActive) {
        taken += booking.seats;
      }
    }
    final int free = seatsTotal - taken;
    return free < 0 ? 0 : free;
  }
}
