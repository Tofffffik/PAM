import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/formatting.dart';
import '../../../shared/models/route.dart' as model;
import '../../../shared/state/catalog.dart';
import '../../../shared/validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/filter_chips.dart';
import '../../../shared/widgets/load_failed.dart';
import '../../../shared/widgets/route_row.dart';
import '../domain/search_query.dart';

/// Search form and results.
///
/// The form writes into [searchProvider]; the list is the routes that match
/// that query, computed in the state layer. The chips «Сегодня» and «Завтра»
/// choose the day, «Есть места» and «До 200 L» narrow the list further.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const String _today = 'Сегодня';
  static const String _tomorrow = 'Завтра';
  static const String _seatsOnly = 'Есть места';
  static const String _cheap = 'До 200 L';

  late final TextEditingController _from;
  late final TextEditingController _to;
  late final TextEditingController _date;

  @override
  void initState() {
    super.initState();
    final SearchQuery query = ref.read(searchProvider);
    _from = TextEditingController(text: query.from)
      ..addListener(() => ref.read(searchProvider.notifier).setFrom(_from.text));
    _to = TextEditingController(text: query.to)
      ..addListener(() => ref.read(searchProvider.notifier).setTo(_to.text));
    _date = TextEditingController(text: Formatting.dateField(query.day));
  }

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _date.dispose();
    super.dispose();
  }

  void _swapCities() {
    ref.read(searchProvider.notifier).swapCities();
    final SearchQuery query = ref.read(searchProvider);
    _from.text = query.from;
    _to.text = query.to;
  }

  void _setDay(DateTime day) {
    ref.read(searchProvider.notifier).setDay(day);
    _date.text = Formatting.dateField(ref.read(searchProvider).day);
  }

  void _toggle(String label) {
    final SearchQueryController controller = ref.read(searchProvider.notifier);
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    switch (label) {
      case _today:
        _setDay(today);
      case _tomorrow:
        _setDay(today.add(const Duration(days: 1)));
      case _seatsOnly:
        controller.toggleSeatsOnly();
      case _cheap:
        controller.toggleCheapOnly();
    }
  }

  Future<void> _pickDate() async {
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final DateTime current = ref.read(searchProvider).day;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(today) ? today : current,
      firstDate: today,
      lastDate: today.add(Validators.departureHorizon),
      helpText: 'Дата поездки',
    );
    if (picked == null || !mounted) return;
    _setDay(picked);
  }

  void _openRoute(model.Route route) {
    context.push(AppRoutes.route(route.id));
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final SearchQuery query = ref.watch(searchProvider);
    final AsyncValue<RouteBoard> boardAsync = ref.watch(routeBoardProvider);
    final RouteBoard? board = boardAsync.value;

    final List<model.Route> routes = board == null
        ? const <model.Route>[]
        : query.apply(routes: board.routes, bookings: board.bookings);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: Spacing.xxl),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.screen,
                Spacing.xl,
                Spacing.screen,
                Spacing.lg,
              ),
              child: Text(
                'Поиск',
                style: AppTypography.title.copyWith(color: colors.ink),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.screen),
              child: Column(
                children: <Widget>[
                  CityPairField(
                    fromController: _from,
                    toController: _to,
                    onSwap: _swapCities,
                    validator: Validators.cityPair,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: Spacing.lg),
                  AppTextField(
                    label: 'Дата',
                    readOnly: true,
                    controller: _date,
                    onTap: _pickDate,
                    trailing: Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: colors.moss,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),
            FilterChipsRow(
              labels: const <String>[_today, _tomorrow, _seatsOnly, _cheap],
              selected: <String>{
                if (query.isToday) _today,
                if (query.isTomorrow) _tomorrow,
                if (query.seatsOnly) _seatsOnly,
                if (query.cheapOnly) _cheap,
              },
              onToggle: _toggle,
            ),
            const SizedBox(height: Spacing.block),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.screen),
              child: _results(boardAsync, board, routes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _results(
    AsyncValue<RouteBoard> boardAsync,
    RouteBoard? board,
    List<model.Route> routes,
  ) {
    if (board == null) {
      return boardAsync.hasError
          ? const LoadFailed()
          : const Padding(
              padding: EdgeInsets.only(top: Spacing.xl),
              child: Center(child: CircularProgressIndicator()),
            );
    }
    if (routes.isEmpty) return const EmptyState.noRoutes();

    return Column(
      children: <Widget>[
        for (int i = 0; i < routes.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: Spacing.sm),
          RouteRow(
            route: routes[i],
            freeSeats: board.freeSeats(routes[i]),
            onTap: () => _openRoute(routes[i]),
          ),
        ],
      ],
    );
  }
}
