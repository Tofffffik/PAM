import 'models/booking.dart';
import 'models/route.dart';
import 'models/user.dart';

/// Hard-wired data the static screens are built on. It is replaced by the
/// mock repositories at L4 and by the backend at L5.
///
/// Departure times are anchored to the current day so that the «Сегодня» and
/// «Завтра» filters stay meaningful whenever the application is opened.
final DateTime _today = _startOfToday();

DateTime _startOfToday() {
  final DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime _at(int dayOffset, int hour, int minute) {
  return DateTime(_today.year, _today.month, _today.day + dayOffset, hour, minute);
}

/// The signed-in student. Owns routes r5 and r10 as a driver and holds four
/// bookings as a passenger.
const User demoCurrentUser = User(
  id: 'u1',
  name: 'Андрей Мунтяну',
  email: 'andrei.munteanu@student.utm.md',
);

const List<User> demoDrivers = <User>[
  demoCurrentUser,
  User(id: 'u2', name: 'Виктор Русу', email: 'victor.rusu@student.utm.md'),
  User(id: 'u3', name: 'Дана Чиботару', email: 'dana.cibotaru@student.utm.md'),
  User(id: 'u4', name: 'Сергей Лунгу', email: 'sergiu.lungu@student.utm.md'),
];

/// Driver of a route, by id.
User demoUserById(String id) {
  return demoDrivers.firstWhere(
    (User user) => user.id == id,
    orElse: () => demoCurrentUser,
  );
}

/// Ten routes on the real directions students take out of Chișinău.
final List<Route> demoRoutes = <Route>[
  Route(
    id: 'r1',
    driverId: 'u2',
    fromCity: 'Кишинёв',
    toCity: 'Бэлць',
    departureAt: _at(0, 17, 40),
    seatsTotal: 4,
    price: 180,
  ),
  // Sold out: two active bookings take all three seats.
  Route(
    id: 'r2',
    driverId: 'u3',
    fromCity: 'Кишинёв',
    toCity: 'Кагул',
    departureAt: _at(0, 19, 0),
    seatsTotal: 3,
    price: 200,
  ),
  Route(
    id: 'r3',
    driverId: 'u2',
    fromCity: 'Бэлць',
    toCity: 'Кишинёв',
    departureAt: _at(1, 7, 30),
    seatsTotal: 4,
    price: 180,
  ),
  Route(
    id: 'r4',
    driverId: 'u4',
    fromCity: 'Кишинёв',
    toCity: 'Орхей',
    departureAt: _at(1, 9, 15),
    seatsTotal: 3,
    price: 90,
  ),
  Route(
    id: 'r5',
    driverId: 'u1',
    fromCity: 'Кишинёв',
    toCity: 'Унгень',
    departureAt: _at(1, 15, 20),
    seatsTotal: 4,
    price: 120,
  ),
  Route(
    id: 'r6',
    driverId: 'u3',
    fromCity: 'Унгень',
    toCity: 'Кишинёв',
    departureAt: _at(2, 8, 0),
    seatsTotal: 3,
    price: 120,
  ),
  Route(
    id: 'r7',
    driverId: 'u4',
    fromCity: 'Кишинёв',
    toCity: 'Бэлць',
    departureAt: _at(2, 16, 45),
    seatsTotal: 5,
    price: 170,
  ),
  Route(
    id: 'r8',
    driverId: 'u2',
    fromCity: 'Кагул',
    toCity: 'Кишинёв',
    departureAt: _at(3, 6, 50),
    seatsTotal: 4,
    price: 200,
  ),
  // One seat left: the row shows the warn-outlined pip.
  Route(
    id: 'r9',
    driverId: 'u3',
    fromCity: 'Орхей',
    toCity: 'Кишинёв',
    departureAt: _at(3, 18, 30),
    seatsTotal: 2,
    price: 90,
  ),
  // A minibus: over eight seats, so the pips collapse to a single one.
  Route(
    id: 'r10',
    driverId: 'u1',
    fromCity: 'Кишинёв',
    toCity: 'Бэлць',
    departureAt: _at(4, 12, 0),
    seatsTotal: 12,
    price: 160,
  ),
];

/// Every booking in the demo set: four belong to the signed-in student, the
/// rest are other passengers and exist so that the seat arithmetic on the
/// route list has something to subtract.
final List<Booking> demoBookings = <Booking>[
  Booking(
    id: 'b1',
    routeId: 'r1',
    passengerId: 'u1',
    seats: 1,
    status: BookingStatus.active,
    createdAt: _at(-2, 11, 5),
  ),
  Booking(
    id: 'b2',
    routeId: 'r3',
    passengerId: 'u1',
    seats: 2,
    status: BookingStatus.active,
    createdAt: _at(-1, 20, 40),
  ),
  Booking(
    id: 'b3',
    routeId: 'r4',
    passengerId: 'u1',
    seats: 1,
    status: BookingStatus.cancelled,
    createdAt: _at(-3, 9, 25),
  ),
  Booking(
    id: 'b4',
    routeId: 'r7',
    passengerId: 'u1',
    seats: 1,
    status: BookingStatus.active,
    createdAt: _at(-1, 13, 10),
  ),
  Booking(
    id: 'b5',
    routeId: 'r1',
    passengerId: 'u3',
    seats: 1,
    status: BookingStatus.active,
    createdAt: _at(-2, 18, 0),
  ),
  Booking(
    id: 'b6',
    routeId: 'r2',
    passengerId: 'u4',
    seats: 2,
    status: BookingStatus.active,
    createdAt: _at(-2, 8, 15),
  ),
  Booking(
    id: 'b7',
    routeId: 'r2',
    passengerId: 'u2',
    seats: 1,
    status: BookingStatus.active,
    createdAt: _at(-1, 10, 30),
  ),
  Booking(
    id: 'b8',
    routeId: 'r7',
    passengerId: 'u3',
    seats: 1,
    status: BookingStatus.active,
    createdAt: _at(-1, 19, 55),
  ),
  Booking(
    id: 'b9',
    routeId: 'r9',
    passengerId: 'u4',
    seats: 1,
    status: BookingStatus.active,
    createdAt: _at(-1, 7, 45),
  ),
  Booking(
    id: 'b10',
    routeId: 'r5',
    passengerId: 'u3',
    seats: 2,
    status: BookingStatus.active,
    createdAt: _at(-2, 16, 20),
  ),
  Booking(
    id: 'b11',
    routeId: 'r10',
    passengerId: 'u4',
    seats: 3,
    status: BookingStatus.active,
    createdAt: _at(-1, 12, 0),
  ),
];

/// Bookings of the signed-in student, newest first.
List<Booking> get demoMyBookings {
  final List<Booking> mine = demoBookings
      .where((Booking booking) => booking.passengerId == demoCurrentUser.id)
      .toList();
  mine.sort((Booking a, Booking b) => b.createdAt.compareTo(a.createdAt));
  return mine;
}

/// Routes the signed-in student drives, by departure time.
List<Route> get demoMyRoutes {
  final List<Route> mine = demoRoutes
      .where((Route route) => route.driverId == demoCurrentUser.id)
      .toList();
  mine.sort((Route a, Route b) => a.departureAt.compareTo(b.departureAt));
  return mine;
}

/// Route by id; the static screens always ask for one that exists.
Route demoRouteById(String id) {
  return demoRoutes.firstWhere((Route route) => route.id == id);
}
