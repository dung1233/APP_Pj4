import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:training_souls/providers/workout_provider.dart';
import 'package:training_souls/screens/TEST/pushup_detector_view.dart';
import 'package:training_souls/screens/TEST/squat_detector_view.dart';
import 'package:training_souls/screens/Train/train_screen.dart';
import 'package:training_souls/screens/UI/Beginer/run.dart';
import 'package:training_souls/screens/UI/Beginer/situp.dart';

class Rest extends StatefulWidget {
  final int day;

  const Rest({Key? key, required this.day}) : super(key: key);

  @override
  State<Rest> createState() => _RestState();
}

class _RestState extends State<Rest> {
  int seconds = 30;
  Timer? timer;
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Colors
  static const Color primaryColor = Color(0xFFFF6B00);
  static const Color secondaryColor = Color(0xFF333333);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _loadWorkoutData();
    if (mounted) {
      startTimer();
    }
  }

  Future<void> _loadWorkoutData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final results = await _dbHelper.getAllWorkoutResults();
      debugPrint("Workout results: $results");
    } catch (e) {
      debugPrint("Error loading workout data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          timer.cancel();
          _goToNextScreen();
        }
      });
    });
  }

  // Hàm đồng bộ dữ liệu khi hoàn thành tất cả bài tập
  Future<void> _syncDataAfterCompletion() async {
    try {
      // Gọi hàm kiểm tra và đồng bộ workouts
      await _dbHelper.checkAndSyncWorkouts(widget.day);

      // Refresh WorkoutProvider
      if (mounted) {
        final workoutProvider =
            Provider.of<WorkoutProvider>(context, listen: false);
        await workoutProvider.refreshAfterDatabaseChange();
      }

      if (kDebugMode) {
        print(
            "[DEBUG] ✅ Đã hoàn thành đồng bộ dữ liệu sau khi hoàn thành tất cả bài tập");
      }
    } catch (e) {
      if (kDebugMode) {
        print("[DEBUG] ❌ Lỗi khi đồng bộ dữ liệu: $e");
      }
    }
  }

  // Hàm chuyển đến bài tập tiếp theo chưa hoàn thành
  Future<void> _goToNextScreen() async {
    if (_isLoading || !mounted) return;

    timer?.cancel();

    try {
      // Lấy danh sách bài tập của ngày
      final workouts = await _dbHelper.getWorkouts();
      final dayWorkouts = workouts.where((w) => w.day == widget.day).toList();

      if (dayWorkouts.isEmpty) {
        print("⚠️ Không có bài tập nào cho ngày ${widget.day}");
        Navigator.pop(context);
        return;
      }

      // Lấy danh sách kết quả đã hoàn thành
      final completedResults = await _dbHelper.getAllWorkoutResults();
      final todayCompletedExercises = completedResults
          .where((result) => result['day_number'] == widget.day)
          .map((result) => result['exercise_name'].toString().toLowerCase())
          .toSet();

      debugPrint("📋 Bài tập đã hoàn thành hôm nay: $todayCompletedExercises");

      // Tìm bài tập đầu tiên chưa hoàn thành
      Workout? nextWorkout;

      for (var workout in dayWorkouts) {
        String? exerciseName = workout.exerciseName?.toLowerCase();

        // Kiểm tra xem bài tập này đã có kết quả chưa
        bool isCompleted = false;
        if (exerciseName != null) {
          isCompleted = todayCompletedExercises.any((completedName) =>
              completedName.contains(exerciseName) ||
              exerciseName.contains(completedName) ||
              _normalizeExerciseName(completedName) ==
                  _normalizeExerciseName(exerciseName));
        }

        debugPrint(
            "🏃 Kiểm tra bài tập: ${workout.exerciseName} - Đã hoàn thành: $isCompleted");

        // Nếu chưa có kết quả, đây là bài tập tiếp theo
        if (!isCompleted) {
          nextWorkout = workout;
          break;
        }
      }

      // Nếu không tìm thấy bài tập chưa hoàn thành (đã hoàn thành hết)
      if (nextWorkout == null) {
        print("✅ Đã hoàn thành tất cả bài tập trong ngày ${widget.day}");

        // Gọi hàm đồng bộ dữ liệu khi hoàn thành tất cả bài tập
        await _syncDataAfterCompletion();

        if (mounted) {
          // Thay vì pop về màn hình trước, chuyển về TrainScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TrainScreen()),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text("Chúc mừng! Bạn đã hoàn thành tất cả bài tập hôm nay!"),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }

      // Danh sách các màn hình tập luyện
      final workoutScreens = {
        "hít đất": (int day) => PushUpDetectorView(day: day),
        "squat": (int day) => SquatDetectorView(day: day),
        "gập bụng": (int day) => SitUpDetectorPage(day: day),
        "chạy bộ": (int day) => RunningTracker(day: day),
      };

      // Tìm tên bài tập có trong map
      String? exerciseName = nextWorkout.exerciseName?.toLowerCase();
      String? matchedKey;

      if (exerciseName != null) {
        matchedKey = workoutScreens.keys.firstWhere(
          (key) =>
              exerciseName.contains(key) ||
              _normalizeExerciseName(exerciseName) ==
                  _normalizeExerciseName(key),
          orElse: () => "",
        );
      }

      print(
          "📋 Bài tập tiếp theo: ${nextWorkout.exerciseName} (matched: $matchedKey)");

      // Xử lý bài tập đặc biệt cần khởi tạo camera
      if (exerciseName?.contains("gập bụng") == true) {
        try {
          await initializeCameras();
        } catch (e) {
          debugPrint("Lỗi khởi tạo camera: $e");
        }
      }

      if (!mounted) return;

      // Chuyển đến màn hình tương ứng
      if (matchedKey != null && matchedKey.isNotEmpty) {
        await Future.delayed(const Duration(
            milliseconds: 500)); // Delay nhỏ để đảm bảo UI ổn định

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => workoutScreens[matchedKey]!(widget.day),
          ),
        );
      } else {
        // Nếu không tìm thấy bài tập phù hợp, quay về màn hình chính
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Không tìm thấy bài tập phù hợp cho: ${nextWorkout.exerciseName}"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error navigating to next screen: $e");
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Hàm chuẩn hóa tên bài tập để so sánh chính xác hơn
  String _normalizeExerciseName(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'),
            ' ') // Thay thế nhiều khoảng trắng bằng 1 khoảng trắng
        .replaceAll(' ', ''); // Loại bỏ tất cả khoảng trắng
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String get timerText {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/img/dayoff.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Text(
                  'Nghỉ Ngơi',
                  style: GoogleFonts.urbanist(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  timerText,
                  style: const TextStyle(
                    color: secondaryColor,
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.bold,
                    fontSize: 60,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Chuẩn bị cho bài tập tiếp theo',
                  style: GoogleFonts.urbanist(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    minimumSize: const Size(300, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    if (mounted) {
                      setState(() => seconds += 20);
                    }
                  },
                  child: Text(
                    '+20s',
                    style: GoogleFonts.urbanist(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(300, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    timer?.cancel();
                    _goToNextScreen();
                  },
                  child: Text(
                    'BỎ QUA',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
