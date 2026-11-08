import '../../data/repositories/user_repository.dart';
import '../../shared/models/user.dart';
import 'mock_store.dart';

class MockUserRepository implements UserRepository {
  const MockUserRepository(this._store, {required this.latency});

  final MockStore _store;
  final Duration latency;

  @override
  Future<User?> userById(String id) async {
    await pause(latency);
    for (final User user in _store.users) {
      if (user.id == id) return user;
    }
    return null;
  }
}
