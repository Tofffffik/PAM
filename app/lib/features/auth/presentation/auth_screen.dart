import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/validators.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/filter_chips.dart';

/// Sign in and sign up on one screen, switched by the pair of chips at the
/// top.
///
/// Errors stay hidden until the first press of the button; after that every
/// field is checked as it is typed into, so a fixed mistake disappears at
/// once. Where to go next is the router's business: the screen only reports
/// the valid credentials.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onSignIn, required this.onSignUp});

  /// Both report the valid credentials to the session; the router moves on
  /// once the session has changed.
  final Future<void> Function(String email) onSignIn;
  final Future<void> Function(String name, String email) onSignUp;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const String _signIn = 'Вход';
  static const String _signUp = 'Регистрация';

  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String _mode = _signIn;
  bool _passwordHidden = true;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  bool get _registering => _mode == _signUp;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Switching between sign in and sign up starts the form over: the rules
  /// differ, so the old messages no longer apply.
  void _switchMode(String mode) {
    if (mode == _mode) return;
    setState(() {
      _mode = mode;
      _autovalidate = AutovalidateMode.disabled;
    });
    _form.currentState?.reset();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    FocusScope.of(context).unfocus();
    if (_registering) {
      await widget.onSignUp(_name.text, _email.text);
    } else {
      await widget.onSignIn(_email.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _form,
          autovalidateMode: _autovalidate,
          child: AutofillGroup(
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
                      selected: !_registering,
                      onTap: () => _switchMode(_signIn),
                    ),
                    const SizedBox(width: Spacing.sm),
                    FilterToggleChip(
                      label: _signUp,
                      selected: _registering,
                      onTap: () => _switchMode(_signUp),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.block),
                if (_registering) ...<Widget>[
                  AppTextField(
                    key: const ValueKey<String>('auth-name'),
                    label: 'Имя',
                    hint: 'Андрей Мунтяну',
                    controller: _name,
                    validator: Validators.name,
                    textInputAction: TextInputAction.next,
                    autofillHints: const <String>[AutofillHints.name],
                  ),
                  const SizedBox(height: Spacing.lg),
                ],
                AppTextField(
                  key: const ValueKey<String>('auth-email'),
                  label: 'Почта',
                  hint: 'name@student.utm.md',
                  controller: _email,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.email],
                ),
                const SizedBox(height: Spacing.lg),
                AppTextField(
                  key: const ValueKey<String>('auth-password'),
                  label: 'Пароль',
                  hint: _registering
                      ? 'Буквы и цифры, от ${Validators.passwordMin} символов'
                      : null,
                  controller: _password,
                  validator: _registering
                      ? Validators.newPassword
                      : Validators.passwordPresent,
                  obscureText: _passwordHidden,
                  textInputAction: TextInputAction.done,
                  autofillHints: <String>[
                    if (_registering)
                      AutofillHints.newPassword
                    else
                      AutofillHints.password,
                  ],
                  onSubmitted: (_) => _submit(),
                  trailing: _PasswordToggle(
                    hidden: _passwordHidden,
                    onPressed: () =>
                        setState(() => _passwordHidden = !_passwordHidden),
                  ),
                ),
                const SizedBox(height: Spacing.block),
                PrimaryButton(
                  label: _registering ? 'Создать аккаунт' : 'Войти',
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordToggle extends StatelessWidget {
  const _PasswordToggle({required this.hidden, required this.onPressed});

  final bool hidden;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: hidden ? 'Показать пароль' : 'Скрыть пароль',
      visualDensity: VisualDensity.compact,
      icon: Icon(
        hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
        color: context.colors.moss,
      ),
    );
  }
}
