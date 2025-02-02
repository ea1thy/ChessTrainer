// lib/menu_screen.dart
import 'package:flutter/material.dart';
import 'games/chess_trainer/chess_game_screen.dart';
import 'games/another_trainer/another_game_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  /// Переход на экран [screen]
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Показать диалог «Coming Soon»
  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Coming Soon'),
        content: Text('More mini-games are on the way!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Coordinates Trainer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Используем GridView, чтобы каждая игра отображалась карточкой
        child: GridView.count(
          crossAxisCount: 2,         // Две карточки в строке (при добавлении третьей она займет новую строку)
          crossAxisSpacing: 16,      // Горизонтальный отступ между карточками
          mainAxisSpacing: 16,       // Вертикальный отступ
          childAspectRatio: 1.2,     // Соотношение сторон карточки (регулируйте под нужный дизайн)
          children: [
            _GameCard(
              title: 'Pick Square',
              onTap: () => _navigateTo(context, ChessGameScreen()),
            ),
            _GameCard(
              title: 'Identify Square',
              onTap: () => _navigateTo(context, AnotherGameScreen()),
            ),
            // Заглушка для будущей мини-игры
            _GameCard(
              title: 'Coming Soon ...',
              onTap: () => _showComingSoon(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Вспомогательный виджет-карточка.
/// Показывает [title] и реагирует на нажатие [onTap].
class _GameCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _GameCard({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
