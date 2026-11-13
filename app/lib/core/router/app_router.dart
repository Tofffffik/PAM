import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/session_controller.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/booking/presentation/booking_screen.dart';
import '../../features/my_trips/presentation/my_trips_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/publish_route/presentation/publish_route_screen.dart';
import '../../features/route_details/presentation/route_details_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';
import 'not_found_screen.dart';

/// Where the application opens. Tests set it to open a screen directly.
final Provider<String?> initialLocationProvider =
    Provider<String?>((Ref ref) => null);

/// The navigation map of the application.
///
/// ```
/// /auth                     sign in / sign up
/// ── shell (bottom navigation, one stack per section) ──
/// /search                   search
/// /trips                    my trips
/// /profile                  profile
/// ── full screen, above the shell ──
/// /routes/:routeId          route details
/// /routes/:routeId/book     booking
/// /publish                  new route
/// ```
///
/// The global guard keeps a signed-out user on `/auth` and brings them back to
/// the page they asked for after signing in. The booking rule (sold out, own
/// route) is checked by the booking screen itself, because it needs the routes
/// loaded from the repository, and a redirect cannot wait for them.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  // The router listens to this counter; every change of the session bumps it
  // and makes the guard run again.
  final ValueNotifier<int> sessionChanges = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, _) => sessionChanges.value++);

  final GoRouter router = GoRouter(
    initialLocation: ref.read(initialLocationProvider) ?? AppRoutes.search,
    refreshListenable: sessionChanges,
    redirect: (BuildContext context, GoRouterState state) => _authGuard(
      signedIn: ref.read(sessionProvider) != null,
      state: state,
    ),
    errorBuilder: (BuildContext context, GoRouterState state) =>
        const NotFoundScreen(),
    routes: <RouteBase>[
      GoRoute(path: '/', redirect: (_, _) => AppRoutes.search),
      GoRoute(
        path: AppRoutes.auth,
        builder: (BuildContext context, GoRouterState state) => AuthScreen(
          onSignIn: (String email) =>
              ref.read(sessionProvider.notifier).signIn(email: email),
          onSignUp: (String name, String email) =>
              ref.read(sessionProvider.notifier).signUp(
                    name: name,
                    email: email,
                  ),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell shell,
        ) =>
            AppShell(shell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.search,
                builder: (_, _) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.trips,
                builder: (_, _) => const MyTripsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.routePattern,
        builder: (BuildContext context, GoRouterState state) =>
            RouteDetailsScreen(
          routeId: state.pathParameters[AppRoutes.routeIdParam]!,
        ),
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.bookingSegment,
            builder: (BuildContext context, GoRouterState state) =>
                BookingScreen(
              routeId: state.pathParameters[AppRoutes.routeIdParam]!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.publish,
        builder: (_, _) => const PublishRouteScreen(),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    sessionChanges.dispose();
  });
  return router;
});

String? _authGuard({required bool signedIn, required GoRouterState state}) {
  final bool atAuth = state.matchedLocation == AppRoutes.auth;

  if (!signedIn) {
    if (atAuth) return null;
    final String asked = state.uri.toString();
    return Uri(
      path: AppRoutes.auth,
      queryParameters: asked == AppRoutes.search || asked == '/'
          ? null
          : <String, String>{AppRoutes.fromParam: asked},
    ).toString();
  }

  if (atAuth) {
    final String? from = state.uri.queryParameters[AppRoutes.fromParam];
    // Only a path inside the application, never an outside address.
    return from != null && from.startsWith('/') && !from.startsWith('//')
        ? from
        : AppRoutes.search;
  }
  return null;
}
