import 'package:flutter/material.dart';

import 'map/demo/map_demo_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MapDemoScreen());
  }
}
