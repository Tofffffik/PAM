import 'package:flutter/material.dart';

void main() {
  runApp(const CarPoolApp());
}

/// Application root. The theme, router and providers are introduced by the
/// later stages; for now this is the shell that `flutter run` opens.
class CarPoolApp extends StatelessWidget {
  const CarPoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CarPool',
      home: Scaffold(
        body: Center(child: Text('CarPool')),
      ),
    );
  }
}
