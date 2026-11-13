import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/models/user.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../auth/domain/session_controller.dart';

/// Account details and the way out of it.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = ref.watch(sessionProvider);
    // Between sign-out and the redirect to /auth there is no user to show.
    if (user == null) return const SizedBox.shrink();

    final AppColors colors = context.colors;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.screen,
            Spacing.xl,
            Spacing.screen,
            Spacing.xxl,
          ),
          children: <Widget>[
            Text(
              'Профиль',
              style: AppTypography.title.copyWith(color: colors.ink),
            ),
            const SizedBox(height: Spacing.lg),
            Container(
              padding: const EdgeInsets.all(Spacing.xl),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(Radii.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Имя',
                    style: AppTypography.caption.copyWith(color: colors.moss),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    user.name,
                    style: AppTypography.body.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: Spacing.lg),
                  Text(
                    'Почта',
                    style: AppTypography.caption.copyWith(color: colors.moss),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    user.email,
                    style: AppTypography.body.copyWith(color: colors.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.block),
            DangerButton(
              label: 'Выйти',
              onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            ),
          ],
        ),
      ),
    );
  }
}
