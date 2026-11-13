import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/catalog.dart';
import 'app_buttons.dart';
import 'empty_state.dart';

/// The routes or the bookings could not be loaded. The button asks the
/// repositories again; every screen waiting for them updates by itself.
class LoadFailed extends ConsumerWidget {
  const LoadFailed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EmptyState.loadFailed(
      action: SecondaryButton(
        label: 'Повторить',
        onPressed: () => reloadCatalog(ref),
      ),
    );
  }
}
