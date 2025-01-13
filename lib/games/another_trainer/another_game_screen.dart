// lib/games/another_trainer/another_game_screen.dart
import 'package:flutter/material.dart';

class AnotherGameScreen extends StatefulWidget {
  const AnotherGameScreen({Key? key}) : super(key: key);

  @override
  State<AnotherGameScreen> createState() => _AnotherGameScreenState();
}

class _AnotherGameScreenState extends State<AnotherGameScreen> {
  // Здесь своя логика второй мини-игры / тренажёра

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Another Trainer'),
      ),
      body: Center(
        child: Text(
          'Here is another trainer screen!\nImplement your game logic here.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
