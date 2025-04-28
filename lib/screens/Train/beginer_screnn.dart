// 📄 File: BeginerScreen.dart
import 'package:flutter/material.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:training_souls/screens/Test.dart';

class BeginerScrenn extends StatefulWidget {
  const BeginerScrenn({super.key});

  @override
  _BeginnerScreenState createState() => _BeginnerScreenState();
}

class _BeginnerScreenState extends State<BeginerScrenn> {
  final dbHelper = DatabaseHelper();
  List<Workout> allWorkouts = [];
  List<Workout> dayWorkouts = [];
  Workout? nextWorkout;
  int day = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final fetchedWorkouts = await dbHelper.getWorkouts();

    if (fetchedWorkouts.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    fetchedWorkouts.sort((a, b) => (a.day ?? 0).compareTo(b.day ?? 0));

    final notStartedWorkout = fetchedWorkouts.firstWhere(
          (w) => w.status == "NOT_STARTED",
      orElse: () => Workout(day: 1, exerciseName: "", status: "COMPLETED"),
    );

    if (notStartedWorkout.status == "COMPLETED") {
      _showAllCompletedDialog();
      setState(() {
        isLoading = false;
      });
      return;
    }

    final selectedDay = notStartedWorkout.day ?? 1;
    final selectedDayWorkouts = fetchedWorkouts.where((w) => w.day == selectedDay).toList();

    setState(() {
      nextWorkout = notStartedWorkout;
      day = selectedDay;
      dayWorkouts = selectedDayWorkouts;
      isLoading = false;
    });
  }

  Future<void> _showAllCompletedDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🎉 Hoàn thành!"),
        content: const Text("Bạn đã hoàn thành tất cả các bài tập."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (nextWorkout == null) {
      return const Center(child: Text("Không có bài tập nào."));
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 250,
      padding: const EdgeInsets.only(left: 25, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8)],
        image: const DecorationImage(
          image: AssetImage("assets/img/run.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          Text(
            "Ngày $day",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            nextWorkout!.exerciseName ?? "Bài tập không tên",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.orange),
          ),
          const SizedBox(height: 5),
          Text(
            _getWorkoutDescription(nextWorkout!),
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const Spacer(),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              side: const BorderSide(color: Colors.white, width: 1),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Test(day: day, dayWorkouts: dayWorkouts)),
              );
            },
            child: const Text(
              "Bắt đầu",
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  String _getWorkoutDescription(Workout workout) {
    if ((workout.sets ?? 0) > 0 && (workout.reps ?? 0) > 0) {
      return "${workout.sets} hiệp × ${workout.reps} lần";
    } else if ((workout.duration ?? 0) > 0) {
      return "${workout.duration} phút${(workout.distance ?? 0) > 0 ? ' - ${workout.distance}km' : ''}";
    }
    return "Khởi động sức mạnh";
  }
}
