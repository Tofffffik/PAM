/// A person using the application. The same record describes a passenger and
/// a driver: a student publishes routes and books seats with one account.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;
}
