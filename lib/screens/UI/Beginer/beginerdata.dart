import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_souls/data/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:training_souls/models/work_out.dart';
import 'package:training_souls/providers/workout_provider.dart';

class BeginnerDataWidget extends StatefulWidget {
  const BeginnerDataWidget({super.key});

  @override
  State<BeginnerDataWidget> createState() => _BeginnerDataWidgetState();
}

class _BeginnerDataWidgetState extends State<BeginnerDataWidget> {
  final List<List<Workout>> weeks = [];
  final Map<int, bool> expandedDays = {};
  final dbHelper = DatabaseHelper();
  bool isUpdating = false;

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

  @override
  void initState() {
    super.initState();
    _completionCache.clear();
    // Đảm bảo dữ liệu được tải khi widget khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureDataLoaded();
      _syncWorkoutStatusFromResults(); // Thêm dòng này
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

  void _showNutritionAdvice(int day) {
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
                  children: [
                    _buildMealSection(
                      "Bữa sáng",
                      Icons.breakfast_dining,
                      [
                        "2 quả trứng luộc",
                        "1 lát bánh mì nguyên cám",
                        "1 cốc sữa tươi không đường",
                        "1 quả táo hoặc chuối"
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildMealSection(
                      "Bữa trưa",
                      Icons.restaurant,
                      [
                        "150g ức gà nướng",
                        "1 chén cơm gạo lứt",
                        "Rau xanh tùy thích",
                        "1 chén súp rau củ"
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildMealSection(
                      "Bữa tối",
                      Icons.dinner_dining,
                      [
                        "150g cá hồi nướng",
                        "Salad rau trộn",
                        "1/2 chén cơm gạo lứt",
                        "1 cốc sữa chua không đường"
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildMealSection(
                      "Bữa phụ",
                      Icons.fastfood,
                      [
                        "1 nắm hạt hỗn hợp",
                        "Sinh tố protein sau tập",
                        "Trái cây tươi",
                        "Nước lọc (2-3 lít/ngày)"
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFFF6F00),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Lưu ý: Điều chỉnh khẩu phần theo nhu cầu cá nhân",
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                color: const Color(0xFFFF6F00),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String title, IconData icon, List<String> items) {
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
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 34, bottom: 5),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      item,
                      style: GoogleFonts.urbanist(fontSize: 14),
                    ),
                  ],
                ),
              )),
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
                  onTap: () => _showNutritionAdvice(day),
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
                    child: Row(
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          color: Color(0xFFFF6F00),
                          size: 20,
                        ),
                      ],
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement test start functionality
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
                "Bắt đầu kiểm tra",
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
}
