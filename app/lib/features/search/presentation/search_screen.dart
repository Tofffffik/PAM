import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/demo_data.dart';
import '../../../shared/formatting.dart';
import '../../../shared/models/route.dart' as model;
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/filter_chips.dart';
import '../../../shared/widgets/route_row.dart';
import '../../route_details/presentation/route_details_screen.dart';

/// Search form and results.
///
/// The chips only toggle here; filtering the list is the job of L4. The rows
/// are laid on the paper background with an 8pt gap and no separator line.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const List<String> _filters = <String>[
    'Сегодня',
    'Завтра',
    'Есть места',
    'До 200 L',
  ];

  final TextEditingController _from =
      TextEditingController(text: 'Кишинёв');
  final TextEditingController _to = TextEditingController(text: 'Бэлць');
  final TextEditingController _date =
      TextEditingController(text: Formatting.dateField(DateTime.now()));

  final Set<String> _active = <String>{'Сегодня'};

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _date.dispose();
    super.dispose();
  }

  void _swapCities() {
    final String from = _from.text;
    setState(() {
      _from.text = _to.text;
      _to.text = from;
    });
  }

  void _toggle(String label) {
    setState(() {
      if (!_active.remove(label)) _active.add(label);
    });
  }

  void _openRoute(model.Route route) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RouteDetailsScreen(routeId: route.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final List<model.Route> routes = demoRoutes;

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
              padding:
                  const EdgeInsets.symmetric(horizontal: Spacing.screen),
              child: Column(
                children: <Widget>[
                  CityPairField(
                    fromController: _from,
                    toController: _to,
                    onSwap: _swapCities,
                  ),
                  const SizedBox(height: Spacing.lg),
                  AppTextField(
                    label: 'Дата',
                    readOnly: true,
                    controller: _date,
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
              labels: _filters,
              selected: _active,
              onToggle: _toggle,
            ),
            const SizedBox(height: Spacing.block),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Spacing.screen),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < routes.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: Spacing.sm),
                    RouteRow(
                      route: routes[i],
                      freeSeats: routes[i].freeSeats(demoBookings),
                      onTap: () => _openRoute(routes[i]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
