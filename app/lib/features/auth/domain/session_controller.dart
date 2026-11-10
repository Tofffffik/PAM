import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../shared/models/user.dart';

/// Who is signed in, or `null` when nobody is. The router listens to it and
/// moves between the sign-in screen and the sections whenever it changes.
///
/// The state itself is kept here; the credentials are checked by the
/// [AuthRepository]. Signing in and out are asynchronous, the state changes
/// once the repository answers.
class SessionController extends Notifier<User?> {
  /// Starts signed out, or signed in as [initial] — tests begin there.
  SessionController([this._initial]);

  final User? _initial;

  @override
  User? build() => _initial;

  Future<void> signIn({required String email}) async {
    state = await ref.read(authRepositoryProvider).signIn(email: email);
  }

  Future<void> signUp({required String name, required String email}) async {
    state = await ref
        .read(authRepositoryProvider)
        .signUp(name: name, email: email);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = null;
  }
}

final NotifierProvider<SessionController, User?> sessionProvider =
    NotifierProvider<SessionController, User?>(() => SessionController());
