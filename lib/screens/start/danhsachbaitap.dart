import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:training_souls/screens/TEST/pushup_detector_view.dart';
import 'package:training_souls/screens/TEST/squat_detector_view.dart';
import 'package:training_souls/screens/UI/Beginer/run.dart';
import 'package:training_souls/screens/UI/Beginer/situp.dart';
import 'package:training_souls/screens/start/Test.dart';

class Danhsachbaitap extends StatefulWidget {
  const Danhsachbaitap({Key? key}) : super(key: key);

  @override
  _DanhsachbaitapState createState() => _DanhsachbaitapState();
}

class _DanhsachbaitapState extends State<Danhsachbaitap> {
  List<Workout> workouts = [];
  bool isLoading = true;
  Workout? nextWorkout;

  @override
  void initState() {
    super.initState();
    _loadWorkoutsFromSQLite();
  }

  double getWidthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  double getHeightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
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

  Future<void> _navigateToTraining(int day) async {
    final dbHelper = DatabaseHelper();
    // Lấy danh sách bài tập của ngày
    final dayWorkouts =
        (await dbHelper.getWorkouts()).where((w) => w.day == day).toList();

    // Tìm bài tập đầu tiên chưa hoàn thành
    Workout? nextWorkout;
    for (var workout in dayWorkouts) {
      if (workout.status != "COMPLETED" &&
          workout.exerciseName != null &&
          !workout.exerciseName!.toLowerCase().contains("nghỉ ngơi")) {
        nextWorkout = workout;
        break;
      }
    }

    // Nếu không có bài tập nào chưa hoàn thành, lấy bài đầu tiên
    nextWorkout ??= dayWorkouts.firstWhere(
        (w) =>
            w.exerciseName != null &&
            !w.exerciseName!.toLowerCase().contains("nghỉ ngơi"),
        orElse: () => dayWorkouts.first);

    // Chuyển đến bài tập tương ứng
    if (nextWorkout.exerciseName?.toLowerCase().contains("hít đất") == true) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PushUpDetectorView(day: day)));
    } else if (nextWorkout.exerciseName?.toLowerCase().contains("squat") ==
        true) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SquatDetectorView(day: day)));
    } else if (nextWorkout.exerciseName?.toLowerCase().contains("gập bụng") ==
        true) {
      await initializeCameras();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SitUpDetectorPage(day: day)));
    } else if (nextWorkout.exerciseName?.toLowerCase().contains("chạy bộ") ==
        true) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => RunningTracker(day: day)));
    } else {
      // Chuyển đến bài tập khác hoặc màn hình mặc định
      print(
          "⚠️ Không tìm thấy màn hình phù hợp cho bài tập: ${nextWorkout.exerciseName}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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

              _navigateToTraining(today!);
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
    );
  }
}
