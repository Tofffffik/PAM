/// Every path in the application, so that no screen spells a URL by hand.
///
/// The three sections are the branches of the bottom navigation. A route and
/// its booking sit above the sections, full screen, under a path of their
/// own — the same link opens them from the search, from «Мои поездки» or
/// from outside the application.
abstract final class AppRoutes {
  static const String auth = '/auth';

  static const String search = '/search';
  static const String trips = '/trips';
  static const String profile = '/profile';

  static const String publish = '/publish';

  static const String routeIdParam = 'routeId';
  static const String routePattern = '/routes/:$routeIdParam';
  static const String bookingSegment = 'book';

  /// Query parameter carrying the page asked for before signing in.
  static const String fromParam = 'from';

  static String route(String id) => '/routes/$id';

  static String booking(String id) => '/routes/$id/$bookingSegment';
}
