// TODO Implement this library.
import 'package:flutter/foundation.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:training_souls/screens/TEST/pushup_detector_view.dart';
import 'package:training_souls/screens/UI/Beginer/pushup.dart';
import 'package:training_souls/screens/UI/Beginer/run.dart';
import 'package:training_souls/screens/UI/Beginer/situp.dart';
import 'package:training_souls/work.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
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

  double getWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  double getHeightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  int getTotalDuration() {
    return workouts.fold(0, (sum, workout) => sum + (workout.duration ?? 0));
  }

  int getTotalExercises() {
    return workouts.length;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (nextWorkout == null) {
      return const Center(child: Text("Không có bài tập nào"));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 1,
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            // Header với ảnh và thông tin chung
            Container(
              height: getHeightPercentage(context, 0.23),
              padding: const EdgeInsets.only(left: 25, top: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 5,
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage("assets/img/situp.jpg"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Column(
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
              ),
            ),

            // Thông số tổng quan
            Padding(
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
            ),

            // Danh sách bài tập
            Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Danh sách bài tập",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: getHeightPercentage(context, 0.52),
                  child: ListView.builder(
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      return WorkoutItem(
                        animationPath: workout.img ?? "",
                        exerciseName: workout.exerciseName ?? "Không tên",
                        sets: workout.sets ?? 0,
                        reps: workout.reps ?? 0,
                        duration: workout.duration,
                        distance: workout.distance,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      final today = nextWorkout?.day;
                      print("🗓 Đang tập ngày: $today");

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PushUpDetectorView(
                            day: today ?? 1, // Truyền ngày vào
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F00),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 120,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Bắt đầu",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

class WorkoutItem extends StatelessWidget {
  final String animationPath;
  final String exerciseName;
  final int sets;
  final int reps;
  final int? duration;
  final double? distance;

  const WorkoutItem({
    required this.animationPath,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.duration,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Lottie.asset(
              getAnimationPath(exerciseName),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exerciseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                if (sets > 0 && reps > 0) Text("$sets hiệp × $reps lần"),
                if (duration != null && duration! > 0)
                  Text(
                    "${duration} phút"
                    "${distance != null && distance! > 0 ? ' - ${distance}km' : ''}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 18),
        ],
      ),
    );
  }
}

String getAnimationPath(String name) {
  switch (name.toLowerCase()) {
    case "squat":
      return "assets/img/Animation - 1743427831861.json";
    case "hít đất":
      return "assets/img/Animation - 1742982248147.json";
    case "gập bụng":
      return "assets/img/Animation - 1743004318512.json";
    case "chạy bộ":
      return "assets/img/Animation - 1743005455297.json";
    default:
      return "assets/img/Animation - 1743004318512.json"; // default animation
  }
}
