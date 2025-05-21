import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:training_souls/providers/workout_provider.dart';
import 'package:dio/dio.dart';
import 'package:training_souls/api/user_service.dart';
import 'package:training_souls/Stripe/account_type_dialog.dart';
import 'package:training_souls/screens/Khampha/teacher_screen.dart';
import 'package:training_souls/data/local_storage.dart';
import 'package:training_souls/screens/trainhome.dart';
import 'dart:async'; // Thêm import Timer
import 'package:training_souls/services/notification_service.dart';
import 'package:training_souls/models/meal_suggestion.dart';
import 'package:training_souls/services/premium_trial_manager.dart';
import '../../../offline/SyncStatusWidget.dart';

class BeginnerDataWidget extends StatefulWidget {
  const BeginnerDataWidget({super.key});

  @override
  State<BeginnerDataWidget> createState() => _BeginnerDataWidgetState();
}

class _BeginnerDataWidgetState extends State<BeginnerDataWidget> {
  Timer? _timer; // Thêm biến timer
  final List<List<Workout>> weeks = [];
  final Map<int, bool> expandedDays = {};
  final dbHelper = DatabaseHelper();
  bool isUpdating = false;
  bool hasExistingCoach = false; // Thêm biến để lưu trạng thái kiểm tra

  // Cache cho trạng thái hoàn thành
  final Map<String, bool> _completionCache = {};

  final List<String> workoutBackgrounds = [
    "assets/img/run.jpg",
    "assets/img/gapbung.jpg",
    "assets/img/pushup.jpg",
    "assets/img/squat.jpg",
    "assets/img/OP5.jpg",
  ];

  String getRandomImageForDay(int day) {
    final random = Random(day);
    return workoutBackgrounds[random.nextInt(workoutBackgrounds.length)];
  }

  Future<bool> checkExerciseCompletion(int day, String exerciseName) async {
    final cacheKey = "$day-$exerciseName";
    if (_completionCache.containsKey(cacheKey)) {
      return _completionCache[cacheKey]!;
    }

    try {
      final results = await dbHelper.getExerciseResults(day);
      debugPrint(
          "DEBUG: Results for day $day: $results"); // Kiểm tra dữ liệu trả về
      final isCompleted =
          results.any((result) => result['exercise_name'] == exerciseName);

      _completionCache[cacheKey] = isCompleted;
      return isCompleted;
    } catch (e) {
      debugPrint("Error checking exercise completion: $e");
      return false;
    }
  }

  Future<void> _updateCompletionStatus(List<Workout> workouts) async {
    if (isUpdating) return;

    setState(() {
      isUpdating = true;
    });

    try {
      bool anyChange = false;

      for (var workout in workouts) {
        if (workout.day != null &&
            workout.exerciseName != null &&
            workout.id != null) {
          bool isCompleted = await checkExerciseCompletion(
              workout.day!, workout.exerciseName!);

          if (isCompleted && workout.status != "COMPLETED") {
            await dbHelper.updateWorkoutStatus(workout.id!, "COMPLETED");
            workout.status = "COMPLETED";
            anyChange = true;
          }
        }
      }

      if (mounted && anyChange) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error updating completion status: $e");
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  // Thêm biến để lưu thời gian đã đặt lịch
  DateTime? _scheduledTime;

  // Hàm lưu thời gian đã đặt lịch
  Future<void> _saveScheduledTime(DateTime time) async {
    await LocalStorage.saveData('scheduled_test_time', time.toIso8601String());
  }

  // Hàm lấy thời gian đã đặt lịch
  Future<void> _loadScheduledTime() async {
    final timeStr = await LocalStorage.getData('scheduled_test_time');
    if (timeStr != null) {
      final scheduledTime = DateTime.parse(timeStr);
      if (scheduledTime.isAfter(DateTime.now())) {
        setState(() {
          _scheduledTime = scheduledTime;
        });
      } else {
        // Nếu thời gian đã qua, xóa khỏi storage
        await LocalStorage.removeData('scheduled_test_time');
      }
    }
  }

  // Thêm hàm để lưu ID huấn luyện viên đã chọn
  Future<void> _saveSelectedCoachId(String coachId) async {
    await LocalStorage.saveData('selected_coach_id', coachId);
  }

  // Thêm hàm để load ID huấn luyện viên đã chọn
  Future<void> _loadSelectedCoachId() async {
    final coachId = await LocalStorage.getData('selected_coach_id');
    if (coachId != null) {
      setState(() {
        _selectedTrainerId = coachId;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _completionCache.clear();
    // Đảm bảo dữ liệu được tải khi widget khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureDataLoaded();
      _syncWorkoutStatusFromResults();
      _loadScheduledTime();
      _loadSelectedCoachId();
      _startTimer();
      checkExistingCoach();
      _checkPremiumTrial(); // Thêm dòng này
    });
  }

  // Thêm hàm mới để kiểm tra thời gian dùng thử Premium
  Future<void> _checkPremiumTrial() async {
    try {
      // Kiểm tra và hiển thị popup nếu hết thời gian dùng thử
      await PremiumTrialManager.checkAndShowTrialExpiredPopup(context);
    } catch (e) {
      print("❌ Lỗi khi kiểm tra thời gian dùng thử: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy timer khi widget bị dispose
    super.dispose();
  }

  // Thêm phương thức để bắt đầu timer
  void _startTimer() {
    _timer?.cancel(); // Hủy timer cũ nếu có
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Cập nhật UI mỗi giây
        });
      }
    });
  }

  Future<void> _syncWorkoutStatusFromResults() async {
    try {
      final provider = Provider.of<WorkoutProvider>(context, listen: false);
      final workouts = provider.workouts;
      bool hasChanges = false;

      for (var workout in workouts) {
        if (workout.day != null && workout.exerciseName != null) {
          final isCompleted = await checkExerciseCompletion(
              workout.day!, workout.exerciseName!);

          if (isCompleted && workout.status != "COMPLETED") {
            workout.status = "COMPLETED";
            hasChanges = true;

            // Cập nhật trạng thái trong SQLite
            if (workout.id != null) {
              await dbHelper.updateWorkoutStatus(workout.id!, "COMPLETED");
            }

            // Cập nhật cache
            _completionCache["${workout.day}-${workout.exerciseName}"] = true;
          }
        }
      }

      // Cập nhật provider
      if (hasChanges) {
        provider.updateWorkouts([...workouts]);
      }

      // Cập nhật UI
      if (hasChanges && mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error syncing status from results: $e");
    }
  }

  Future<void> _ensureDataLoaded() async {
    // Lấy provider từ context
    final provider = Provider.of<WorkoutProvider>(context, listen: false);

    // Kiểm tra và tải dữ liệu nếu cần
    if (provider.workouts.isEmpty && !provider.isLoading) {
      debugPrint("DEBUG: BeginnerDataWidget triggering workout reload");
      await provider.loadWorkoutsFromSQLite();
    }
  }

  Future<void> saveExerciseResult(int day, String exerciseName) async {
    try {
      await dbHelper.insertExerciseResult(day, exerciseName);

      // Cập nhật cache
      _completionCache["$day-$exerciseName"] = true;

      await _updateCompletionStatus(context.read<WorkoutProvider>().workouts);
    } catch (e) {
      debugPrint("Error saving exercise result: $e");
    }
  }

  List<List<Workout>> _groupWorkoutsByWeek(List<Workout> allWorkouts) {
    if (allWorkouts.isEmpty) {
      debugPrint("⚠️ Không có dữ liệu bài tập.");
      return [];
    }

    // Nhóm bài tập theo ngày
    Map<int, List<Workout>> workoutsByDay = {};
    for (var workout in allWorkouts) {
      if (workout.day != null) {
        workoutsByDay.putIfAbsent(workout.day!, () => []).add(workout);
      }
    }

    // Chuyển thành danh sách tuần (mỗi tuần 7 ngày)
    List<List<Workout>> groupedWeeks = [];
    List<Workout> currentWeek = [];
    var sortedDays = workoutsByDay.keys.toList()..sort();

    for (int day in sortedDays) {
      currentWeek.addAll(workoutsByDay[day]!);
      if (day % 7 == 0 || day == sortedDays.last) {
        groupedWeeks.add(currentWeek);
        currentWeek = [];
      }
    }

    return groupedWeeks;
  }

  // Tính toán số ngày đã hoàn thành trong tuần
  int _getCompletedDaysInWeek(List<Workout> weekWorkouts) {
    final Map<int, List<Workout>> workoutsByDay = {};
    for (var workout in weekWorkouts) {
      if (workout.day != null) {
        workoutsByDay.putIfAbsent(workout.day!, () => []).add(workout);
      }
    }

    int completedDays = 0;
    for (var day in workoutsByDay.keys) {
      final workouts = workoutsByDay[day]!;
      final completedAll = workouts.every((w) =>
          w.status == "COMPLETED" ||
          (w.exerciseName?.toLowerCase().contains("nghỉ ngơi") ?? false));

      if (completedAll) completedDays++;
    }

    return completedDays;
  }

  // Thay đổi cách quản lý loading state
  int? _loadingDay;

  void _showNutritionAdvice(int day) async {
    // Kiểm tra nếu ngày này đang loading thì không cho phép ấn tiếp
    if (_loadingDay == day) return;

    try {
      setState(() {
        _loadingDay = day;
      });

      // Lấy token
      final token = await LocalStorage.getValidToken();
      if (token == null) {
        throw Exception("Token không tồn tại");
      }

      // Tìm workout cho ngày được chọn
      final provider = Provider.of<WorkoutProvider>(context, listen: false);
      final dayWorkouts = provider.workouts.where((w) => w.day == day).toList();

      if (dayWorkouts.isEmpty || dayWorkouts.first.workoutDate == null) {
        throw Exception("Không tìm thấy thông tin ngày tập");
      }

      // Format ngày theo yêu cầu của API
      final workoutDate = DateTime.parse(dayWorkouts.first.workoutDate!);
      final formattedDate =
          "${workoutDate.year}-${workoutDate.month.toString().padLeft(2, '0')}-${workoutDate.day.toString().padLeft(2, '0')}";

      // Gọi API với timeout
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);

      final response = await dio.get(
        "http://54.251.220.228:8080/trainingSouls/meals/suggest?date=$formattedDate",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        final mealSuggestion = MealSuggestion.fromJson(response.data);

        // Parse kết quả thành các phần thành dữ liệu 3 bữa rồi truyền vào thì chỉ có 1 bữa được hiển thị
        //Nên việc còn lại thực ra chỉ là tách hiển thị thôi
        final meals = mealSuggestion.result.split('\n\n');

        if (!mounted) return;

        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tư vấn dinh dưỡng - Ngày $day",
                  style: GoogleFonts.urbanist(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: meals.map((meal) {
                        final parts = meal.split('\n');
                        final title = parts[0].replaceAll(':', '');

                        // Tìm phần "Nên ăn" và "Không nên ăn"
                        final shouldEatIndex =
                            parts.indexWhere((p) => p.contains('- Nên ăn:'));
                        final shouldNotEatIndex = parts
                            .indexWhere((p) => p.contains('- Không nên ăn:'));

                        // Lấy danh sách món nên ăn
                        List<String> shouldEatItems = [];
                        if (shouldEatIndex != -1) {
                          final shouldEatText = parts[shouldEatIndex]
                              .replaceAll('- Nên ăn:', '')
                              .trim();
                          shouldEatItems = shouldEatText
                              .split(', ')
                              .map((item) => item.trim())
                              .toList();
                        }

                        // Lấy danh sách món không nên ăn
                        List<String> shouldNotEatItems = [];
                        if (shouldNotEatIndex != -1) {
                          final shouldNotEatText = parts[shouldNotEatIndex]
                              .replaceAll('- Không nên ăn:', '')
                              .trim();
                          shouldNotEatItems = shouldNotEatText
                              .split(', ')
                              .map((item) => item.trim())
                              .toList();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMealSection(
                              title,
                              _getMealIcon(title),
                              shouldEatItems,
                              shouldNotEatItems,
                            ),
                            const SizedBox(height: 15),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        throw Exception("Lỗi khi lấy dữ liệu: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Lỗi khi lấy tư vấn dinh dưỡng: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Có lỗi xảy ra: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingDay = null;
        });
      }
    }
  }

  IconData _getMealIcon(String mealTitle) {
    switch (mealTitle.toLowerCase()) {
      case 'bữa sáng':
        return Icons.breakfast_dining;
      case 'bữa trưa':
        return Icons.restaurant;
      case 'bữa tối':
        return Icons.dinner_dining;
      default:
        return Icons.fastfood;
    }
  }

  Widget _buildMealSection(String title, IconData icon, List<String> shouldEat,
      List<String> shouldNotEat) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFF6F00), size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.urbanist(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (shouldEat.isNotEmpty) ...[
            Text(
              "Nên ăn:",
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 5),
            ...shouldEat.map((item) => Padding(
                  padding: const EdgeInsets.only(left: 34, bottom: 5),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.urbanist(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (shouldNotEat.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              "Không nên ăn:",
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 5),
            ...shouldNotEat.map((item) => Padding(
                  padding: const EdgeInsets.only(left: 34, bottom: 5),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.urbanist(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        if (provider.workouts.isEmpty && !provider.isLoading) {
          // Thử tải lại dữ liệu một lần nữa
          Future.microtask(() => provider.ensureWorkoutsLoaded());
        }

        final weeks = _groupWorkoutsByWeek(provider.workouts);
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : weeks.isEmpty
                  ? const Center(child: Text("Không có bài tập nào."))
                  : Column(
                      children: weeks.asMap().entries.map((entry) {
                        int weekIndex = entry.key;
                        final weekData = entry.value;
                        final Map<int, List<Workout>> workoutsByDay = {};
                        for (var workout in weekData) {
                          if (workout.day != null) {
                            workoutsByDay
                                .putIfAbsent(workout.day!, () => [])
                                .add(workout);
                          }
                        }

                        // Tính số ngày đã hoàn thành
                        final completedDays = _getCompletedDaysInWeek(weekData);
                        final totalDays = workoutsByDay.length;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [
                                          Color(0xFFFF6F00),
                                          Color(0xFFFF6F00)
                                        ]),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Week ${weekIndex + 1}',
                                        style: GoogleFonts.urbanist(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              workoutsByDay.isEmpty
                                  ? Center(
                                      child: Text(
                                          "Không có bài tập trong tuần này"),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: workoutsByDay.keys.length,
                                      itemBuilder: (context, index) {
                                        final day =
                                            workoutsByDay.keys.elementAt(index);
                                        final dayWorkouts =
                                            workoutsByDay[day] ?? [];
                                        final completedCount = dayWorkouts
                                            .where(
                                                (w) => w.status == "COMPLETED")
                                            .length;
                                        final isExpanded =
                                            expandedDays[day] ?? false;

                                        return _buildDayCard(day, dayWorkouts,
                                            completedCount, isExpanded);
                                      },
                                    ),
                              // Thêm card kiểm tra tuần

                              _buildWeeklyTestCard(weekIndex + 1),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
        );
      },
    );
  }

  // Tách biệt widget cho từng ngày để code rõ ràng hơn
  Widget _buildDayCard(
      int day, List<Workout> dayWorkouts, int completedCount, bool isExpanded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    expandedDays[day] = !isExpanded;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.93,
                  height: MediaQuery.of(context).size.height * 0.15,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 5),
                        blurRadius: 10,
                      ),
                    ],
                    image: DecorationImage(
                      image: AssetImage(getRandomImageForDay(day)),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.6),
                        BlendMode.multiply,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Ngày $day",
                            style: GoogleFonts.urbanist(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getCompletionColor(
                                  completedCount, dayWorkouts.length),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$completedCount/${dayWorkouts.length} bài hoàn thành",
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.black45,
                        radius: 18,
                        child: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Nút tư vấn dinh dưỡng
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _handleNutritionButtonClick(day),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: _loadingDay == day
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF6F00)),
                            ),
                          )
                        : const Icon(
                            Icons.restaurant_menu,
                            color: Color(0xFFFF6F00),
                            size: 20,
                          ),
                  ),
                ),
              ),
            ],
          ),
          if (isExpanded)
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: dayWorkouts
                    .map((workout) => _buildWorkoutItem(workout))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkoutItem(Workout workout) {
    final isRestDay =
        workout.exerciseName?.toLowerCase().contains("nghỉ ngơi") ?? false;
    final displayStatus = isRestDay ? "NOT_STARTED" : workout.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              "assets/img/OP5.jpg",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.exerciseName ?? "Không tên",
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                if (workout.sets != null &&
                    workout.reps != null &&
                    workout.sets! > 0 &&
                    workout.reps! > 0)
                  Text(
                    "${workout.sets} hiệp × ${workout.reps} lần",
                    style: GoogleFonts.urbanist(color: Colors.grey[600]),
                  ),
                if (workout.duration != null && workout.duration! > 0)
                  Text(
                    "${workout.duration} phút${workout.distance != null && workout.distance! > 0 ? ' - ${workout.distance}km' : ''}",
                    style: GoogleFonts.urbanist(color: Colors.grey[600]),
                  ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(workout.status),
                  style: GoogleFonts.urbanist(
                    color: _getStatusColor(workout.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          isUpdating && workout.id != null
              ? const SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : InkWell(
                  onTap: isRestDay ? null : () => _toggleWorkoutStatus(workout),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: displayStatus == "COMPLETED"
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                    ),
                    child: Icon(
                      displayStatus == "COMPLETED"
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: displayStatus == "COMPLETED"
                          ? const Color.fromARGB(255, 14, 228, 50)
                          : Colors.grey,
                      size: 25,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case "COMPLETED":
        return "Đã hoàn thành";
      case "MISSED":
        return "Đã bỏ lỡ";
      case "NOT_STARTED":
        return "Chưa bắt đầu";
      default:
        return "Chưa bắt đầu";
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "COMPLETED":
        return Colors.green;
      case "MISSED":
        return Colors.orange;
      case "NOT_STARTED":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Hàm trả về màu dựa trên số lượng bài tập đã hoàn thành
  Color _getCompletionColor(int completedCount, int totalCount) {
    if (completedCount == 0) {
      return Colors.red.withOpacity(0.8); // Chưa hoàn thành bài nào thì màu đỏ
    } else if (completedCount >= 4) {
      return Colors.green
          .withOpacity(0.8); // Hoàn thành từ 4 bài trở lên thì màu xanh
    } else {
      return Colors.orange.withOpacity(0.8); // Hoàn thành 1-3 bài thì màu vàng
    }
  }

  void _toggleWorkoutStatus(Workout workout) async {
    if (workout.id == null) {
      debugPrint("❌ Không thể cập nhật trạng thái: Workout ID is null");
      return;
    }

    // Hiển thị loader trong quá trình cập nhật
    setState(() {
      isUpdating = true;
    });

    try {
      final newStatus =
          workout.status == "COMPLETED" ? "NOT_STARTED" : "COMPLETED";

      // Thực hiện cập nhật trong DB
      await dbHelper.updateWorkoutStatus(workout.id!, newStatus);

      // Cập nhật vào workout_results nếu là COMPLETED
      if (newStatus == "COMPLETED" &&
          workout.day != null &&
          workout.exerciseName != null) {
        await dbHelper.insertWorkoutResult(workout.day!, {
          'exercise_name': workout.exerciseName,
          'sets_completed': workout.sets,
          'reps_completed': workout.reps,
          'distance_completed': workout.distance,
          'duration_completed': workout.duration,
          'completed_date': DateTime.now().toIso8601String()
        });
      } else if (newStatus == "NOT_STARTED" &&
          workout.day != null &&
          workout.exerciseName != null) {
        // Xóa khỏi workout_results nếu chuyển về NOT_STARTED
        final db = await dbHelper.database;
        await db.delete('workout_results',
            where: 'day_number = ? AND exercise_name = ?',
            whereArgs: [workout.day, workout.exerciseName]);
      }

      // Cập nhật cache
      if (workout.day != null && workout.exerciseName != null) {
        final cacheKey = "${workout.day}-${workout.exerciseName}";
        _completionCache[cacheKey] = newStatus == "COMPLETED";
      }

      // Cập nhật UI
      setState(() {
        workout.status = newStatus;
      });

      // Cập nhật trong Provider
      final provider = context.read<WorkoutProvider>();
      final updatedWorkouts = provider.workouts.map((w) {
        if (w.id == workout.id) {
          return Workout(
            id: w.id,
            exerciseName: w.exerciseName,
            status: newStatus,
            day: w.day,
            sets: w.sets,
            reps: w.reps,
            duration: w.duration,
            distance: w.distance,
          );
        }
        return w;
      }).toList();
      provider.updateWorkouts(updatedWorkouts);
    } catch (e) {
      debugPrint("❌ Lỗi khi cập nhật trạng thái bài tập: $e");
    } finally {
      // Tắt loader
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  Widget _buildWeeklyTestCard(int weekNumber) {
    final bool isTestTime = _isTestTimeReached();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6F00).withOpacity(0.3),
            offset: const Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Bài kiểm tra tuần $weekNumber",
                  style: GoogleFonts.urbanist(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "30 phút",
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Kiểm tra tiến độ và đánh giá kết quả sau một tuần tập luyện",
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 15,
            runSpacing: 10,
            children: [
              _buildTestFeature(Icons.fitness_center, "5 bài tập"),
              _buildTestFeature(Icons.timer, "30 phút"),
              _buildTestFeature(Icons.emoji_events, "Chứng nhận"),
            ],
          ),
          const SizedBox(height: 20),
          if (_scheduledTime != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    isTestTime ? 'Đã đến giờ kiểm tra' : 'Đã đặt lịch kiểm tra',
                    style: GoogleFonts.urbanist(
                      color:
                          isTestTime ? Colors.green : const Color(0xFFFF6F00),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lúc ${_scheduledTime!.hour}:${_scheduledTime!.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.urbanist(
                      color: const Color(0xFFFF6F00),
                      fontSize: 14,
                    ),
                  ),
                  if (_selectedTrainerId != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person,
                          color: Color(0xFFFF6F00),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedTrainerId != null
                              ? trainerInfo.values.firstWhere(
                                  (t) => t['id'] == _selectedTrainerId,
                                  orElse: () => {'name': 'Unknown'},
                                )['name']
                              : 'Unknown',
                          style: GoogleFonts.urbanist(
                            color: const Color(0xFFFF6F00),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!isTestTime) ...[
                    const SizedBox(height: 8),
                    Text(
                      _getRemainingTimeText(),
                      style: GoogleFonts.urbanist(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isTestTime) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VideoCallScreen(),
                      ),
                    );
                  } else {
                    _showTestOptionsDialog(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6F00),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isTestTime ? "Vào phòng ngay" : "Xem chi tiết",
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleTestButtonClick(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF6F00),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Đăng ký kiểm tra",
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Thêm phương thức để lấy text thời gian còn lại
  String _getRemainingTimeText() {
    if (_scheduledTime == null) return '';

    final now = DateTime.now();
    final difference = _scheduledTime!.difference(now);

    if (difference.isNegative) {
      return 'Đã đến giờ kiểm tra';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    return 'Còn ${hours}h ${minutes}m ${seconds}s';
  }

  Widget _buildTestFeature(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Hàm kiểm tra xem khung giờ có khả dụng không
  bool _isTimeSlotAvailable(TimeOfDay slot) {
    final now = DateTime.now();
    final slotDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      slot.hour,
      slot.minute,
    );
    return now.isBefore(slotDateTime);
  }

  // Thêm biến để lưu huấn luyện viên đã chọn
  String? _selectedTrainerId;

  // Thêm map chứa thông tin huấn luyện viên
  final Map<String, Map<String, dynamic>> trainerInfo = {
    'trainer1': {
      'id': '946869671',
      'name': 'Nguyễn Văn An',
      'specialty': 'Huấn luyện viên Thể lực',
      'experience': '5 năm kinh nghiệm',
      'certifications': [
        'Chứng chỉ huấn luyện viên quốc tế',
        'Chứng chỉ dinh dưỡng thể thao',
      ],
      'image': 'assets/img/coach.jpg',
      'description':
          'Chuyên gia về cải thiện thể lực và sức bền, có kinh nghiệm làm việc với vận động viên chuyên nghiệp.',
    },
    'trainer2': {
      'id': '104641193',
      'name': 'Trần Thị Bích',
      'specialty': 'Huấn luyện viên Tốc độ',
      'experience': '4 năm kinh nghiệm',
      'certifications': [
        'Chứng chỉ huấn luyện tốc độ',
        'Chứng chỉ phục hồi chấn thương',
      ],
      'image': 'assets/img/coachrun.jpg',
      'description':
          'Chuyên gia về cải thiện tốc độ và kỹ thuật chạy, giúp học viên đạt được mục tiêu cá nhân.',
    },
    'trainer3': {
      'id': '161411928',
      'name': 'Lê Văn Cường',
      'specialty': 'Huấn luyện viên Sức mạnh',
      'experience': '6 năm kinh nghiệm',
      'certifications': [
        'Chứng chỉ huấn luyện sức mạnh',
        'Chứng chỉ CrossFit Level 2',
      ],
      'image': 'assets/img/coachpush.jpg',
      'description':
          'Chuyên gia về phát triển sức mạnh và cơ bắp, có kinh nghiệm với nhiều môn thể thao khác nhau.',
    },
  };

  void _showTrainerSelectionDialog(BuildContext context) async {
    // Kiểm tra xem đã có huấn luyện viên được chọn chưa
    if (_selectedTrainerId != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Thông báo',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF6F00),
              ),
            ),
            content: Text(
              'Bạn đã đăng ký huấn luyện viên rồi, không thể thay đổi',
              style: GoogleFonts.urbanist(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Đã hiểu',
                  style: GoogleFonts.urbanist(
                    color: const Color(0xFFFF6F00),
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    final PageController pageController = PageController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.8,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chọn Huấn luyện viên',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: trainerInfo.length,
                    itemBuilder: (context, index) {
                      final trainer = trainerInfo.values.elementAt(index);
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                trainer['image'],
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              trainer['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              trainer['specialty'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.work_history,
                                      color: Colors.orange),
                                  const SizedBox(width: 10),
                                  Text(
                                    trainer['experience'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Chứng chỉ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...trainer['certifications'].map<Widget>((cert) =>
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.green, size: 20),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          cert,
                                          style: const TextStyle(fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    final token =
                                        await LocalStorage.getValidToken();
                                    if (token == null) {
                                      throw Exception("Token không tồn tại");
                                    }

                                    print(
                                        "🔍 Attempting to select coach with ID: ${trainer['id']}");

                                    final dio = Dio();
                                    dio.interceptors.add(LogInterceptor(
                                      request: true,
                                      requestHeader: true,
                                      requestBody: true,
                                      responseHeader: true,
                                      responseBody: true,
                                      error: true,
                                    ));

                                    final userService = UserService(dio);
                                    try {
                                      await userService.selectCoach(
                                        "Bearer $token",
                                        trainer['id'].toString(),
                                      );

                                      // Lưu ID huấn luyện viên đã chọn
                                      await _saveSelectedCoachId(
                                          trainer['id'].toString());

                                      setState(() {
                                        _selectedTrainerId = trainer['id'];
                                      });
                                      Navigator.pop(context);
                                      // Hiển thị lại dialog chọn thời gian
                                      _showScheduleDialog(context);
                                    } catch (e) {
                                      if (e is DioException &&
                                          e.response?.statusCode == 500) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Bạn đã đăng ký huấn luyện viên này hoặc một huấn luyện viên khác rồi"),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        rethrow;
                                      }
                                    }
                                  } catch (e) {
                                    print("❌ Lỗi khi chọn huấn luyện viên: $e");
                                    if (e is DioException) {
                                      print(
                                          "🔍 Response data: ${e.response?.data}");
                                      print(
                                          "🔍 Response headers: ${e.response?.headers}");
                                      print(
                                          "🔍 Request data: ${e.requestOptions.data}");
                                      print(
                                          "🔍 Request path: ${e.requestOptions.path}");
                                    }
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Có lỗi xảy ra khi chọn huấn luyện viên: ${e.toString()}"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B00),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _selectedTrainerId == trainer['id']
                                      ? 'Đã chọn'
                                      : 'Chọn huấn luyện viên này',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    trainerInfo.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pageController.hasClients &&
                                pageController.page?.round() == index
                            ? const Color(0xFFFF6B00)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Thêm biến để lưu timer cho đếm ngược
  Timer? _countdownTimer;

  void _startCountdownTimer(StateSetter setState) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Cập nhật UI mỗi giây
        });
      }
    });
  }

  // Hàm hiển thị dialog đặt lịch
  void _showScheduleDialog(BuildContext context) {
    final now = DateTime.now();

    // Lưu trữ thời gian đã chọn
    DateTime? selectedTime;

    // Xác định thời gian hiện tại cho giới hạn chọn lịch
    final currentHour = now.hour;
    final currentMinute = now.minute;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Kiểm tra xem thời gian đã chọn có hợp lệ không (không phải thời gian đã qua)
            bool isTimeValid() {
              if (selectedTime == null) return false;

              // Nếu là cùng ngày, kiểm tra giờ và phút
              if (selectedTime!.year == now.year &&
                  selectedTime!.month == now.month &&
                  selectedTime!.day == now.day) {
                return selectedTime!.hour > currentHour ||
                    (selectedTime!.hour == currentHour &&
                        selectedTime!.minute > currentMinute);
              }

              // Nếu là ngày khác, luôn hợp lệ
              return selectedTime!.isAfter(now);
            }

            return AlertDialog(
              title: Text(
                'Chọn thời gian kiểm tra',
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Chọn huấn luyện viên
                      Container(
                        width: double.infinity,
                        child: !hasExistingCoach
                            ? ElevatedButton.icon(
                                onPressed: () =>
                                    _showTrainerSelectionDialog(context),
                                icon: const Icon(Icons.person),
                                label: Text(
                                  _selectedTrainerId != null
                                      ? 'HLV: ${trainerInfo.values.firstWhere((t) => t['id'] == _selectedTrainerId)['name']}'
                                      : 'Chọn huấn luyện viên',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedTrainerId != null
                                      ? Colors.green
                                      : const Color(0xFFFF6B00),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Đã có huấn luyện viên',
                                      style: GoogleFonts.urbanist(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),

                      const SizedBox(height: 20),

                      // Chọn ngày
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chọn ngày:',
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final DateTime? pickedDate =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: now,
                                  lastDate: now.add(const Duration(days: 30)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFFFF6B00),
                                          onPrimary: Colors.white,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    if (selectedTime != null) {
                                      // Giữ nguyên giờ và phút, chỉ cập nhật ngày
                                      selectedTime = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        selectedTime!.hour,
                                        selectedTime!.minute,
                                      );
                                    } else {
                                      // Nếu chưa chọn giờ, mặc định là giờ hiện tại + 1
                                      final defaultHour = (now.hour + 1) % 24;
                                      selectedTime = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        defaultHour,
                                        0,
                                      );
                                    }
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedTime != null
                                          ? '${selectedTime!.day}/${selectedTime!.month}/${selectedTime!.year}'
                                          : 'Chọn ngày',
                                      style: GoogleFonts.urbanist(),
                                    ),
                                    const Icon(Icons.calendar_today, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Chọn giờ
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chọn giờ:',
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final TimeOfDay? pickedTime =
                                    await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime != null
                                      ? TimeOfDay(
                                          hour: selectedTime!.hour,
                                          minute: selectedTime!.minute)
                                      : TimeOfDay(
                                          hour: (now.hour + 1) % 24, minute: 0),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFFFF6B00),
                                          onPrimary: Colors.white,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (pickedTime != null) {
                                  setState(() {
                                    if (selectedTime != null) {
                                      // Giữ nguyên ngày, chỉ cập nhật giờ và phút
                                      selectedTime = DateTime(
                                        selectedTime!.year,
                                        selectedTime!.month,
                                        selectedTime!.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );
                                    } else {
                                      // Nếu chưa chọn ngày, mặc định là ngày hiện tại
                                      selectedTime = DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );
                                    }
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedTime != null
                                          ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                          : 'Chọn giờ',
                                      style: GoogleFonts.urbanist(),
                                    ),
                                    const Icon(Icons.access_time, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Nút đặt lịch
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_selectedTrainerId != null &&
                                  selectedTime != null &&
                                  isTimeValid())
                              ? () async {
                                  try {
                                    final token =
                                        await LocalStorage.getValidToken();
                                    if (token == null) {
                                      throw Exception("Token không tồn tại");
                                    }

                                    // Format date string cho API theo định dạng yyyy-MM-ddTHH:mm:00
                                    final dateStr = "${selectedTime!.year}-"
                                        "${selectedTime!.month.toString().padLeft(2, '0')}-"
                                        "${selectedTime!.day.toString().padLeft(2, '0')}T"
                                        "${selectedTime!.hour.toString().padLeft(2, '0')}:"
                                        "${selectedTime!.minute.toString().padLeft(2, '0')}:00";

                                    final dio = Dio();
                                    dio.options.headers["Authorization"] =
                                        "Bearer $token";
                                    dio.options.headers["Content-Type"] =
                                        "application/json";

                                    // Gọi API với endpoint đúng format
                                    final response = await dio.post(
                                        "http://54.251.220.228:8080/trainingSouls/notifications/notifyCoachLevelTest/$dateStr");

                                    if (response.statusCode == 200) {
                                      await _saveScheduledTime(selectedTime!);
                                      this.setState(() {
                                        _scheduledTime = selectedTime;
                                      });

                                      // Thêm thông báo nhắc nhở trước 1 phút
                                      final notificationTime = selectedTime!
                                          .subtract(Duration(minutes: 1));
                                      await NotificationService()
                                          .scheduleNotification(
                                        title: 'Chuẩn bị kiểm tra! ⏰',
                                        body:
                                            'Bạn có lịch kiểm tra với ${trainerInfo.values.firstWhere((t) => t['id'] == _selectedTrainerId)['name']} trong 1 phút nữa! 💪',
                                        scheduledDate: notificationTime,
                                      );
                                      Navigator.pop(context);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Đã đặt lịch kiểm tra lúc ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')} ngày ${selectedTime!.day}/${selectedTime!.month}/${selectedTime!.year} với ${trainerInfo.values.firstWhere((t) => t['id'] == _selectedTrainerId)['name']}',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const Trainhome(),
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                    } else {
                                      throw Exception(
                                          "Lỗi khi gửi thông báo: ${response.statusCode}");
                                    }
                                  } catch (e) {
                                    print("❌ Lỗi khi gửi thông báo: $e");
                                    if (e is DioException) {
                                      print(
                                          "Response data: ${e.response?.data}");
                                      print(
                                          "Response status: ${e.response?.statusCode}");
                                    }
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Có lỗi xảy ra khi đặt lịch: ${e.toString()}"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_selectedTrainerId != null &&
                                    selectedTime != null &&
                                    isTimeValid())
                                ? Colors.green
                                : Colors.grey,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: Text(
                            'Đặt lịch kiểm tra',
                            style: GoogleFonts.urbanist(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Thông báo lỗi nếu có
                      if (selectedTime != null && !isTimeValid())
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            'Không thể chọn thời gian đã qua. Vui lòng chọn thời gian khác.',
                            style: GoogleFonts.urbanist(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (!hasExistingCoach && _selectedTrainerId == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            'Vui lòng chọn huấn luyện viên trước khi đặt lịch',
                            style: GoogleFonts.urbanist(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.urbanist(color: Colors.grey),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleTestButtonClick(BuildContext context) async {
    try {
      final token = await LocalStorage.getValidToken();
      if (token == null) {
        throw Exception("Token không tồn tại");
      }

      final dio = Dio();
      final client = UserService(dio);
      final response = await client.getMyInfo("Bearer $token");

      if (response.code == 0 && response.result != null) {
        final accountType =
            response.result?.accountType?.toLowerCase() ?? 'basic';

        if (accountType != 'premium') {
          // Hiển thị dialog thiết kế mới cho yêu cầu Premium
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: 'Dismiss',
            barrierColor: Colors.black.withOpacity(0.6),
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) {
              return Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Material(
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Banner gradient header
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 25),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF6F00), Color(0xFFFF6F00)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.workspace_premium,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Tính năng Premium',
                                  style: GoogleFonts.urbanist(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Content
                          Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Text(
                                  'Kiểm tra bởi Huấn luyện viên',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Tính năng này yêu cầu tài khoản Premium để sử dụng. '
                                  'Nâng cấp ngay để được huấn luyện viên kiểm tra và nhận phản hồi chuyên sâu.',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildFeatureItem(
                                        Icons.check_circle_outline,
                                        'Phản hồi chi tiết',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildFeatureItem(
                                        Icons.schedule,
                                        'Phản hồi nhanh',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildFeatureItem(
                                        Icons.video_call,
                                        'Tư vấn trực tiếp',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildFeatureItem(
                                        Icons.insert_chart,
                                        'Phân tích dữ liệu',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 32),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showGeneralDialog(
                                      context: context,
                                      barrierLabel: 'Dismiss',
                                      barrierColor:
                                          Colors.black.withOpacity(0.5),
                                      transitionDuration:
                                          const Duration(milliseconds: 300),
                                      pageBuilder: (_, __, ___) {
                                        return AccountTypePopup(
                                          selectedOption: 'Basic',
                                          options: ['Basic', 'Premium'],
                                          onSelected: (selectedType) {
                                            print(
                                                "🔶 Người dùng đã chọn gói: $selectedType");
                                          },
                                        );
                                      },
                                      transitionBuilder:
                                          (_, animation, __, child) {
                                        return Transform.scale(
                                          scale: animation.value,
                                          child: Opacity(
                                            opacity: animation.value,
                                            child: child,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFF6F00),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    minimumSize: Size(double.infinity, 50),
                                  ),
                                  child: Text(
                                    'Nâng cấp Premium',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Để sau',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            transitionBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: child,
                ),
              );
            },
          );
        } else {
          // Nếu là tài khoản Premium, hiển thị dialog chọn hình thức kiểm tra
          _showTestOptionsDialog(context);
        }
      }
    } catch (e) {
      print("❌ Lỗi khi kiểm tra loại tài khoản: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Có lỗi xảy ra: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Helper widget để hiển thị các tính năng Premium
  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(
          icon,
          color: Color(0xFFFF6F00),
          size: 28,
        ),
        SizedBox(height: 8),
        Text(
          text,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  bool _isTestTimeReached() {
    if (_scheduledTime == null) return false;
    final now = DateTime.now();
    final difference = _scheduledTime!.difference(now);
    return difference.isNegative;
  }

  // Hàm hiển thị dialog chọn hình thức kiểm tra
  void _showTestOptionsDialog(BuildContext context) {
    if (_scheduledTime != null) {
      final now = DateTime.now();
      if (now.isAfter(_scheduledTime!)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VideoCallScreen(),
          ),
        );
        return;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (_scheduledTime != null) {
          return StatefulBuilder(
            builder: (context, setState) {
              // Bắt đầu timer khi dialog hiển thị
              _startCountdownTimer(setState);

              final now = DateTime.now();
              final difference = _scheduledTime!.difference(now);

              if (difference.isNegative) {
                return AlertDialog(
                  title: Text(
                    'Sẵn sàng kiểm tra',
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Đã đến giờ kiểm tra',
                        style: GoogleFonts.urbanist(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VideoCallScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Vào phòng ngay',
                          style: GoogleFonts.urbanist(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6F00).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.timer,
                          color: Color(0xFFFF6F00),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Thời gian còn lại',
                        style: GoogleFonts.urbanist(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6F00).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${difference.inHours}h ${difference.inMinutes.remainder(60)}m ${difference.inSeconds.remainder(60)}s',
                          style: GoogleFonts.urbanist(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00FF22),
                          ),
                        ),
                      ),
                      if (_selectedTrainerId != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person,
                              color: Color(0xFFFF6F00),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'HLV: ${trainerInfo.values.firstWhere((t) => t['id'] == _selectedTrainerId)['name']}',
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                color: const Color(0xFFFF6F00),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Đóng',
                          style: GoogleFonts.urbanist(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6F00).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sports_score,
                    color: Color(0xFFFF6F00),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Chọn hình thức kiểm tra',
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bạn có thể chọn kiểm tra ngay hoặc đặt lịch cho thời điểm khác',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VideoCallScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.video_call),
                    label: Text(
                      'Gọi ngay',
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_scheduledTime == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showScheduleDialog(context);
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        'Đặt lịch',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6F00),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.urbanist(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // Hủy timer khi dialog đóng
      _countdownTimer?.cancel();
    });
  }

  // Thêm hàm kiểm tra huấn luyện viên
  Future<void> checkExistingCoach() async {
    try {
      final token = await LocalStorage.getValidToken();
      if (token == null) {
        throw Exception("Token không tồn tại");
      }

      final dio = Dio();
      final response = await dio.get(
        "http://54.251.220.228:8080/trainingSouls/users/checkExistCoach",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          hasExistingCoach = response.data == true;
        });
      }
    } catch (e) {
      print("❌ Lỗi khi kiểm tra huấn luyện viên: $e");
    }
  }

  Future<void> _handleNutritionButtonClick(int day) async {
    try {
      final token = await LocalStorage.getValidToken();
      if (token == null) {
        throw Exception("Token không tồn tại");
      }

      final dio = Dio();
      final client = UserService(dio);
      final response = await client.getMyInfo("Bearer $token");

      if (response.code == 0 && response.result != null) {
        final accountType =
            response.result?.accountType?.toLowerCase() ?? 'basic';

        if (accountType != 'premium') {
          // Hiển thị dialog thiết kế mới cho yêu cầu Premium
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: 'Dismiss',
            barrierColor: Colors.black.withOpacity(0.6),
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Material(
                      color: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Banner gradient header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF6F00), Color(0xFFFF6F00)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.workspace_premium,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Tính năng Premium',
                                  style: GoogleFonts.urbanist(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Text(
                                  'Tư vấn dinh dưỡng chuyên sâu',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tính năng này yêu cầu tài khoản Premium để sử dụng. '
                                  'Nâng cấp ngay để nhận tư vấn dinh dưỡng chi tiết và chuyên sâu.',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildFeatureItem(
                                        Icons.restaurant_menu,
                                        'Thực đơn chi tiết',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildFeatureItem(
                                        Icons.timer,
                                        'Lịch ăn uống',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildFeatureItem(
                                        Icons.health_and_safety,
                                        'Dinh dưỡng cân bằng',
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildFeatureItem(
                                        Icons.trending_up,
                                        'Theo dõi tiến độ',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showGeneralDialog(
                                      context: context,
                                      barrierLabel: 'Dismiss',
                                      barrierColor:
                                          Colors.black.withOpacity(0.5),
                                      transitionDuration:
                                          const Duration(milliseconds: 300),
                                      pageBuilder: (_, __, ___) {
                                        return AccountTypePopup(
                                          selectedOption: 'Basic',
                                          options: ['Basic', 'Premium'],
                                          onSelected: (selectedType) {
                                            print(
                                                "🔶 Người dùng đã chọn gói: $selectedType");
                                          },
                                        );
                                      },
                                      transitionBuilder:
                                          (_, animation, __, child) {
                                        return Transform.scale(
                                          scale: animation.value,
                                          child: Opacity(
                                            opacity: animation.value,
                                            child: child,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6F00),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                  ),
                                  child: Text(
                                    'Nâng cấp Premium',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Để sau',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            transitionBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: child,
                ),
              );
            },
          );
        } else {
          // Nếu là tài khoản Premium, gọi hàm hiển thị tư vấn dinh dưỡng
          _showNutritionAdvice(day);
        }
      }
    } catch (e) {
      print("❌ Lỗi khi kiểm tra loại tài khoản: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Có lỗi xảy ra: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
