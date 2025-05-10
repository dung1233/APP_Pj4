import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/work_out.dart';

class Detailrepset extends StatefulWidget {
  const Detailrepset({Key? key}) : super(key: key);

  @override
  _DetailrepsetState createState() => _DetailrepsetState();
}

class _DetailrepsetState extends State<Detailrepset> {
  List<Workout> workouts = [];
  bool isLoading = true;
  Workout? nextWorkout;

  @override
  void initState() {
    super.initState();
    _loadWorkoutsFromSQLite();
  }

  Future<void> _loadWorkoutsFromSQLite() async {
    final dbHelper = DatabaseHelper();
    final List<Workout> allWorkouts = await dbHelper.getWorkouts();

    if (allWorkouts.isEmpty) {
      if (kDebugMode) {
        print("⚠️ Không có dữ liệu trong SQLite.");
      }
      setState(() => isLoading = false);
      return;
    }

    final notStartedWorkout = allWorkouts.firstWhere(
      (workout) => workout.status == "NOT_COMPLETED",
      orElse: () => allWorkouts.first,
    );

    setState(() {
      nextWorkout = notStartedWorkout;
      workouts = allWorkouts.where((w) => w.day == nextWorkout?.day).toList();
      isLoading = false;
    });
  }

  int getTotalDuration() {
    return workouts.fold(0, (sum, workout) => sum + (workout.duration ?? 0));
  }

  int getTotalExercises() {
    return workouts.length;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            "${workouts.fold(0, (sum, w) => sum + (w.sets ?? 0))}",
            "Tổng hiệp",
          ),
          _buildMetricItem(
            "${workouts.fold(0, (sum, w) => sum + (w.reps ?? 0))}",
            "Tổng lần",
          ),
          _buildMetricItem(
            "${getTotalDuration()}",
            "Tổng thời gian",
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
