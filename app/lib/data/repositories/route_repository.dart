import '../../shared/models/route.dart' as model;

/// What a driver enters on the publishing form, before the repository gives
/// the route its id.
class RouteDraft {
  const RouteDraft({
    required this.driverId,
    required this.fromCity,
    required this.toCity,
    required this.departureAt,
    required this.seatsTotal,
    required this.price,
  });

  final String driverId;
  final String fromCity;
  final String toCity;
  final DateTime departureAt;
  final int seatsTotal;
  final double price;
}

/// Published routes. Free seats are not stored here: they are derived from the
/// bookings, see `Route.freeSeats`.
abstract interface class RouteRepository {
  Future<List<model.Route>> fetchRoutes();

  /// The route with [id], or `null` when it does not exist.
  Future<model.Route?> findRoute(String id);

  /// Stores a new route and returns it with its id.
  ///
  /// Throws [ArgumentError] when the draft breaks a rule of the domain: seats
  /// from 1 to 12, a positive price.
  Future<model.Route> publish(RouteDraft draft);
}
