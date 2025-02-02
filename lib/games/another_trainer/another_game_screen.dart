import 'dart:async';
import 'package:flutter/material.dart';
import 'another_top_results_screen.dart';
import '../../../models/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnotherGameScreen extends StatefulWidget {
  const AnotherGameScreen({Key? key}) : super(key: key);

  @override
  State<AnotherGameScreen> createState() => _AnotherGameScreenState();
}

class _AnotherGameScreenState extends State<AnotherGameScreen> {
  List<String> positions = [];
  List<Result> topResults = [];
  String highlightedPosition = '';
  int score = 0;
  int attemptsLeft = 10;
  bool gameEnded = false;
  bool gameStarted = false;
  Stopwatch stopwatch = Stopwatch();
  double elapsedTime = 0;
  late Timer timer;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    createBoardPositions();
  }

  @override
  void dispose() {
    if (timer.isActive) timer.cancel();
    stopwatch.stop();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void createBoardPositions() {
    List<String> files = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    List<String> ranks = ['1', '2', '3', '4', '5', '6', '7', '8'];

    positions.clear();
    for (var file in files) {
      for (var rank in ranks) {
        positions.add(file + rank);
      }
    }
  }

  void nextTarget() {
    setState(() {
      String previousPosition = highlightedPosition;
      do {
        positions.shuffle();
        highlightedPosition = positions.first;
      } while (highlightedPosition == previousPosition);
    });
  }

  void startGame() {
    setState(() {
      score = 0;
      attemptsLeft = 10;
      gameEnded = false;
      gameStarted = true;
      elapsedTime = 0;
      stopwatch.reset();
      stopwatch.start();
      nextTarget();
    });

    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        elapsedTime = stopwatch.elapsedMilliseconds / 1000.0;
      });
    });
  }

  void endGame() {
    stopwatch.stop();
    if (timer.isActive) timer.cancel();

    setState(() {
      elapsedTime = stopwatch.elapsedMilliseconds / 1000.0;
      gameEnded = true;
    });

    saveResult();
  }

  Future<void> saveResult() async {
    final prefs = await SharedPreferences.getInstance();
    topResults.add(Result(score: score, time: elapsedTime));
    topResults.sort((a, b) {
      if (a.score == b.score) {
        return a.time.compareTo(b.time);
      } else {
        return b.score.compareTo(a.score);
      }
    });
    if (topResults.length > 10) {
      topResults = topResults.sublist(0, 10);
    }
    await prefs.setStringList(
      'anotherTopResults',
      topResults.map((e) => '${e.score},${e.time}').toList(),
    );
  }

  Future<void> loadTopResults() async {
    final prefs = await SharedPreferences.getInstance();
    final storedResults = prefs.getStringList('anotherTopResults');
    if (storedResults != null) {
      topResults = storedResults.map((e) {
        final parts = e.split(',');
        return Result(
          score: int.parse(parts[0]),
          time: double.parse(parts[1]),
        );
      }).toList();
    }
  }

  void navigateToTopResults() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnotherTopResultsScreen(topResults: topResults),
      ),
    );
  }

  void handleSubmit(String input) {
    if (gameEnded || input.isEmpty) return;

    setState(() {
      if (input.toUpperCase() == highlightedPosition) {
        score++;
      }
      attemptsLeft--;

      if (attemptsLeft <= 0) {
        endGame();
      } else {
        nextTarget();
      }
    });

    _controller.clear();
    _focusNode.requestFocus();
  }

  /// Виджет шахматного поля.
  Widget buildBoard() {
    return AspectRatio(
      aspectRatio: 1.0, // квадрат
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = constraints.maxWidth / 8.0;

          final files = ['A','B','C','D','E','F','G','H'];
          final ranks = ['1','2','3','4','5','6','7','8'];

          List<Widget> rows = [];
          for (var rank in ranks.reversed) {
            List<Widget> cells = [];
            for (var file in files) {
              final position = file + rank;
              cells.add(
                Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: position == highlightedPosition
                        ? Colors.blue
                        : (files.indexOf(file) + ranks.indexOf(rank)) % 2 == 0
                        ? Colors.white
                        : Colors.black,
                    border: Border.all(
                      color: Colors.black38,
                      width: 1,
                    ),
                  ),
                ),
              );
            }
            rows.add(
              Row(
                children: cells,
                mainAxisSize: MainAxisSize.min,
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: rows,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Identify Square'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: navigateToTopResults,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Показать доску, только если игра началась и не закончилась
            if (gameStarted && !gameEnded)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildBoard(),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Собираем контент (поле ввода, стартовый экран, game over и т.п.)
  Widget buildContent() {
    // Если игра НЕ запущена:
    if (!gameStarted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Welcome to the Chess Position Trainer!\n",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text:
                    "Improve your memory by identifying squares.\n",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  TextSpan(
                    text: "\nHow to play:\n",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                  TextSpan(
                    text:
                    "1. Look at the highlighted square name.\n"
                        "2. Tap the corresponding square on the chessboard.\n"
                        "3. You have 10 attempts. Good luck!\n",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Image.asset('assets/chess_icon.png', height: 100),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: startGame,
              child: Text('Start Game'),
            ),
          ],
        ),
      );
    }

    // Если игра окончена:
    if (gameEnded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Game Over',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Score: $score', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(
              'Time: ${elapsedTime.toStringAsFixed(1)} seconds',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startGame,
              child: Text('Restart Game'),
            ),
          ],
        ),
      );
    }

    // Игра идёт (но не окончена):
    return Column(
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'Enter square name (e.g., A1)',
            border: OutlineInputBorder(),
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
          onSubmitted: handleSubmit,
        ),
        SizedBox(height: 20),
        Text('Score: $score', style: TextStyle(fontSize: 18)),
        Text('Attempts Left: $attemptsLeft', style: TextStyle(fontSize: 18)),
        Text(
          'Time: ${elapsedTime.toStringAsFixed(1)} seconds',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
