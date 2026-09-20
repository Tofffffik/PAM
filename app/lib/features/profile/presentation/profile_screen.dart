import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../sandbox/sandbox_screen.dart';
import '../../../shared/demo_data.dart';
import '../../../shared/models/user.dart';
import '../../../shared/widgets/app_buttons.dart';

/// Account details and the way out of it.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onSignOut});

  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final User user = demoCurrentUser;

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
                    style:
                        AppTypography.caption.copyWith(color: colors.moss),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    user.name,
                    style: AppTypography.body.copyWith(color: colors.ink),
                  ),
                  const SizedBox(height: Spacing.lg),
                  Text(
                    'Почта',
                    style:
                        AppTypography.caption.copyWith(color: colors.moss),
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
            // Temporary entry point to the component sandbox; it goes away
            // once the router is in place at L3.
            SecondaryButton(
              label: 'Компоненты и состояния',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SandboxScreen(),
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            DangerButton(label: 'Выйти', onPressed: onSignOut),
          ],
        ),
      ),
    );
  }
}
