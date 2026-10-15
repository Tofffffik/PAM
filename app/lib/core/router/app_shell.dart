import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/bottom_nav.dart';

/// The three sections behind the bottom navigation.
///
/// Each section keeps its own navigation stack, so the cities typed into the
/// search and the scroll position survive a trip to another tab. Tapping the
/// active tab again returns that section to its first screen.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: shell.currentIndex,
        onSelect: (int index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
      ),
    );
  }
}
