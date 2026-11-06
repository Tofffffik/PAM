import '../../shared/models/user.dart';

/// Signing in and out. The screens and the session state talk to this
/// interface only; what stands behind it (mock data now, the backend at L5)
/// is decided in `core/di/providers.dart`.
abstract interface class AuthRepository {
  Future<User> signIn({required String email});

  Future<User> signUp({required String name, required String email});

  Future<void> signOut();
}
