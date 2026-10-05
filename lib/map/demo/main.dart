import 'package:flutter/material.dart';

import 'map_demo_screen.dart';

void main() => runApp(const MapDemoApp());

/// Standalone map demo: no Firebase initialization or authentication.
class MapDemoApp extends StatelessWidget {
  const MapDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MapDemoScreen());
  }
}
