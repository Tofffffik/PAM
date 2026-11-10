import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_auth_repository.dart';
import '../../data/mock/mock_booking_repository.dart';
import '../../data/mock/mock_route_repository.dart';
import '../../data/mock/mock_store.dart';
import '../../data/mock/mock_user_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/route_repository.dart';
import '../../data/repositories/user_repository.dart';

/// Wiring of the application's dependencies.
///
/// Screens and notifiers ask for the repository interfaces only. Swapping the
/// mock implementations for the backend at L5 means changing the bodies of the
/// providers in this file and nothing else.

/// How long a mock call takes, imitating the network. Tests override it with
/// `Duration.zero`.
final Provider<Duration> mockLatencyProvider = Provider<Duration>(
  (Ref ref) => const Duration(milliseconds: 350),
);

/// The mock database. One per provider container.
final Provider<MockStore> mockStoreProvider = Provider<MockStore>(
  (Ref ref) => MockStore(),
);

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
  (Ref ref) => MockAuthRepository(latency: ref.watch(mockLatencyProvider)),
);

final Provider<UserRepository> userRepositoryProvider =
    Provider<UserRepository>(
  (Ref ref) => MockUserRepository(
    ref.watch(mockStoreProvider),
    latency: ref.watch(mockLatencyProvider),
  ),
);

final Provider<RouteRepository> routeRepositoryProvider =
    Provider<RouteRepository>(
  (Ref ref) => MockRouteRepository(
    ref.watch(mockStoreProvider),
    latency: ref.watch(mockLatencyProvider),
  ),
);

final Provider<BookingRepository> bookingRepositoryProvider =
    Provider<BookingRepository>(
  (Ref ref) => MockBookingRepository(
    ref.watch(mockStoreProvider),
    latency: ref.watch(mockLatencyProvider),
  ),
);
