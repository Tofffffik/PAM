import '../../data/repositories/booking_repository.dart';
import '../../shared/models/booking.dart';
import '../../shared/models/route.dart' as model;
import '../../shared/validators.dart';
import 'mock_store.dart';

class MockBookingRepository implements BookingRepository {
  const MockBookingRepository(this._store, {required this.latency});

  final MockStore _store;
  final Duration latency;

  @override
  Future<List<Booking>> fetchBookings() async {
    await pause(latency);
    return List<Booking>.of(_store.bookings);
  }

  @override
  Future<Booking> book({
    required String routeId,
    required String passengerId,
    required int seats,
  }) async {
    await pause(latency);
    if (seats < Validators.seatsMin || seats > Validators.seatsMax) {
      throw const BookingRefused(BookingRefusal.invalidSeats);
    }
    final model.Route? route = _findRoute(routeId);
    if (route == null) {
      throw const BookingRefused(BookingRefusal.routeNotFound);
    }
    if (route.driverId == passengerId) {
      throw const BookingRefused(BookingRefusal.ownRoute);
    }
    final int free = route.freeSeats(_store.bookings);
    if (seats > free) {
      throw BookingRefused(BookingRefusal.notEnoughSeats, seatsLeft: free);
    }
    final Booking booking = Booking(
      id: _store.nextId('b'),
      routeId: routeId,
      passengerId: passengerId,
      seats: seats,
      status: BookingStatus.active,
      createdAt: DateTime.now(),
    );
    _store.bookings.add(booking);
    return booking;
  }

  @override
  Future<Booking> cancel(String bookingId) async {
    await pause(latency);
    final int index =
        _store.bookings.indexWhere((Booking b) => b.id == bookingId);
    if (index == -1) {
      throw ArgumentError.value(bookingId, 'bookingId', 'no such booking');
    }
    final Booking cancelled =
        _store.bookings[index].copyWith(status: BookingStatus.cancelled);
    _store.bookings[index] = cancelled;
    return cancelled;
  }

  model.Route? _findRoute(String id) {
    for (final model.Route route in _store.routes) {
      if (route.id == id) return route;
    }
    return null;
  }
}
