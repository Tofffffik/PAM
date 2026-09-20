/// State of a booking. Cancelling a booking switches the status; the record
/// itself is never deleted.
enum BookingStatus { active, cancelled }

/// A seat reservation made by a passenger on a route.
class Booking {
  const Booking({
    required this.id,
    required this.routeId,
    required this.passengerId,
    required this.seats,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String routeId;
  final String passengerId;
  final int seats;
  final BookingStatus status;
  final DateTime createdAt;

  bool get isActive => status == BookingStatus.active;
}
