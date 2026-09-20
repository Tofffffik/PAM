import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/filter_chips.dart';

/// Sign in and sign up on one screen, switched by the pair of chips at the
/// top. The form is static here: it is validated at L3 and talks to the
/// backend from L5.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.onSubmit});

  final VoidCallback? onSubmit;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const String _signIn = 'Вход';
  static const String _signUp = 'Регистрация';

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String _mode = _signIn;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final bool registering = _mode == _signUp;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.screen,
            Spacing.xxl,
            Spacing.screen,
            Spacing.xxl,
          ),
          children: <Widget>[
            Text(
              'CarPool',
              style: AppTypography.title.copyWith(color: colors.ink),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Попутчики между парами и домой на выходные.',
              style: AppTypography.body.copyWith(color: colors.moss),
            ),
            const SizedBox(height: Spacing.block),
            Row(
              children: <Widget>[
                FilterToggleChip(
                  label: _signIn,
                  selected: !registering,
                  onTap: () => setState(() => _mode = _signIn),
                ),
                const SizedBox(width: Spacing.sm),
                FilterToggleChip(
                  label: _signUp,
                  selected: registering,
                  onTap: () => setState(() => _mode = _signUp),
                ),
              ],
            ),
            const SizedBox(height: Spacing.block),
            if (registering) ...<Widget>[
              AppTextField(
                label: 'Имя',
                hint: 'Андрей Мунтяну',
                controller: _name,
              ),
              const SizedBox(height: Spacing.lg),
            ],
            AppTextField(
              label: 'Почта',
              hint: 'name@student.utm.md',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: Spacing.lg),
            AppTextField(
              label: 'Пароль',
              controller: _password,
              obscureText: true,
            ),
            const SizedBox(height: Spacing.block),
            PrimaryButton(
              label: registering ? 'Создать аккаунт' : 'Войти',
              onPressed: widget.onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
