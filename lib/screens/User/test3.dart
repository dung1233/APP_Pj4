import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/DatabaseHelper.dart';

class WorkoutLocalResultScreen extends StatelessWidget {
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dữ liệu bài tập đã lưu")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getAllWorkoutResults(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final results = snapshot.data!;
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (_, index) {
              final r = results[index];
              return ListTile(
                title: Text(r['exerciseName']),
                subtitle: Text("Set: ${r['setsCompleted']} × Rep: ${r['repsCompleted']}"),
              );
            },
          );
        },
      ),
    );
  }
}
