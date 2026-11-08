import '../../data/repositories/route_repository.dart';
import '../../shared/models/route.dart' as model;
import '../../shared/validators.dart';
import 'mock_store.dart';

class MockRouteRepository implements RouteRepository {
  const MockRouteRepository(this._store, {required this.latency});

  final MockStore _store;
  final Duration latency;

  @override
  Future<List<model.Route>> fetchRoutes() async {
    await pause(latency);
    return List<model.Route>.of(_store.routes);
  }

  @override
  Future<model.Route?> findRoute(String id) async {
    await pause(latency);
    for (final model.Route route in _store.routes) {
      if (route.id == id) return route;
    }
    return null;
  }

  @override
  Future<model.Route> publish(RouteDraft draft) async {
    await pause(latency);
    if (draft.seatsTotal < Validators.seatsMin ||
        draft.seatsTotal > Validators.seatsMax) {
      throw ArgumentError.value(draft.seatsTotal, 'seatsTotal');
    }
    if (draft.price <= 0 || draft.price > Validators.priceMax) {
      throw ArgumentError.value(draft.price, 'price');
    }
    final model.Route route = model.Route(
      id: _store.nextId('r'),
      driverId: draft.driverId,
      fromCity: draft.fromCity,
      toCity: draft.toCity,
      departureAt: draft.departureAt,
      seatsTotal: draft.seatsTotal,
      price: draft.price,
    );
    _store.routes.add(route);
    return route;
  }
}
