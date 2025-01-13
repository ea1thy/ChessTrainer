import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Trainer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> positions = [];
  String highlightedPosition = '';
  String selectedPosition = '';
  int score = 0;
  int attemptsLeft = 10;
  bool gameEnded = false;
  bool gameStarted = false;
  Stopwatch stopwatch = Stopwatch();
  double elapsedTime = 0;

  // Изменяем тип переменной на List<Result>
  List<Result> topResults = [];
  late Timer timer;

  @override
  void initState() {
    super.initState();
    createBoardPositions();
    loadTopResults();
  }

  @override
  void dispose() {
    if (timer.isActive) timer.cancel();
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
        highlightedPosition = (positions..shuffle()).first;
      } while (highlightedPosition == previousPosition);
    });
  }

  void updateScore() {
    setState(() {
      attemptsLeft--;
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
    await prefs.setStringList('topResults', topResults.map((e) => '${e.score},${e.time}').toList());
  }

  Future<void> loadTopResults() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedResults = prefs.getStringList('topResults');
    if (storedResults != null) {
      topResults = storedResults.map((e) {
        var parts = e.split(',');
        return Result(score: int.parse(parts[0]), time: double.parse(parts[1]));
      }).toList();
    }
  }


  void navigateToTopResults() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TopResultsScreen(topResults: topResults),
      ),
    );
  }

  void handleClick(String clickedPosition) {
    if (gameEnded) return;

    setState(() {
      selectedPosition = clickedPosition;

      if (clickedPosition == highlightedPosition) {
        score++;
      }
      updateScore();

      if (attemptsLeft <= 0) {
        endGame();
      } else {
        nextTarget();
      }
    });
  }

  Widget buildBoard() {
    List<Widget> rows = [];
    List<String> files = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    List<String> ranks = ['1', '2', '3', '4', '5', '6', '7', '8'];

    for (var rank in ranks.reversed) {
      List<Widget> cells = [];
      for (var file in files) {
        String position = file + rank;
        bool isSelected = position == selectedPosition;

        cells.add(
          GestureDetector(
            onTap: () => handleClick(position),
            child: AnimatedContainer(
              margin: EdgeInsets.all(0),
              width: 46,
              height: 46,
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.green : Colors.black38,
                  width: isSelected ? 3 : 1,
                ),
                color: (files.indexOf(file) + ranks.indexOf(rank)) % 2 == 0
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        );
      }
      rows.add(Row(children: cells));
    }

    return Column(children: rows);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chess Position Trainer'),
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
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Welcome to the Chess Position Trainer!\n",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                          ),
                          TextSpan(
                            text: "Improve your memory skills by identifying squares.\n",
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16, color: Colors.blue),
                          ),
                          TextSpan(
                            text: "\nHow to play:\n",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                          ),
                          TextSpan(
                            text: "1. Look at the highlighted square name.\n"
                                "2. Tap the corresponding square on the chessboard.\n"
                                "3. You have 10 attempts. Good luck!\n",
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Image.asset('assets/chess_icon.png', height: 100), // Замените путь на актуальный.
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: startGame,
                      child: Text('Start Game'),
                    ),
                  ],
                ),
              ),

            if (gameStarted && !gameEnded) ...[
              Text('Target:', style: TextStyle(fontSize: 18)),
              Text('$highlightedPosition', style: TextStyle(fontSize: 80, color: Colors.green)),
              buildBoard(),
              Text('Score: $score', style: TextStyle(fontSize: 18)),
              Text('Attempts Left: $attemptsLeft', style: TextStyle(fontSize: 18)),
              Text(
                'Time: ${elapsedTime.toStringAsFixed(1)} seconds',
                style: TextStyle(fontSize: 18),
              ),
            ],
            if (gameEnded) ...[
              Expanded(
                child: Center( // Центрирование всего содержимого
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center, // Горизонтальное центрирование
                    children: [
                      Text(
                        'Game Over',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('Score: $score', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      Text('Time: ${elapsedTime.toStringAsFixed(1)} seconds', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: startGame,
                        child: Text('Restart Game'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class Result {
  final int score;
  final double time;

  Result({required this.score, required this.time});
}


class TopResultsScreen extends StatelessWidget {
  final List<Result> topResults;

  const TopResultsScreen({Key? key, required this.topResults}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Сортировка: сначала по score (в убывании), потом по времени (в возрастании)
    List<Result> sortedResults = List.from(topResults);
    sortedResults.sort((a, b) {
      if (a.score == b.score) {
        return a.time.compareTo(b.time); // если score одинаковый, сортируем по времени
      } else {
        return b.score.compareTo(a.score); // сортируем по убыванию score
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Top Results"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Top Results (${sortedResults.length} entries)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sortedResults.length,
                itemBuilder: (context, index) {
                  String position = (index + 1).toString();
                  String time = sortedResults[index].time.toStringAsFixed(1) + ' seconds';
                  String score = sortedResults[index].score.toString();
                  return ListTile(
                    leading: Text(position, style: TextStyle(fontSize: 18)),
                    title: Text('Score: $score, Time: $time', style: TextStyle(fontSize: 18)),
                    trailing: index < 3
                        ? Icon(
                      index == 0
                          ? Icons.emoji_events
                          : index == 1
                          ? Icons.emoji_events
                          : Icons.emoji_events,
                      color: index == 0
                          ? Color(0xFFFFD700) // Gold
                          : index == 1
                          ? Color(0xFFC0C0C0) // Silver
                          : Color(0xFFCD7F32), // Bronze
                    )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

