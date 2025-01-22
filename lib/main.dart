// lib/main.dart
import 'package:flutter/material.dart';
import 'menu_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Trainer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MenuScreen(), // Главный экран — выбор тренажёра
    );
  }
}
