// TODO Implement this library.
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:training_souls/screens/start/danhsachbaitap.dart';
import 'package:training_souls/screens/start/datatrain.dart';
import 'package:training_souls/screens/start/detailday.dart';
import 'package:training_souls/screens/start/detailrepset.dart';
import 'package:training_souls/screens/start/exercise_bottom_sheet.dart';

class Test extends StatefulWidget {
  const Test({super.key});
  @override
  // ignore: library_private_types_in_public_api
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
    displayWorkoutResults();
  }

  void displayWorkoutResults() async {
    final dbHelper = DatabaseHelper();
    final results = await dbHelper.getAllWorkoutResults();

    // In kết quả để debug
    print("Tất cả kết quả workout: $results");

    // Xử lý và hiển thị kết quả
    for (var result in results) {
      print("ID: ${result['id']}");
      print("Ngày: ${result['day_number']}");
      print("Tên bài tập: ${result['exercise_name']}");
      print("Sets hoàn thành: ${result['sets_completed']}");
      print("Reps hoàn thành: ${result['reps_completed']}");
      print("Khoảng cách hoàn thành: ${result['distance_completed']}");
      print("Thời gian hoàn thành: ${result['duration_completed']}");
      print("Ngày hoàn thành: ${result['completed_date']}");
      print("-----------------------");
    }
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
                    // ignore: deprecated_member_use
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Detailday(),
            ),

            // Thông số tổng quan
            Detailrepset(),
            // Danh sách bài tập
            Danhsachbaitap(),
          ],
        ),
      ),
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
  final String status;

  const WorkoutItem({
    super.key,
    required this.animationPath,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.duration,
    this.distance,
    required this.status,
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
            // ignore: deprecated_member_use
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
                  style: GoogleFonts.urbanist(
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
                    style: GoogleFonts.urbanist(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          if (status == "COMPLETED")
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.pending_outlined,
                color: Colors.orange,
                size: 24,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              switch (exerciseName.toLowerCase()) {
                case "squat":
                  showSquatExerciseDetails(context);
                  break;
                case "hít đất":
                  showPushupExerciseDetails(context);
                  break;
                case "gập bụng":
                  showSitUpExerciseDetails(context);
                  break;
                case "chạy bộ":
                  showRunerExerciseDetails(context);
                  break;
                // ...
              }
            },
          )
        ],
      ),
    );
  }

  void showSquatExerciseDetails(BuildContext context) {
    showExerciseBottomSheet(
      context: context,
      title: "GÁNH ĐÙI",
      animationAsset: "assets/img/Animation - 1743427831861.json",
      youtubeUrl: "https://www.youtube.com/watch?v=JANvVVsyZJE",
      guide: squatGuide,
      targetMuscles: ["Cơ mông", "Cơ đùi trước"],
    );
  }

  void showPushupExerciseDetails(BuildContext context) {
    showExerciseBottomSheet(
      context: context,
      title: "HÍT ĐẤT",
      animationAsset:
          "assets/img/Animation - 1742982248147.json", // Thay bằng file animation hít đất thực tế của bạn
      youtubeUrl:
          "https://www.youtube.com/watch?v=IODxDxX7oi4", // Link YouTube hướng dẫn hít đất
      guide: pushupGuide,
      targetMuscles: ["Cơ ngực", "Cơ vai", "Cơ tay trước"],
    );
  }

  void showSitUpExerciseDetails(BuildContext context) {
    showExerciseBottomSheet(
      context: context,
      title: "Gập bụng",
      animationAsset:
          "assets/img/Animation - 1743004318512.json", // Thay bằng file animation hít đất thực tế của bạn
      youtubeUrl:
          "https://www.youtube.com/watch?v=jDwoBqPH0jk", // Link YouTube hướng dẫn hít đất
      guide: situpGuide,
      targetMuscles: ["Cơ bụng"],
    );
  }

  void showRunerExerciseDetails(BuildContext context) {
    showExerciseBottomSheet(
      context: context,
      title: "chạy bộ",
      animationAsset:
          "assets/img/Animation - 1743005455297.json", // Thay bằng file animation hít đất thực tế của bạn
      youtubeUrl:
          "https://www.youtube.com/watch?v=_kGESn8ArrU&t=22s", // Link YouTube hướng dẫn hít đất
      guide: runnerGuide,
      targetMuscles: ["Cơ chan"],
    );
  }
}

// Tương tự cho gập bụng, chạy bộ...

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
      return "."; // default animation
  }
}
