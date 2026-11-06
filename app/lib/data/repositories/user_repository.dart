import '../../shared/models/user.dart';

/// Looking up the people behind routes and bookings.
abstract interface class UserRepository {
  /// The user with [id], or `null` when there is no such user.
  Future<User?> userById(String id);
}
