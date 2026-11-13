import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Dates and times are shown in Russian everywhere in the interface.
  Intl.defaultLocale = 'ru';
  await initializeDateFormatting('ru');
  runApp(const ProviderScope(child: CarPoolApp()));
}

/// Application root: the theme, the Russian locale and the router.
///
/// The state lives in the providers of the enclosing [ProviderScope], so it
/// outlives every rebuild of this widget and the navigation stack is kept.
class CarPoolApp extends ConsumerWidget {
  const CarPoolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CarPool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: const Locale('ru'),
      supportedLocales: const <Locale>[Locale('ru')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: router,
    );
  }
}
