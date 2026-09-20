import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/my_trips/presentation/my_trips_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/search/presentation/search_screen.dart';
import 'shared/widgets/bottom_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Dates and times are shown in Russian everywhere in the interface.
  Intl.defaultLocale = 'ru';
  await initializeDateFormatting('ru');
  runApp(const CarPoolApp());
}

/// Application root. Navigation is wired by hand until `go_router` arrives at
/// L3; the screens below are static and read from the demo data.
class CarPoolApp extends StatelessWidget {
  const CarPoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarPool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const _Entry(),
    );
  }
}

class _Entry extends StatefulWidget {
  const _Entry();

  @override
  State<_Entry> createState() => _EntryState();
}

class _EntryState extends State<_Entry> {
  bool _signedIn = false;

  @override
  Widget build(BuildContext context) {
    if (!_signedIn) {
      return AuthScreen(onSubmit: () => setState(() => _signedIn = true));
    }
    return AppShell(onSignOut: () => setState(() => _signedIn = false));
  }
}

/// The three sections behind the bottom navigation.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.onSignOut});

  final VoidCallback? onSignOut;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          const SearchScreen(),
          const MyTripsScreen(),
          ProfileScreen(onSignOut: widget.onSignOut),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onSelect: (int index) => setState(() => _index = index),
      ),
    );
  }
}
