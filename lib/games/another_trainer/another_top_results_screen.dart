import 'package:flutter/material.dart';
import '../../../models/result.dart';

class AnotherTopResultsScreen extends StatelessWidget {
  final List<Result> topResults;

  const AnotherTopResultsScreen({Key? key, required this.topResults}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Сортируем: по убыванию score, а при равном score — по возрастанию time
    List<Result> sortedResults = List.from(topResults);
    sortedResults.sort((a, b) {
      if (a.score == b.score) {
        return a.time.compareTo(b.time);
      } else {
        return b.score.compareTo(a.score);
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
                  String time = sortedResults[index].time.toStringAsFixed(1) + ' s';
                  String score = sortedResults[index].score.toString();

                  return ListTile(
                    leading: Text(position, style: TextStyle(fontSize: 18)),
                    title: Text('Score: $score, Time: $time',
                        style: TextStyle(fontSize: 18)),
                    trailing: index < 3
                        ? Icon(
                      Icons.emoji_events,
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