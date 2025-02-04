import 'package:flutter/material.dart';
import 'package:flutter_application_1/hearbeat.dart';
// Import heartbeat.dart to use HomePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Health App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // The home property points to the HomePage from heartbeat.dart
      home: const HomePage(),
    );
  }
}
