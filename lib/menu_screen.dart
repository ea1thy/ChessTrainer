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
      body: Align(
        alignment: Alignment.topCenter, // Располагаем весь контент сверху по центру
        child: FractionallySizedBox(
          widthFactor: 0.8, // Опционально: Задаём ширину относительно экрана (можно убрать)
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center, // Центрируем кнопки горизонтально
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1), // 10% от высоты экрана
              ElevatedButton(
                onPressed: () {
                  _navigateTo(context, ChessGameScreen());
                },
                child: Text('Chess Trainer'),
              ),
              SizedBox(height: 20), // Отступ между кнопками
              ElevatedButton(
                onPressed: () {
                  _navigateTo(context, AnotherGameScreen());
                },
                child: Text('Another Trainer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}