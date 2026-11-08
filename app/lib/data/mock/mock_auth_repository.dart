import '../../data/repositories/auth_repository.dart';
import '../../shared/demo_data.dart';
import '../../shared/models/user.dart';
import 'mock_store.dart';

/// Accepts any well-formed credentials, as the session did before L4: signing
/// in opens the demo account with the typed mail, signing up opens an account
/// with the typed name and mail.
class MockAuthRepository implements AuthRepository {
  const MockAuthRepository({required this.latency});

  final Duration latency;

  @override
  Future<User> signIn({required String email}) async {
    await pause(latency);
    return User(
      id: demoCurrentUser.id,
      name: demoCurrentUser.name,
      email: email.trim(),
    );
  }

  @override
  Future<User> signUp({required String name, required String email}) async {
    await pause(latency);
    return User(
      id: demoCurrentUser.id,
      name: name.trim(),
      email: email.trim(),
    );
  }

  @override
  Future<void> signOut() => pause(latency);
}
