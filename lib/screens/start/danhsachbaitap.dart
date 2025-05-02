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

  // Hàm kiểm tra trạng thái hoàn thành của một bài tập
  Future<bool> checkExerciseCompletion(int day, String exerciseName) async {
    final dbHelper = DatabaseHelper();
    final results = await dbHelper.getExerciseResults(day);

    // Kiểm tra xem bài tập có trong kết quả không
    for (var result in results) {
      if (result['exercise_name'] == exerciseName) {
        return true; // Đã hoàn thành
      }
    }

    return false; // Chưa hoàn thành
  }

  // Hàm cập nhật trạng thái hoàn thành cho tất cả bài tập
  Future<void> _updateCompletionStatus() async {
    final dbHelper = DatabaseHelper();
    bool anyChange = false; // Flag xem có gì thay đổi không

    for (var workout in workouts) {
      if (workout.day != null && workout.exerciseName != null) {
        bool isCompleted =
            await checkExerciseCompletion(workout.day!, workout.exerciseName!);

        if (isCompleted && workout.status != "COMPLETED") {
          await dbHelper.updateWorkoutStatus(workout.id!, "COMPLETED");
          workout.status = "COMPLETED";
          anyChange = true; // Có thay đổi
        }
      }
    }

    if (mounted && anyChange) {
      setState(() {}); // Chỉ setState nếu có thay đổi
    }
  }

  // Sử dụng logic đã có - tìm bài tập dựa trên status NOT_COMPLETED
  Future<void> _loadWorkoutsFromSQLite() async {
    setState(() => isLoading = true);

    final dbHelper = DatabaseHelper();
    final List<Workout> allWorkouts = await dbHelper.getWorkouts();

    if (allWorkouts.isEmpty) {
      if (kDebugMode) {
        print("⚠️ Không có dữ liệu trong SQLite.");
      }
      setState(() => isLoading = false);
      return;
    }

    // Giữ nguyên logic tìm bài tập dựa trên status NOT_COMPLETED
    final notStartedWorkout = allWorkouts.firstWhere(
      (workout) => workout.status == "NOT_COMPLETED",
      orElse: () => allWorkouts.first,
    );

    setState(() {
      nextWorkout = notStartedWorkout;
      // Lấy tất cả bài tập của ngày đó
      workouts = allWorkouts.where((w) => w.day == nextWorkout?.day).toList();
      isLoading = false;
    });

    // Cập nhật trạng thái hoàn thành sau khi tải dữ liệu
    await _updateCompletionStatus();
  }

  // Thêm hàm để người dùng có thể đánh dấu bài tập đã hoàn thành
  Future<void> markExerciseAsCompleted(
      int workoutId, String exerciseName, int day) async {
    final dbHelper = DatabaseHelper();

    // Lưu kết quả bài tập
    await dbHelper.insertExerciseResult(day, exerciseName);

    // Cập nhật trạng thái trong cơ sở dữ liệu
    await dbHelper.updateWorkoutStatus(workoutId, "COMPLETED");

    // Cập nhật lại danh sách
    await _loadWorkoutsFromSQLite();
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

  int getTotalDuration() {
    return workouts.fold(0, (sum, workout) => sum + (workout.duration ?? 0));
  }

  int getTotalExercises() {
    return workouts.length;
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
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else
          SizedBox(
            height: getHeightPercentage(context, 0.52),
            child: ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return GestureDetector(
                  onTap: () {
                    // Nếu bài tập chưa hoàn thành, hiển thị tùy chọn đánh dấu hoàn thành
                    if (workout.status != "COMPLETED" && workout.id != null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('${workout.exerciseName}'),
                          content: const Text(
                              'Bạn muốn đánh dấu bài tập này là đã hoàn thành?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                markExerciseAsCompleted(
                                  workout.id!,
                                  workout.exerciseName ?? "",
                                  workout.day ?? 1,
                                );
                              },
                              child: const Text('Đánh dấu hoàn thành'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: WorkoutItem(
                    animationPath: workout.img ?? "",
                    exerciseName: workout.exerciseName ?? "Không tên",
                    sets: workout.sets ?? 0,
                    reps: workout.reps ?? 0,
                    duration: workout.duration,
                    distance: workout.distance,
                    status: workout.status ?? "NOT_COMPLETED",
                  ),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              // Hiển thị thông tin ngày hiện tại
              // Text(
              //   "Ngày ${nextWorkout?.day ?? 0}",
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.grey[700],
              //   ),
              // ),
              // // Hiển thị thông tin về tổng thời gian và số bài tập
              // Text(
              //   "${getTotalDuration()} phút - ${getTotalExercises()} bài tập",
              //   style: TextStyle(
              //     fontSize: 14,
              //     color: Colors.grey[600],
              //   ),
              // ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final today = nextWorkout?.day;
                  if (today != null) {
                    print("🗓 Đang tập ngày: $today");
                    _navigateToTraining(today);
                  } else {
                    // Hiển thị thông báo lỗi nếu không có ngày
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Không có bài tập nào để bắt đầu."),
                      ),
                    );
                  }
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
            ],
          ),
        ),
      ],
    );
  }
}
