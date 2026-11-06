import '../../shared/models/booking.dart';

/// Why a booking was refused. The screens turn each reason into a message.
enum BookingRefusal {
  /// The route does not exist.
  routeNotFound,

  /// The passenger drives this route.
  ownRoute,

  /// Fewer free seats than the passenger asked for.
  notEnoughSeats,

  /// Seats outside 1…12.
  invalidSeats,
}

class BookingRefused implements Exception {
  const BookingRefused(this.reason, {this.seatsLeft = 0});

  final BookingRefusal reason;

  /// Free seats at the moment of refusal, meaningful for [notEnoughSeats].
  final int seatsLeft;

  @override
  String toString() => 'BookingRefused($reason, seatsLeft: $seatsLeft)';
}

/// Seat reservations. A booking is checked against the free seats at the time
/// it is made, so two passengers cannot take the same last seat.
abstract interface class BookingRepository {
  Future<List<Booking>> fetchBookings();

  /// Reserves [seats] on the route for [passengerId].
  ///
  /// Throws [BookingRefused] when the booking breaks a rule of the domain.
  Future<Booking> book({
    required String routeId,
    required String passengerId,
    required int seats,
  });

  /// Marks a booking as cancelled. The seats go back to the route; the record
  /// stays. Cancelling an already cancelled booking changes nothing.
  Future<Booking> cancel(String bookingId);
}
