import 'package:flutter/material.dart';
import '../../data/DatabaseHelper.dart';

class WorkoutLocalResultScreen extends StatefulWidget {
  @override
  _WorkoutLocalResultScreenState createState() => _WorkoutLocalResultScreenState();
}

class _WorkoutLocalResultScreenState extends State<WorkoutLocalResultScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _futureResults;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final allResults = await dbHelper.getAllWorkoutResults();

    // Nhóm theo ngày và bài tập, giữ bản ghi có rep cao nhất
    final Map<String, Map<String, dynamic>> groupedResults = {};
    for (var result in allResults) {
      final key = '${result['dayNumber']}_${result['exerciseName']}';
      if (!groupedResults.containsKey(key) || result['repsCompleted'] > groupedResults[key]!['repsCompleted']) {
        groupedResults[key] = result;
      }
    }

    setState(() {
      _futureResults = Future.value(groupedResults.values.toList());
    });
  }

  Future<void> _refreshData() async {
    await _loadResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dữ liệu bài tập đã lưu"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("❌ Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("⚠️ Không có dữ liệu"));
          }

          final results = snapshot.data!;
          final groupedByDay = <int, List<Map<String, dynamic>>>{};

          for (var r in results) {
            final day = r['dayNumber'] ?? 0;
            if (!groupedByDay.containsKey(day)) {
              groupedByDay[day] = [];
            }
            groupedByDay[day]!.add(r);
          }

          return ListView(
            children: groupedByDay.entries.map((entry) {
              final day = entry.key;
              final dayResults = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "🗓️ Ngày: $day",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...dayResults.map((r) {
                    final name = r['exerciseName'] ?? '';
                    final isRun = name.toString().toLowerCase().contains("chạy");
                    return ListTile(
                      title: Text(name),
                      subtitle: Text(
                        isRun
                            ? 'Distance: ${r['distanceCompleted']}m | Time: ${r['durationCompleted']}p'
                            : 'Set: ${r['setsCompleted']} × Rep: ${r['repsCompleted']}',
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}