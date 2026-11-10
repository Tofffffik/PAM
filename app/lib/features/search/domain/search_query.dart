import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/booking.dart';
import '../../../shared/models/route.dart' as model;

/// What the passenger is looking for. Lives in a provider, so the search
/// survives leaving the tab and coming back.
class SearchQuery {
  const SearchQuery({
    required this.from,
    required this.to,
    required this.day,
    this.seatsOnly = false,
    this.cheapOnly = false,
  });

  /// Chip «До 200 L».
  static const double cheapLimit = 200;

  final String from;
  final String to;

  /// The day of departure, date only.
  final DateTime day;

  /// Chip «Есть места».
  final bool seatsOnly;

  /// Chip «До 200 L».
  final bool cheapOnly;

  bool get isToday => _sameDay(day, DateUtils.dateOnly(DateTime.now()));

  bool get isTomorrow => _sameDay(
        day,
        DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 1)),
      );

  SearchQuery copyWith({
    String? from,
    String? to,
    DateTime? day,
    bool? seatsOnly,
    bool? cheapOnly,
  }) {
    return SearchQuery(
      from: from ?? this.from,
      to: to ?? this.to,
      day: day ?? this.day,
      seatsOnly: seatsOnly ?? this.seatsOnly,
      cheapOnly: cheapOnly ?? this.cheapOnly,
    );
  }

  /// The routes that match the query, earliest first. An empty city matches
  /// any city; cities are compared ignoring case and surrounding spaces.
  List<model.Route> apply({
    required Iterable<model.Route> routes,
    required Iterable<Booking> bookings,
  }) {
    final List<model.Route> matched = routes.where((model.Route route) {
      if (!_sameDay(route.departureAt, day)) return false;
      if (!_matchesCity(route.fromCity, from)) return false;
      if (!_matchesCity(route.toCity, to)) return false;
      if (seatsOnly && route.freeSeats(bookings) == 0) return false;
      if (cheapOnly && route.price > cheapLimit) return false;
      return true;
    }).toList();
    matched.sort(
      (model.Route a, model.Route b) => a.departureAt.compareTo(b.departureAt),
    );
    return matched;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _matchesCity(String city, String wanted) {
    final String needle = wanted.trim().toLowerCase();
    return needle.isEmpty || city.toLowerCase() == needle;
  }
}

/// Holds the search. The defaults are the screen's first state: today, from
/// Chișinău to Bălți.
class SearchQueryController extends Notifier<SearchQuery> {
  @override
  SearchQuery build() {
    return SearchQuery(
      from: 'Кишинёв',
      to: 'Бэлць',
      day: DateUtils.dateOnly(DateTime.now()),
    );
  }

  void setFrom(String city) => state = state.copyWith(from: city);

  void setTo(String city) => state = state.copyWith(to: city);

  void swapCities() {
    state = state.copyWith(from: state.to, to: state.from);
  }

  /// Chips «Сегодня» and «Завтра» choose the day; they do not clear it.
  void setDay(DateTime day) {
    state = state.copyWith(day: DateUtils.dateOnly(day));
  }

  void toggleSeatsOnly() {
    state = state.copyWith(seatsOnly: !state.seatsOnly);
  }

  void toggleCheapOnly() {
    state = state.copyWith(cheapOnly: !state.cheapOnly);
  }
}

final NotifierProvider<SearchQueryController, SearchQuery> searchProvider =
    NotifierProvider<SearchQueryController, SearchQuery>(SearchQueryController.new);
