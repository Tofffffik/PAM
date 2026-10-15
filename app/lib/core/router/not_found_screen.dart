import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_buttons.dart';
import '../../shared/widgets/empty_state.dart';
import '../theme/spacing.dart';
import 'app_routes.dart';

/// What an unknown link or a route that no longer exists opens.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.routeMissing = false});

  /// A well-formed link to a route that is not there, as opposed to a path
  /// the application does not know at all.
  final bool routeMissing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(routeMissing ? 'Маршрут' : 'CarPool')),
      body: ListView(
        children: <Widget>[
          if (routeMissing)
            const EmptyState.routeNotFound()
          else
            const EmptyState.pageNotFound(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.screen),
            child: SecondaryButton(
              label: 'К поиску',
              onPressed: () => context.go(AppRoutes.search),
            ),
          ),
        ],
      ),
    );
  }
}
