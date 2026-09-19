import 'package:flutter_test/flutter_test.dart';

import 'package:carpool/main.dart';

void main() {
  testWidgets('application shell builds', (WidgetTester tester) async {
    await tester.pumpWidget(const CarPoolApp());

    expect(find.text('CarPool'), findsOneWidget);
  });
}
