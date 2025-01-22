// lib/menu_screen.dart
import 'package:flutter/material.dart';
import 'games/chess_trainer/chess_game_screen.dart';
import 'games/another_trainer/another_game_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Trainer'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _navigateTo(context, ChessGameScreen());
              },
              child: Text('Chess Trainer'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _navigateTo(context, AnotherGameScreen());
              },
              child: Text('Another Trainer'),
            ),
          ],
        ),
      ),
    );
  }
}
