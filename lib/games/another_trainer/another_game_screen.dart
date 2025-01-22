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

    positions = [];
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

    timer = Timer.periodic(Duration(milliseconds: 100), (_) {
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
    // Сортировка и ограничение до 10 результатов
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
    List<String>? storedResults = prefs.getStringList('anotherTopResults');
    if (storedResults != null) {
      topResults = storedResults.map((e) {
        var parts = e.split(',');
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
    _focusNode.requestFocus(); // Сохраняем фокус в поле ввода
  }

  Widget buildBoard() {
    double screenWidth = MediaQuery.of(context).size.width;
    double cellSize = (screenWidth - 16) / 8;

    List<Widget> rows = [];
    List<String> files = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    List<String> ranks = ['1', '2', '3', '4', '5', '6', '7', '8'];

    for (var rank in ranks.reversed) {
      List<Widget> cells = [];
      for (var file in files) {
        String position = file + rank;

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

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Column(
          children: rows,
          mainAxisSize: MainAxisSize.min,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guess the Chess Square'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: navigateToTopResults,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!gameStarted)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to "Guess the Chess Square"!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: startGame,
                    child: Text('Start Game'),
                  ),
                ],
              ),
            if (gameStarted && !gameEnded) ...[
              buildBoard(),
              SizedBox(height: 20),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: 'Enter square name (e.g., A1)',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
                onSubmitted: handleSubmit,
              ),
              SizedBox(height: 20),
              Text('Score: $score', style: TextStyle(fontSize: 18)),
              Text('Attempts Left: $attemptsLeft',
                  style: TextStyle(fontSize: 18)),
              Text(
                'Time: ${elapsedTime.toStringAsFixed(1)} seconds',
                style: TextStyle(fontSize: 18),
              ),
            ],
            if (gameEnded) ...[
              Center(
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}