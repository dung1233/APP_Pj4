import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/work_out.dart';

class Detailday extends StatefulWidget {
  const Detailday({Key? key}) : super(key: key);

  @override
  _DetaildayState createState() => _DetaildayState();
}

class _DetaildayState extends State<Detailday> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          "Ngày ${nextWorkout?.day ?? '3'}",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nextWorkout?.exerciseName ?? "Sức mạnh",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "${getTotalDuration()} phút - ${getTotalExercises()} bài tập",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
