// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: SplashScreen(), // Запускаем SplashScreen перед MenuScreen
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Создаем AnimationController для вращения
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Длительность анимации
      vsync: this,
    )..repeat(); // Запускаем бесконечное вращение

    // Задержка перед переходом на MenuScreen
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MenuScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Освобождаем ресурсы контроллера
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Задаем фон
      body: Center(
        child: RotationTransition(
          turns: _controller, // Используем AnimationController для вращения
          child: Image.asset(
            'assets/splash.png', // Картинка для splash screen
            width: 150, // Задайте нужный размер
            height: 150,
          ),
        ),
      ),
    );
  }
}